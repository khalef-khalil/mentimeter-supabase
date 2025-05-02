import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../utils/logger.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  AuthMode _authMode = AuthMode.login;
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login 
          ? AuthMode.register 
          : AuthMode.login;
    });
  }
  
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (_authMode == AuthMode.login) {
        await _supabaseService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        final response = await _supabaseService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        if (mounted) {
          if (response.user != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully. Please check your email to confirm your account.'),
              ),
            );
          } else {
            String errorMsg = response.session == null ? "Could not create account" : "";
            AppLogger.error('Signup failed', error: errorMsg);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $errorMsg'),
              ),
            );
          }
        }
      }
      
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Authentication failed';
        if (e.toString().contains('email_address_invalid')) {
          errorMessage = 'Invalid email format. Please check your email address.';
        } else if (e.toString().contains('invalid_credentials')) {
          errorMessage = 'Invalid email or password.';
        } else if (e.toString().contains('weak_password')) {
          errorMessage = 'Password is too weak. Use a stronger password.';
        }
        
        AppLogger.error('Auth error', error: '$e - Displayed to user as: $errorMessage');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and Header
                Center(
                  child: Icon(
                    Icons.poll,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Mencimeter',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _authMode == AuthMode.login ? 'Welcome back!' : 'Create your account',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Form
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email address',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email';
                              }
                              if (!value.contains('@')) {
                                return 'Email must contain @';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _authMode == AuthMode.login ? 'Login' : 'Register',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _isLoading ? null : _switchAuthMode,
                  child: Text(
                    _authMode == AuthMode.login
                        ? 'Don\'t have an account? Sign up'
                        : 'Already have an account? Log in',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Demo login button - only for development purposes
                if (_authMode == AuthMode.login)
                  Center(
                    child: TextButton.icon(
                      onPressed: _isLoading ? null : () {
                        _emailController.text = 'demo@example.com';
                        _passwordController.text = 'password123';
                        _submit();
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Try Demo Account'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
} 