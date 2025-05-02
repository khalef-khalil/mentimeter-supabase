import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../widgets/app_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  final SupabaseService _supabaseService = SupabaseService();
  
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = _supabaseService.currentUser;
    
    return AppScaffold(
      title: 'Profile',
      currentIndex: 3,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Icon(
              Icons.person,
              size: 50,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user?.email ?? 'Guest User',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistics'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/stats'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Quiz History'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/history'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/favorites'),
          ),
          const Divider(),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              await _supabaseService.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
} 