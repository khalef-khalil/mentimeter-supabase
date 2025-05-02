import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/quiz_attempt.dart';
import '../services/supabase_service.dart';
import '../widgets/app_scaffold.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  List<QuizAttempt> _attempts = [];
  
  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }
  
  Future<void> _loadAttempts() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final attempts = await _supabaseService.getUserQuizAttempts();
      setState(() {
        _attempts = attempts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quiz history: $e')),
        );
      }
    }
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }
  
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Quiz History',
      currentIndex: 2,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attempts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history_edu,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No quiz history yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Take some quizzes to see your history',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Find Quizzes'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _attempts.length,
                  itemBuilder: (context, index) {
                    final attempt = _attempts[index];
                    final bool isCompleted = attempt.isCompleted;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attempt.quizTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(attempt.startedAt),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            isCompleted
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Score'),
                                            Text(
                                              attempt.scoreFormatted,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Questions'),
                                            Text(
                                              '${attempt.correctAnswers}/${attempt.totalQuestions} correct',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      'In Progress',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 