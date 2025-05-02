import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/create_quiz_screen.dart';
import 'screens/quiz_responses_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/host_quiz_screen.dart';
import 'screens/join_quiz_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/quiz_history_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/auth_wrapper.dart';
import 'services/supabase_service.dart';
import 'utils/logger.dart';

void main() async {
  // Override Flutter's error handling to use our custom logger
  foundation.FlutterError.onError = (foundation.FlutterErrorDetails details) {
    // Only log errors that we care about
    if (details.exception.toString().contains('auth') || 
        details.exception.toString().contains('supabase')) {
      AppLogger.error(
        'Flutter error',
        error: details.exception,
        stackTrace: details.stack,
      );
    }
  };

  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Supabase with debug mode
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: true,
  );
  
  runApp(const MencimeterApp());
}

class MencimeterApp extends StatelessWidget {
  const MencimeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mencimeter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
          primary: Colors.blue.shade700,
          secondary: Colors.orangeAccent,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      routerConfig: _router,
    );
  }
}

final _supabaseService = SupabaseService();

// GoRouter configuration
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => AuthWrapper(
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/quiz/:id',
      builder: (context, state) {
        final quizId = state.pathParameters['id']!;
        final sessionCode = state.uri.queryParameters['session'];
        return QuizScreen(
          quizId: quizId,
          sessionCode: sessionCode,
        );
      },
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => AuthWrapper(
        child: const CreateQuizScreen(),
      ),
    ),
    GoRoute(
      path: '/host/:quizId',
      builder: (context, state) {
        final quizId = state.pathParameters['quizId']!;
        return AuthWrapper(
          child: HostQuizScreen(quizId: quizId),
        );
      },
    ),
    GoRoute(
      path: '/join',
      builder: (context, state) => const JoinQuizScreen(),
    ),
    GoRoute(
      path: '/responses/:quizId',
      builder: (context, state) {
        final quizId = state.pathParameters['quizId']!;
        return AuthWrapper(
          child: QuizResponsesScreen(quizId: quizId),
        );
      },
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => AuthWrapper(
        child: const StatsScreen(),
      ),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => AuthWrapper(
        child: const QuizHistoryScreen(),
      ),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => AuthWrapper(
        child: const FavoritesScreen(),
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => AuthWrapper(
        child: ProfileScreen(),
      ),
    ),
  ],
  redirect: (context, state) {
    // Check if the user is authenticated for routes that require auth
    final isAuthenticated = _supabaseService.currentUser != null;
    final isAuthRoute = state.fullPath == '/login';
    final isQuizRoute = state.fullPath?.startsWith('/quiz/') ?? false;
    final isJoinRoute = state.fullPath == '/join';
    
    // If not authenticated and not on login route, redirect to login
    // Allow public quiz routes without authentication
    if (!isAuthenticated && !isAuthRoute && !isQuizRoute && !isJoinRoute) {
      return '/login';
    }
    
    // If authenticated and on login route, redirect to home
    if (isAuthenticated && isAuthRoute) {
      return '/';
    }
    
    // No redirect needed
    return null;
  },
);
