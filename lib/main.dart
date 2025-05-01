import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/create_quiz_screen.dart';
import 'screens/quiz_responses_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// GoRouter configuration
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/quiz/:id',
      builder: (context, state) {
        final quizId = state.pathParameters['id']!;
        return QuizScreen(quizId: quizId);
      },
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => const CreateQuizScreen(),
    ),
    GoRoute(
      path: '/responses/:quizId',
      builder: (context, state) {
        final quizId = state.pathParameters['quizId']!;
        return QuizResponsesScreen(quizId: quizId);
      },
    ),
  ],
);
