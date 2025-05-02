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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card header with title and actions
                Row(
                  children: [
                    // Category icon chip
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(quiz.category),
                        size: 22,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getCategoryText(quiz.category),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Action buttons
                    if (showActions) ...[
                      // Favorite button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => onToggleFavorite(quiz.id, !quiz.isFavorite),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              quiz.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: quiz.isFavorite ? Colors.red : Colors.grey.shade400,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      
                      // Delete button
                      if (onDelete != null)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Quiz'),
                                  content: const Text('Are you sure you want to delete this quiz? This action cannot be undone.'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
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
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      
                      // Stats button
                      if (onViewResponses != null)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: onViewResponses,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.bar_chart,
                                color: colorScheme.primary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                
                // Card footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Difficulty pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(quiz.difficulty).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getDifficultyIcon(quiz.difficulty),
                            size: 16,
                            color: _getDifficultyColor(quiz.difficulty),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getDifficultyText(quiz.difficulty),
                            style: TextStyle(
                              fontSize: 13,
                              color: _getDifficultyColor(quiz.difficulty),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Creation date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${quiz.createdAt.day}/${quiz.createdAt.month}/${quiz.createdAt.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getDifficultyIcon(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return Icons.sentiment_satisfied_rounded;
      case QuizDifficulty.medium:
        return Icons.sentiment_neutral_rounded;
      case QuizDifficulty.hard:
        return Icons.sentiment_dissatisfied_rounded;
    }
  }
} 