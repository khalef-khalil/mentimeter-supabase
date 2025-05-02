import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBottomNav;
  final int currentIndex;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.showBottomNav = true,
    this.currentIndex = 0,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null 
        ? AppBar(
            title: Text(
              title!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: actions,
          )
        : null,
      body: SafeArea(
        child: child,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showBottomNav 
        ? Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Colors.grey.shade600,
                showUnselectedLabels: true,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded),
                    activeIcon: Icon(Icons.home_rounded, size: 28),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_outline),
                    activeIcon: Icon(Icons.favorite, size: 28),
                    label: 'Favorites',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history_rounded),
                    activeIcon: Icon(Icons.history_rounded, size: 28),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person, size: 28),
                    label: 'Profile',
                  ),
                ],
                onTap: (index) {
                  if (index == currentIndex) return;
                  
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
              ),
            ),
          )
        : null,
    );
  }
} 