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
      appBar: AppBar(
        title: Text(_authMode == AuthMode.login ? 'Login' : 'Register'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          child: Text(
                            _authMode == AuthMode.login ? 'Login' : 'Register',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _switchAuthMode,
                          child: Text(
                            _authMode == AuthMode.login
                                ? 'Create an account'
                                : 'I already have an account',
                          ),
                        ),
                      ],
                    ),
                ],
              ),
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