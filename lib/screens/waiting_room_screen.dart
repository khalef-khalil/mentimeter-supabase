import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz.dart';
import '../models/quiz_session.dart';
import '../services/supabase_service.dart';
import '../widgets/app_scaffold.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String sessionCode;
  final bool isHost;
  
  const WaitingRoomScreen({
    super.key,
    required this.sessionCode,
    this.isHost = false,
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  Quiz? _quiz;
  QuizSession? _session;
  List<Map<String, dynamic>> _participants = [];
  bool _isLoading = true;
  bool _quizStarted = false;
  String? _error;
  StreamSubscription? _sessionSubscription;
  StreamSubscription? _participantsSubscription;
  
  @override
  void initState() {
    super.initState();
    _loadSessionAndQuiz();
  }
  
  @override
  void dispose() {
    _sessionSubscription?.cancel();
    _participantsSubscription?.cancel();
    super.dispose();
  }
  
  Future<void> _loadSessionAndQuiz() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final result = await _supabaseService.getSessionWithQuizByCode(widget.sessionCode);
      final session = result['session'];
      final quiz = result['quiz'];
      
      final participants = await _supabaseService.getParticipantsForSession(session.id);

      print('Session loaded: ${session.id}, has_started: ${session.hasStarted}');
      
      // If the quiz has already started, navigate directly to the quiz screen
      if (session.hasStarted) {
        print('Quiz has already started, navigating directly');
        if (mounted) {
          context.go('/quiz/${quiz.id}?session=${widget.sessionCode}');
          return;
        }
      }
      
      setState(() {
        _session = session;
        _quiz = quiz;
        _participants = participants;
        _isLoading = false;
      });
      
      // Cancel any existing subscriptions before setting up new ones
      _sessionSubscription?.cancel();
      _participantsSubscription?.cancel();
      
      // Set up real-time subscriptions after we have the session ID
      _setupRealtimeSubscription();
    } catch (e) {
      print('Error loading session: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading session: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _setupRealtimeSubscription() {
    if (_session == null) {
      print('Cannot set up subscriptions: Session is null');
      return;
    }

    print('Setting up realtime subscriptions for session: ${_session!.id}');
    
    // Subscribe to changes in the session
    _sessionSubscription = _supabaseService.subscribeToSession(widget.sessionCode)
      .listen((event) {
        print('Session update received: $event');
        
        // Check if the quiz has started
        if (event.isNotEmpty && event['has_started'] == true && !_quizStarted) {
          print('Quiz has started, navigating to quiz screen');
          setState(() {
            _quizStarted = true;
          });
          
          // Navigate to the quiz screen
          if (mounted && _quiz != null) {
            context.go('/quiz/${_quiz!.id}?session=${widget.sessionCode}');
          }
        }
      });
      
    // Also subscribe to participants changes
    _participantsSubscription = _supabaseService.subscribeToParticipants(_session!.id)
      .listen((participants) {
        if (mounted) {
          print('Received participants update: ${participants.length} participants');
          setState(() {
            _participants = participants;
          });
        }
      });
  }
  
  Future<void> _startQuiz() async {
    if (!widget.isHost || _session == null) {
      print('Cannot start quiz: isHost=${widget.isHost}, session=${_session != null}');
      return;
    }
    
    try {
      print('Starting quiz for session: ${_session!.id}');
      await _supabaseService.startSessionQuiz(_session!.id);
      print('Quiz started successfully');
      
      // For immediate feedback, update the local state
      setState(() {
        _quizStarted = true;
      });
      
      // Navigate directly instead of waiting for the subscription
      if (mounted && _quiz != null) {
        context.go('/quiz/${_quiz!.id}?session=${widget.sessionCode}');
      }
    } catch (e) {
      print('Error starting quiz: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting quiz: $e')),
        );
      }
    }
  }
  
  void _copyJoinCode() {
    final joinCode = widget.sessionCode;
    Clipboard.setData(ClipboardData(text: joinCode));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Join code copied to clipboard')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Waiting Room',
      showBottomNav: false,
      actions: [
        if (!widget.isHost)
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => context.go('/'),
            tooltip: 'Leave waiting room',
          ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Could not load waiting room',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!.replaceAll('Exception: ', ''),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/'),
                          icon: const Icon(Icons.home),
                          label: const Text('Go to Home'),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                _quiz?.title ?? 'Quiz Loading...',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Waiting for the host to start the quiz',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.sessionCode,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 8,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      onPressed: _copyJoinCode,
                                      tooltip: 'Copy code',
                                      iconSize: 28,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      Expanded(
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Participants (${_participants.length})',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.refresh),
                                      onPressed: _loadSessionAndQuiz,
                                      tooltip: 'Refresh',
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: _participants.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No participants yet',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: _participants.length,
                                        itemBuilder: (context, index) {
                                          final participant = _participants[index];
                                          final username = participant['username'] ?? 'Anonymous';
                                          final isHost = participant['is_host'] ?? false;
                                          
                                          return ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: isHost
                                                  ? Colors.amber.shade300
                                                  : Colors.blue.shade200,
                                              child: Icon(
                                                isHost ? Icons.star : Icons.person,
                                                color: isHost ? Colors.amber.shade800 : Colors.blue.shade800,
                                              ),
                                            ),
                                            title: Text(
                                              username,
                                              style: TextStyle(
                                                fontWeight: isHost ? FontWeight.bold : null,
                                              ),
                                            ),
                                            trailing: isHost
                                                ? const Chip(
                                                    label: Text('Host'),
                                                    backgroundColor: Colors.amber,
                                                    labelStyle: TextStyle(color: Colors.white),
                                                  )
                                                : null,
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      if (widget.isHost) ...[
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _participants.length > 0 ? _startQuiz : null,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('START QUIZ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (_participants.isEmpty) ...[
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              'Wait for participants to join',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
    );
  }
} 