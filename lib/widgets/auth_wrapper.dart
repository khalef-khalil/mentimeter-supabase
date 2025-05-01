import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../screens/auth_screen.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;
  
  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final SupabaseService _supabaseService = SupabaseService();
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _supabaseService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data?.session?.user;
          
          if (user == null) {
            return const AuthScreen();
          }
          
          return widget.child;
        }
        
        // Show a loading indicator while waiting for the auth state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
} 