import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../widgets/app_scaffold.dart';

class LeaderboardScreen extends StatefulWidget {
  final String sessionId;
  final bool isHost;
  
  const LeaderboardScreen({
    super.key,
    required this.sessionId,
    this.isHost = false,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _leaderboardEntries = [];
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer;
  int _completedCount = 0;
  int _totalParticipants = 0;
  
  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
    
    // If host, start a timer to refresh the leaderboard every few seconds
    if (widget.isHost) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        _loadLeaderboard();
      });
    }
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadLeaderboard() async {
    try {
      // Get the leaderboard entries
      final entries = await _supabaseService.getLeaderboard(widget.sessionId);
      
      // Get the total participants count
      final participants = await _supabaseService.getParticipantsForSession(widget.sessionId);
      
      setState(() {
        _leaderboardEntries = entries;
        _completedCount = entries.length;
        _totalParticipants = participants.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading leaderboard: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Quiz Results',
      showBottomNav: true,
      currentIndex: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadLeaderboard,
          tooltip: 'Refresh results',
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
                          'Could not load results',
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
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Quiz Results',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (widget.isHost && _completedCount < _totalParticipants) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.timer, color: Colors.amber.shade800),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$_completedCount of $_totalParticipants completed',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _leaderboardEntries.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.leaderboard,
                                    size: 64,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No results yet',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Waiting for participants to complete the quiz',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _leaderboardEntries.length,
                              itemBuilder: (context, index) {
                                final entry = _leaderboardEntries[index];
                                
                                // Handle both the new view format and the old join format
                                final String username;
                                final bool isHost;
                                
                                if (entry.containsKey('username')) {
                                  // New view format
                                  username = entry['username'] ?? 'Anonymous';
                                  isHost = entry['is_host'] ?? false;
                                } else if (entry.containsKey('session_participants')) {
                                  // Old join format
                                  username = entry['session_participants']['username'] ?? 'Anonymous';
                                  isHost = entry['session_participants']['is_host'] ?? false;
                                } else {
                                  // Fallback
                                  username = 'Participant ${index + 1}';
                                  isHost = false;
                                }
                                
                                final score = entry['score'] as int;
                                final timeSpent = entry['time_spent'] as int;
                                final position = index + 1;
                                
                                // Get medal colors for top 3
                                Color? medalColor;
                                if (position == 1) {
                                  medalColor = Colors.amber;
                                } else if (position == 2) {
                                  medalColor = Colors.grey.shade400;
                                } else if (position == 3) {
                                  medalColor = Colors.brown.shade300;
                                }
                                
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16, 
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    leading: medalColor != null
                                        ? CircleAvatar(
                                            backgroundColor: medalColor,
                                            child: Text(
                                              position.toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : CircleAvatar(
                                            backgroundColor: Colors.grey.shade200,
                                            child: Text(
                                              position.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                    title: Text(
                                      username,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isHost ? Colors.amber.shade700 : null,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Time: ${_formatTime(timeSpent)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    trailing: Text(
                                      '$score pts',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go('/'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                          child: const Text('Back to Home'),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
} 