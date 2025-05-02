import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/question.dart';
import '../services/supabase_service.dart';
import '../widgets/question_form.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];
  final SupabaseService _supabaseService = SupabaseService();
  bool _isCreating = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
  
  void _addQuestion() {
    setState(() {
      _questions.add({
        'text': '',
        'type': QuestionType.multipleChoice,
        'options': ['', ''],
        'timerSeconds': 30,
      });
    });
  }
  
  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }
  
  void _updateQuestion(int index, Map<String, dynamic> data) {
    setState(() {
      _questions[index] = data;
    });
  }
  
  Future<void> _createQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a quiz title')),
      );
      return;
    }
    
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one question')),
      );
      return;
    }
    
    setState(() {
      _isCreating = true;
    });
    
    try {
      // Create quiz
      final quiz = await _supabaseService.createQuiz(title);
      
      // Create questions
      for (int i = 0; i < _questions.length; i++) {
        final question = _questions[i];
        await _supabaseService.createQuestion(
          quizId: quiz.id,
          questionText: question['text'],
          questionType: question['type'],
          options: question['type'] == QuestionType.multipleChoice ? question['options'] : null,
          correctOption: question['type'] == QuestionType.multipleChoice ? question['correctOption'] : null,
          position: i,
          timerSeconds: question['timerSeconds'] ?? 30,
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz created successfully')),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating quiz: $e')),
        );
      }
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isCreating
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Quiz Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a quiz title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Questions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._questions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final question = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: QuestionForm(
                          initialData: question,
                          onChanged: (data) => _updateQuestion(index, data),
                          onRemove: () => _removeQuestion(index),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Question'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_questions.isNotEmpty)
                      Center(
                        child: ElevatedButton(
                          onPressed: _createQuiz,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('Create Quiz'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
} 