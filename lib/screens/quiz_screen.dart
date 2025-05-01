import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import '../services/supabase_service.dart';
import '../widgets/multiple_choice_question.dart';
import '../widgets/word_cloud_question.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  
  const QuizScreen({super.key, required this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  Quiz? _quiz;
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }
  
  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final quiz = await _supabaseService.getQuiz(widget.quizId);
      final questions = await _supabaseService.getQuestionsForQuiz(widget.quizId);
      
      setState(() {
        _quiz = quiz;
        _questions = questions;
        _isLoading = false;
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
  
  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
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
      _nextQuestion();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting response: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_quiz?.title ?? 'Quiz'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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