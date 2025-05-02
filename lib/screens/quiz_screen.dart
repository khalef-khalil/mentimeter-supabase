import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import '../models/quiz_session.dart';
import '../models/quiz_attempt.dart';
import '../services/supabase_service.dart';
import '../widgets/multiple_choice_question.dart';
import '../widgets/word_cloud_question.dart';
import '../widgets/app_scaffold.dart';

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
  QuizAttempt? _attempt;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  Timer? _timer;
  int _timeRemaining = 0;
  int _correctAnswers = 0;
  String? _error;
  
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
      // If we have a session code, first verify the session and get quiz together
      if (widget.sessionCode != null) {
        try {
          final result = await _supabaseService.getSessionWithQuizByCode(widget.sessionCode!);
          final session = result['session'];
          final quiz = result['quiz'];
          
          setState(() {
            _session = session;
            _quiz = quiz;
          });
          
          // Now get the questions
          final questions = await _supabaseService.getQuestionsForQuiz(quiz.id);
          
          setState(() {
            _questions = questions;
            _isLoading = false;
            
            if (_questions.isNotEmpty) {
              _startTimer();
            }
          });
          
          // Start tracking the quiz attempt
          if (_supabaseService.currentUser != null) {
            try {
              final attempt = await _supabaseService.startQuizAttempt(
                quiz.id, 
                quiz.title, 
                questions.length
              );
              setState(() {
                _attempt = attempt;
              });
            } catch (e) {
              // Failed to track attempt, continue without it
              debugPrint('Failed to track quiz attempt: $e');
            }
          }
          
          return;  // Exit early as we've loaded everything we need
        } catch (e) {
          // We couldn't load by session, continue to try loading by quiz ID directly
          debugPrint('Error loading quiz by session: $e');
        }
      }
      
      // If we don't have a session code or loading by session failed, load normally
      final quiz = await _supabaseService.getQuiz(widget.quizId);
      final questions = await _supabaseService.getQuestionsForQuiz(widget.quizId);
      
      // Start tracking the quiz attempt
      if (_supabaseService.currentUser != null) {
        try {
          final attempt = await _supabaseService.startQuizAttempt(
            quiz.id, 
            quiz.title, 
            questions.length
          );
          setState(() {
            _attempt = attempt;
          });
        } catch (e) {
          // Failed to track attempt, continue without it
          debugPrint('Failed to track quiz attempt: $e');
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
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading quiz: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
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
      // Complete the quiz attempt if we're tracking
      if (_attempt != null) {
        _supabaseService.completeQuizAttempt(_attempt!.id, _correctAnswers);
      }
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quiz Complete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('You have completed the quiz. Thank you for participating!'),
              const SizedBox(height: 16),
              Text('Your score: $_correctAnswers out of ${_questions.length}'),
              Text('Percentage: ${(_correctAnswers / _questions.length * 100).toStringAsFixed(0)}%'),
            ],
          ),
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
      
      // Check if the answer is correct for multiple choice
      final question = _questions[_currentQuestionIndex];
      if (question.questionType == QuestionType.multipleChoice &&
          question.correctOption != null &&
          responseData['selected_option'] == question.correctOption) {
        setState(() {
          _correctAnswers++;
        });
      }
      
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
    return AppScaffold(
      title: _quiz?.title ?? 'Quiz',
      showBottomNav: true,
      currentIndex: 0,
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
                          'Could not load quiz',
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
                          
                          // Progress and score display
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Question: ${_currentQuestionIndex + 1}/${_questions.length}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Score: $_correctAnswers',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          // Progress bar
                          LinearProgressIndicator(
                            value: (_currentQuestionIndex + 1) / _questions.length,
                            backgroundColor: Colors.grey[300],
                            color: Theme.of(context).colorScheme.primary,
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
          key: ValueKey('question_${_currentQuestionIndex}_${question.id}'),
          question: question,
          onSubmit: _submitResponse,
          onNext: _nextQuestion,
        );
      case QuestionType.wordCloud:
        return WordCloudQuestion(
          key: ValueKey('question_${_currentQuestionIndex}_${question.id}'),
          question: question,
          onSubmit: _submitResponse,
        );
      default:
        return const Center(child: Text('Unsupported question type'));
    }
  }
} 