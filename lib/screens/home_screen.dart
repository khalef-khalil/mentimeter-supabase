import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz.dart';
import '../services/supabase_service.dart';
import '../widgets/quiz_filter_bar.dart';
import '../widgets/quiz_card.dart';
import '../widgets/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  List<Quiz> _quizzes = [];
  late TabController _tabController;
  
  QuizDifficulty? _selectedDifficulty;
  QuizCategory? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadUserQuizzes();
  }
  
  Future<void> _loadUserQuizzes() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final quizzes = await _supabaseService.getUserQuizzes(
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
          SnackBar(content: Text('Error loading quizzes: $e')),
        );
      }
    }
  }
  
  Future<void> _loadPublicQuizzes() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final quizzes = await _supabaseService.getActiveQuizzes(
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
          SnackBar(content: Text('Error loading quizzes: $e')),
        );
      }
    }
  }
  
  void _onTabChanged() {
    setState(() {
      // Reset filters when changing tabs
      _selectedDifficulty = null;
      _selectedCategory = null;
    });
    
    if (_tabController.index == 0) {
      _loadUserQuizzes();
    } else {
      _loadPublicQuizzes();
    }
  }
  
  void _applyFilters(QuizDifficulty? difficulty, QuizCategory? category) {
    setState(() {
      _selectedDifficulty = difficulty;
      _selectedCategory = category;
    });
    
    if (_tabController.index == 0) {
      _loadUserQuizzes();
    } else {
      _loadPublicQuizzes();
    }
  }
  
  void _toggleFavorite(String quizId, bool isFavorite) async {
    try {
      await _supabaseService.toggleFavorite(quizId, isFavorite);
      
      // Refresh the list
      if (_tabController.index == 0) {
        _loadUserQuizzes();
      } else {
        _loadPublicQuizzes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating favorite: $e')),
        );
      }
    }
  }
  
  Future<void> _deleteQuiz(String quizId) async {
    try {
      await _supabaseService.deleteQuiz(quizId);
      _loadUserQuizzes();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting quiz: $e')),
        );
      }
    }
  }
  
  Future<void> _logout() async {
    try {
      await _supabaseService.signOut();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mencimeter'),
          actions: [
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () => context.go('/join'),
              tooltip: 'Join Quiz',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'My Quizzes'),
              Tab(text: 'Public Quizzes'),
            ],
            labelColor: Colors.white,
          ),
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
                              const Text(
                                'No quizzes found',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              if (_tabController.index == 0) ...[
                                const Text(
                                  'Create your first quiz',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () => context.go('/create'),
                                  child: const Text('Create Quiz'),
                                ),
                              ] else ...[
                                const Text(
                                  'Try different filters or join a quiz with a code',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () => context.go('/join'),
                                  child: const Text('Join Quiz with Code'),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _quizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = _quizzes[index];
                            return QuizCard(
                              quiz: quiz,
                              onToggleFavorite: (quizId, isFavorite) => 
                                _toggleFavorite(quizId, isFavorite),
                              onTap: () {
                                if (_tabController.index == 0) {
                                  context.go('/host/${quiz.id}');
                                } else {
                                  context.go('/quiz/${quiz.id}');
                                }
                              },
                              onDelete: _tabController.index == 0
                                  ? () => _deleteQuiz(quiz.id)
                                  : null,
                              onViewResponses: _tabController.index == 0
                                  ? () => context.go('/responses/${quiz.id}')
                                  : null,
                            );
                          },
                        ),
            ),
          ],
        ),
        floatingActionButton: _tabController.index == 0
            ? FloatingActionButton(
                onPressed: () => context.go('/create'),
                tooltip: 'Create a new quiz',
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
} 