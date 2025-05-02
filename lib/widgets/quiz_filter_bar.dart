import 'package:flutter/material.dart';
import '../models/quiz.dart';

class QuizFilterBar extends StatefulWidget {
  final Function(QuizDifficulty?, QuizCategory?) onApplyFilters;
  final QuizDifficulty? initialDifficulty;
  final QuizCategory? initialCategory;
  
  const QuizFilterBar({
    super.key,
    required this.onApplyFilters,
    this.initialDifficulty,
    this.initialCategory,
  });

  @override
  State<QuizFilterBar> createState() => _QuizFilterBarState();
}

class _QuizFilterBarState extends State<QuizFilterBar> {
  late QuizDifficulty? _selectedDifficulty;
  late QuizCategory? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
    _selectedCategory = widget.initialCategory;
  }
  
  String _getDifficultyLabel(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return 'Easy';
      case QuizDifficulty.medium:
        return 'Medium';
      case QuizDifficulty.hard:
        return 'Hard';
    }
  }
  
  String _getCategoryLabel(QuizCategory category) {
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
  
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
    );
  }
  
  void _applyFilters() {
    widget.onApplyFilters(_selectedDifficulty, _selectedCategory);
  }
  
  void _resetFilters() {
    setState(() {
      _selectedDifficulty = null;
      _selectedCategory = null;
    });
    widget.onApplyFilters(null, null);
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Quizzes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.clear),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Difficulty',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip(
                  label: 'Easy',
                  isSelected: _selectedDifficulty == QuizDifficulty.easy,
                  onSelected: () {
                    setState(() {
                      _selectedDifficulty = _selectedDifficulty == QuizDifficulty.easy
                          ? null
                          : QuizDifficulty.easy;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterChip(
                  label: 'Medium',
                  isSelected: _selectedDifficulty == QuizDifficulty.medium,
                  onSelected: () {
                    setState(() {
                      _selectedDifficulty = _selectedDifficulty == QuizDifficulty.medium
                          ? null
                          : QuizDifficulty.medium;
                    });
                    _applyFilters();
                  },
                ),
                _buildFilterChip(
                  label: 'Hard',
                  isSelected: _selectedDifficulty == QuizDifficulty.hard,
                  onSelected: () {
                    setState(() {
                      _selectedDifficulty = _selectedDifficulty == QuizDifficulty.hard
                          ? null
                          : QuizDifficulty.hard;
                    });
                    _applyFilters();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: QuizCategory.values.map((category) {
                return _buildFilterChip(
                  label: _getCategoryLabel(category),
                  isSelected: _selectedCategory == category,
                  onSelected: () {
                    setState(() {
                      _selectedCategory = _selectedCategory == category
                          ? null
                          : category;
                    });
                    _applyFilters();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
} 