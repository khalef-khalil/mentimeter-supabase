import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz.dart';
import '../services/supabase_service.dart';
import '../widgets/quiz_filter_bar.dart';
import '../widgets/quiz_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  List<Quiz> _quizzes = [];
  
  QuizDifficulty? _selectedDifficulty;
  QuizCategory? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }
  
  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final quizzes = await _supabaseService.getFavoriteQuizzes(
        difficulty: _selectedDifficulty,
        category: _selectedCategory,
      );
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
          SnackBar(content: Text('Error loading favorites: $e')),
        );
      }
    }
  }

  void _toggleFavorite(String quizId, bool isFavorite) async {
    try {
      await _supabaseService.toggleFavorite(quizId, isFavorite);
      _loadFavorites();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating favorite: $e')),
        );
      }
    }
  }
  
  void _applyFilters(QuizDifficulty? difficulty, QuizCategory? category) {
    setState(() {
      _selectedDifficulty = difficulty;
      _selectedCategory = category;
    });
    _loadFavorites();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Quizzes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          QuizFilterBar(
            onApplyFilters: _applyFilters,
            initialDifficulty: _selectedDifficulty,
            initialCategory: _selectedCategory,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _quizzes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No favorite quizzes yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add quizzes to your favorites to see them here',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () => context.go('/'),
                              child: const Text('Browse Quizzes'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFavorites,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _quizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = _quizzes[index];
                            return QuizCard(
                              quiz: quiz,
                              onFavoriteToggle: _toggleFavorite,
                              onTap: () => context.go('/quiz/${quiz.id}'),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
} 