import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz.dart';
import '../services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  List<Quiz> _quizzes = [];
  
  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }
  
  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final quizzes = await _supabaseService.getQuizzes();
      setState(() {
        _quizzes = quizzes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quizzes: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mencimeter'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No quizzes yet',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.go('/create'),
                        child: const Text('Create Quiz'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadQuizzes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = _quizzes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(
                            quiz.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Created: ${quiz.createdAt.toString().substring(0, 16)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                quiz.active
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: quiz.active ? Colors.green : Colors.grey,
                              ),
                              Switch(
                                value: quiz.active,
                                onChanged: (value) async {
                                  await _supabaseService.updateQuizActive(
                                    quiz.id,
                                    value,
                                  );
                                  _loadQuizzes();
                                },
                              ),
                            ],
                          ),
                          onTap: () => context.go('/responses/${quiz.id}'),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
} 