import 'package:flutter/material.dart';
import '../models/quiz.dart';

class QuizCard extends StatelessWidget {
  final Quiz quiz;
  final Function(String, bool) onToggleFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onViewResponses;
  final bool showActions;
  
  const QuizCard({
    super.key,
    required this.quiz,
    required this.onToggleFavorite,
    this.onTap,
    this.onDelete,
    this.onViewResponses,
    this.showActions = true,
  });
  
  String _getDifficultyText(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return 'Easy';
      case QuizDifficulty.medium:
        return 'Medium';
      case QuizDifficulty.hard:
        return 'Hard';
    }
  }
  
  Color _getDifficultyColor(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return Colors.green;
      case QuizDifficulty.medium:
        return Colors.orange;
      case QuizDifficulty.hard:
        return Colors.red;
    }
  }
  
  String _getCategoryText(QuizCategory category) {
    switch (category) {
      case QuizCategory.general:
        return 'General';
      case QuizCategory.science:
        return 'Science';
      case QuizCategory.history:
        return 'History';
      case QuizCategory.geography:
        return 'Geography';
      case QuizCategory.entertainment:
        return 'Entertainment';
      case QuizCategory.sports:
        return 'Sports';
      case QuizCategory.technology:
        return 'Technology';
    }
  }
  
  IconData _getCategoryIcon(QuizCategory category) {
    switch (category) {
      case QuizCategory.general:
        return Icons.help;
      case QuizCategory.science:
        return Icons.science;
      case QuizCategory.history:
        return Icons.history_edu;
      case QuizCategory.geography:
        return Icons.public;
      case QuizCategory.entertainment:
        return Icons.movie;
      case QuizCategory.sports:
        return Icons.sports_soccer;
      case QuizCategory.technology:
        return Icons.computer;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (showActions) ...[
                    IconButton(
                      icon: Icon(
                        quiz.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: quiz.isFavorite ? Colors.red : null,
                      ),
                      onPressed: () => onToggleFavorite(quiz.id, !quiz.isFavorite),
                      tooltip: quiz.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                    ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Quiz'),
                              content: const Text('Are you sure you want to delete this quiz? This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onDelete!();
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        tooltip: 'Delete quiz',
                        color: Colors.red,
                      ),
                    if (onViewResponses != null)
                      IconButton(
                        icon: const Icon(Icons.bar_chart),
                        onPressed: onViewResponses,
                        tooltip: 'View responses',
                        color: Colors.blue,
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(quiz.category),
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getCategoryText(quiz.category),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(quiz.difficulty).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getDifficultyText(quiz.difficulty),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getDifficultyColor(quiz.difficulty),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Created: ${quiz.createdAt.toString().substring(0, 16)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 