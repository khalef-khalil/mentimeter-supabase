import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import '../models/response.dart';
import '../services/supabase_service.dart';
import '../widgets/app_scaffold.dart';

class QuizResponsesScreen extends StatefulWidget {
  final String quizId;
  
  const QuizResponsesScreen({super.key, required this.quizId});

  @override
  State<QuizResponsesScreen> createState() => _QuizResponsesScreenState();
}

class _QuizResponsesScreenState extends State<QuizResponsesScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  Quiz? _quiz;
  List<Question> _questions = [];
  Map<String, List<QuizResponse>> _responses = {};
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final quiz = await _supabaseService.getQuiz(widget.quizId);
      final questions = await _supabaseService.getQuestionsForQuiz(widget.quizId);
      
      final Map<String, List<QuizResponse>> responses = {};
      for (final question in questions) {
        final questionResponses = await _supabaseService.getResponsesForQuestion(question.id);
        responses[question.id] = questionResponses;
      }
      
      setState(() {
        _quiz = quiz;
        _questions = questions;
        _responses = responses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _quiz?.title ?? 'Quiz Responses',
      showBottomNav: true,
      currentIndex: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            final url = Uri.base.toString().replaceAll('/responses/${widget.quizId}', '/quiz/${widget.quizId}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Share this link: $url'),
                action: SnackBarAction(
                  label: 'Copy',
                  onPressed: () {
                    // In a real app, you would copy to clipboard here
                  },
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Back to Home',
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? const Center(child: Text('No questions available'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      final questionResponses = _responses[question.id] ?? [];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Q${index + 1}: ${question.questionText}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Type: ${question.questionType == QuestionType.multipleChoice ? 'Multiple Choice' : 'Word Cloud'}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Responses:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              questionResponses.isEmpty
                                  ? const Text('No responses yet')
                                  : _buildResponsesList(question, questionResponses),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_quiz?.active == true) {
            context.go('/quiz/${widget.quizId}');
          } else {
            _updateQuizActive(true);
          }
        },
        label: Text(_quiz?.active == true ? 'View Live' : 'Activate Quiz'),
        icon: Icon(_quiz?.active == true ? Icons.visibility : Icons.play_arrow),
      ),
    );
  }
  
  Widget _buildResponsesList(Question question, List<QuizResponse> responses) {
    if (question.questionType == QuestionType.multipleChoice) {
      // Count occurrences of each option
      final Map<String, int> optionCounts = {};
      for (final response in responses) {
        final option = response.responseData['selected_option'] as String?;
        if (option != null) {
          optionCounts[option] = (optionCounts[option] ?? 0) + 1;
        }
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total responses: ${responses.length}'),
          const SizedBox(height: 8),
          ...question.options?.map((option) {
            final count = optionCounts[option] ?? 0;
            final percentage = responses.isEmpty ? 0.0 : count / responses.length;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[300],
                    color: Theme.of(context).colorScheme.primary,
                    minHeight: 12,
                  ),
                  Text('$count votes (${(percentage * 100).toStringAsFixed(1)}%)'),
                ],
              ),
            );
          }).toList() ?? [],
        ],
      );
    } else {
      // Word cloud responses
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total responses: ${responses.length}'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: responses.map((response) {
              final text = response.responseData['text'] as String?;
              return text != null
                  ? Chip(
                      label: Text(text),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    )
                  : const SizedBox.shrink();
            }).toList(),
          ),
        ],
      );
    }
  }
  
  Future<void> _updateQuizActive(bool active) async {
    try {
      await _supabaseService.updateQuizActive(widget.quizId, active);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quiz ${active ? 'activated' : 'deactivated'} successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating quiz: $e')),
        );
      }
    }
  }
} 