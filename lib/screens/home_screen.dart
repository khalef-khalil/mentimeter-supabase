import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz.dart';
import '../services/supabase_service.dart';

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
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserQuizzes();
  }
  
  Future<void> _loadUserQuizzes() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final quizzes = await _supabaseService.getUserQuizzes();
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
      final quizzes = await _supabaseService.getActiveQuizzes();
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
    if (_tabController.index == 0) {
      _loadUserQuizzes();
    } else {
      _loadPublicQuizzes();
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
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mencimeter'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () => context.go('/join'),
            tooltip: 'Join Quiz',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => _onTabChanged(),
          tabs: const [
            Tab(text: 'My Quizzes'),
            Tab(text: 'Public Quizzes'),
          ],
          labelColor: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildQuizList(),
              _buildQuizList(),
            ],
          ),
          if (_tabController.index == 1)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: _buildJoinQuizButton(),
              ),
            ),
        ],
      ),
      floatingActionButton: _tabController.index == 0 
          ? FloatingActionButton(
              onPressed: () => context.go('/create'),
              tooltip: 'Create Quiz',
              child: const Icon(Icons.add),
            )
          : FloatingActionButton(
              onPressed: () => context.go('/join'),
              tooltip: 'Join with Code',
              backgroundColor: Colors.amber,
              child: const Icon(Icons.keyboard),
            ),
    );
  }
  
  Widget _buildJoinQuizButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: ElevatedButton(
        onPressed: () => context.go('/join'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dialpad),
            SizedBox(width: 8),
            Text('ENTER QUIZ CODE'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuizList() {
    return _isLoading
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
                    if (_tabController.index == 0) ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.go('/create'),
                        child: const Text('Create Quiz'),
                      ),
                    ] else ...[
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/join'),
                        icon: const Icon(Icons.dialpad),
                        label: const Text('Join with Code'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _tabController.index == 0 
                    ? _loadUserQuizzes 
                    : _loadPublicQuizzes,
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
                        trailing: _tabController.index == 0 ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.present_to_all),
                              onPressed: () => context.go('/host/${quiz.id}'),
                              tooltip: 'Host Quiz',
                            ),
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
                                _tabController.index == 0 
                                    ? _loadUserQuizzes() 
                                    : _loadPublicQuizzes();
                              },
                            ),
                          ],
                        ) : null,
                        onTap: () => _tabController.index == 0
                            ? context.go('/responses/${quiz.id}')
                            : context.go('/quiz/${quiz.id}'),
                      ),
                    );
                  },
                ),
              );
  }
} 