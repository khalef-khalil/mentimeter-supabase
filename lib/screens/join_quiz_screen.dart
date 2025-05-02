import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../widgets/app_scaffold.dart';

class JoinQuizScreen extends StatefulWidget {
  const JoinQuizScreen({super.key});

  @override
  State<JoinQuizScreen> createState() => _JoinQuizScreenState();
}

class _JoinQuizScreenState extends State<JoinQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  bool _isJoining = false;
  
  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
  
  Future<void> _joinQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final code = _codeController.text.trim().toUpperCase();
    
    setState(() {
      _isJoining = true;
    });
    
    try {
      // Fetch both session and quiz in one call to ensure both exist and are valid
      final result = await _supabaseService.getSessionWithQuizByCode(code);
      
      final session = result['session'];
      final quiz = result['quiz'];
      
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
        
        // Navigate to the quiz with the session join code
        context.go('/quiz/${session.quizId}?session=${session.joinCode}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
        
        String errorMessage = 'Invalid or expired join code. Please try again.';
        
        // Show a more specific error message if possible
        if (e.toString().contains('Session not found')) {
          errorMessage = 'This quiz session is no longer active or doesn\'t exist.';
        } else if (e.toString().contains('Quiz not found') || e.toString().contains('no longer available')) {
          errorMessage = 'The quiz associated with this code is not available.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Join Quiz',
      showBottomNav: true,
      currentIndex: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.quiz,
                        size: 80,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Join a Quiz Session',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Enter the 6-digit code provided by the quiz host',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 100,
                        child: TextFormField(
                          controller: _codeController,
                          decoration: InputDecoration(
                            labelText: 'Quiz Code',
                            hintText: 'Example: ABC123',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                width: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.dialpad),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(
                            fontSize: 28,
                            letterSpacing: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLength: 6,
                          onChanged: (value) {
                            // Auto-convert to uppercase
                            if (value != value.toUpperCase()) {
                              _codeController.value = _codeController.value.copyWith(
                                text: value.toUpperCase(),
                                selection: _codeController.selection,
                              );
                            }
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a join code';
                            }
                            if (value.trim().length != 6) {
                              return 'Join code must be 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isJoining ? null : _joinQuiz,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.amber.shade200,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isJoining
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text('JOIN QUIZ'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back to Home'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 