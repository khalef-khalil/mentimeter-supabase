import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import '../models/quiz_session.dart';
import '../services/supabase_service.dart';
import '../widgets/multiple_choice_question.dart';
import '../widgets/word_cloud_question.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  final String? sessionCode;
  
  const QuizScreen({
    super.key, 
    required this.quizId,
    this.sessionCode,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  Quiz? _quiz;
  QuizSession? _session;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  Timer? _timer;
  int _timeRemaining = 0;
  
  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final quiz = await _supabaseService.getQuiz(widget.quizId);
      final questions = await _supabaseService.getQuestionsForQuiz(widget.quizId);
      
      // If we have a session code, load the session
      if (widget.sessionCode != null) {
        try {
          final session = await _supabaseService.getSessionByCode(widget.sessionCode!);
          setState(() {
            _session = session;
          });
        } catch (e) {
          // Session not found or expired, continue without it
        }
      }
      
      setState(() {
        _quiz = quiz;
        _questions = questions;
        _isLoading = false;
        
        if (_questions.isNotEmpty) {
          _startTimer();
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quiz: $e')),
        );
      }
    }
  }
  
  void _startTimer() {
    // Cancel any existing timer
    _timer?.cancel();
    
    // Get the time limit for the current question
    final timeLimit = _questions[_currentQuestionIndex].timerSeconds;
    
    setState(() {
      _timeRemaining = timeLimit;
    });
    
    // Create a new timer that fires every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          // Time's up, move to the next question
          _timer?.cancel();
          _nextQuestion();
        }
      });
    });
  }
  
  void _nextQuestion() {
    // Cancel the current timer
    _timer?.cancel();
    
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        // Start the timer for the next question
        _startTimer();
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quiz Complete'),
          content: const Text('You have completed the quiz. Thank you for participating!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  
  Future<void> _submitResponse(Map<String, dynamic> responseData) async {
    try {
      await _supabaseService.submitResponse(
        _questions[_currentQuestionIndex].id, 
        responseData,
      );
      // We don't automatically move to the next question anymore
      // Let the user see the feedback first
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting response: $e')),
        );
      }
    }
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_quiz?.title ?? 'Quiz'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_session != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_pin_circle, size: 16),
                  const SizedBox(width: 4),
                  Text(_session!.joinCode),
                ],
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? const Center(child: Text('No questions available'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Timer display
                      if (_timeRemaining > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(_timeRemaining),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _timeRemaining < 10 ? Colors.red : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Progress bar
                      LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) / _questions.length,
                        backgroundColor: Colors.grey[300],
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildQuestionWidget(),
                      ),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildQuestionWidget() {
    final question = _questions[_currentQuestionIndex];
    
    switch (question.questionType) {
      case QuestionType.multipleChoice:
        return MultipleChoiceQuestion(
          question: question,
          onSubmit: _submitResponse,
          onNext: _nextQuestion,
        );
      case QuestionType.wordCloud:
        return WordCloudQuestion(
          question: question,
          onSubmit: _submitResponse,
        );
      default:
        return const Center(child: Text('Unsupported question type'));
    }
  }
} 