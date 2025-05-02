import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBottomNav;
  final int currentIndex;

  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.showBottomNav = true,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null 
        ? AppBar(
            title: Text(title!),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          )
        : null,
      body: SafeArea(
        child: child,
      ),
      bottomNavigationBar: showBottomNav 
        ? BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go('/');
                  break;
                case 1:
                  context.go('/favorites');
                  break;
                case 2:
                  context.go('/history');
                  break;
                case 3:
                  context.go('/profile');
                  break;
              }
            },
          )
        : null,
    );
  }
} 