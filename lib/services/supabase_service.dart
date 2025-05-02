import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import '../models/response.dart';
import '../models/quiz_session.dart';
import '../models/quiz_attempt.dart';
import '../models/quiz_favorite.dart';
import '../utils/logger.dart';
import '../main.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Authentication methods
  User? get currentUser => _client.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  Future<AuthResponse> signUp({
    required String email, 
    required String password,
  }) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
    } catch (e) {
      AppLogger.error('Signup error', error: e);
      rethrow;
    }
  }
  
  Future<AuthResponse> signIn({
    required String email, 
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      AppLogger.error('Login error', error: e);
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      AppLogger.error('Sign out error', error: e);
      rethrow;
    }
  }
  
  // Quiz methods
  Future<List<Quiz>> getQuizzes() async {
    final response = await _client.from('quizzes').select().order('created_at');
    return (response as List).map((json) => Quiz.fromJson(json)).toList();
  }
  
  Future<List<Quiz>> getUserQuizzes({
    QuizDifficulty? difficulty,
    QuizCategory? category,
  }) async {
    if (currentUser == null) return [];
    
    var query = _client
        .from('quizzes')
        .select()
        .eq('user_id', currentUser!.id);
    
    if (difficulty != null) {
      String difficultyStr;
      switch (difficulty) {
        case QuizDifficulty.easy:
          difficultyStr = 'easy';
          break;
        case QuizDifficulty.medium:
          difficultyStr = 'medium';
          break;
        case QuizDifficulty.hard:
          difficultyStr = 'hard';
          break;
      }
      query = query.eq('difficulty', difficultyStr);
    }
    
    if (category != null) {
      String categoryStr;
      switch (category) {
        case QuizCategory.general:
          categoryStr = 'general';
          break;
        case QuizCategory.science:
          categoryStr = 'science';
          break;
        case QuizCategory.history:
          categoryStr = 'history';
          break;
        case QuizCategory.geography:
          categoryStr = 'geography';
          break;
        case QuizCategory.entertainment:
          categoryStr = 'entertainment';
          break;
        case QuizCategory.sports:
          categoryStr = 'sports';
          break;
        case QuizCategory.technology:
          categoryStr = 'technology';
          break;
      }
      query = query.eq('category', categoryStr);
    }
    
    final response = await query.order('created_at');
    final quizzes = (response as List).map((json) => Quiz.fromJson(json)).toList();
    
    // Check if quizzes are favorites
    final favorites = await getUserFavorites();
    final favoriteIds = favorites.map((f) => f.quizId).toSet();
    
    return quizzes.map((quiz) {
      if (favoriteIds.contains(quiz.id)) {
        return quiz.copyWith(isFavorite: true);
      }
      return quiz;
    }).toList();
  }
  
  Future<List<Quiz>> getActiveQuizzes({
    QuizDifficulty? difficulty,
    QuizCategory? category,
  }) async {
    var query = _client.from('quizzes').select().eq('active', true);
    
    if (difficulty != null) {
      String difficultyStr;
      switch (difficulty) {
        case QuizDifficulty.easy:
          difficultyStr = 'easy';
          break;
        case QuizDifficulty.medium:
          difficultyStr = 'medium';
          break;
        case QuizDifficulty.hard:
          difficultyStr = 'hard';
          break;
      }
      query = query.eq('difficulty', difficultyStr);
    }
    
    if (category != null) {
      String categoryStr;
      switch (category) {
        case QuizCategory.general:
          categoryStr = 'general';
          break;
        case QuizCategory.science:
          categoryStr = 'science';
          break;
        case QuizCategory.history:
          categoryStr = 'history';
          break;
        case QuizCategory.geography:
          categoryStr = 'geography';
          break;
        case QuizCategory.entertainment:
          categoryStr = 'entertainment';
          break;
        case QuizCategory.sports:
          categoryStr = 'sports';
          break;
        case QuizCategory.technology:
          categoryStr = 'technology';
          break;
      }
      query = query.eq('category', categoryStr);
    }
    
    final response = await query.order('created_at');
    final quizzes = (response as List).map((json) => Quiz.fromJson(json)).toList();
    
    // Check if quizzes are favorites for logged-in users
    if (currentUser != null) {
      final favorites = await getUserFavorites();
      final favoriteIds = favorites.map((f) => f.quizId).toSet();
      
      return quizzes.map((quiz) {
        if (favoriteIds.contains(quiz.id)) {
          return quiz.copyWith(isFavorite: true);
        }
        return quiz;
      }).toList();
    }
    
    return quizzes;
  }
  
  Future<Quiz> getQuiz(String id) async {
    final response = await _client.from('quizzes').select().eq('id', id).single();
    final quiz = Quiz.fromJson(response);
    
    if (currentUser != null) {
      // Check if quiz is a favorite
      final favorites = await getUserFavorites();
      final isFavorite = favorites.any((f) => f.quizId == id);
      return quiz.copyWith(isFavorite: isFavorite);
    }
    
    return quiz;
  }
  
  Future<Quiz> createQuiz(
    String title, {
    QuizDifficulty difficulty = QuizDifficulty.medium,
    QuizCategory category = QuizCategory.general,
  }) async {
    if (currentUser == null) {
      throw Exception('User must be logged in to create a quiz');
    }
    
    String difficultyStr;
    switch (difficulty) {
      case QuizDifficulty.easy:
        difficultyStr = 'easy';
        break;
      case QuizDifficulty.medium:
        difficultyStr = 'medium';
        break;
      case QuizDifficulty.hard:
        difficultyStr = 'hard';
        break;
    }
    
    String categoryStr;
    switch (category) {
      case QuizCategory.general:
        categoryStr = 'general';
        break;
      case QuizCategory.science:
        categoryStr = 'science';
        break;
      case QuizCategory.history:
        categoryStr = 'history';
        break;
      case QuizCategory.geography:
        categoryStr = 'geography';
        break;
      case QuizCategory.entertainment:
        categoryStr = 'entertainment';
        break;
      case QuizCategory.sports:
        categoryStr = 'sports';
        break;
      case QuizCategory.technology:
        categoryStr = 'technology';
        break;
    }
    
    final response = await _client.from('quizzes').insert({
      'title': title,
      'user_id': currentUser!.id,
      'active': false,
      'difficulty': difficultyStr,
      'category': categoryStr,
    }).select().single();
    
    return Quiz.fromJson(response);
  }
  
  Future<void> updateQuizActive(String id, bool active) async {
    await _client.from('quizzes').update({'active': active}).eq('id', id);
  }
  
  Future<void> deleteQuiz(String id) async {
    if (currentUser == null) {
      throw Exception('User must be logged in to delete a quiz');
    }
    
    await _client.from('quizzes')
      .delete()
      .eq('id', id)
      .eq('user_id', currentUser!.id);
  }
  
  // Question methods
  Future<List<Question>> getQuestionsForQuiz(String quizId) async {
    final response = await _client.from('questions').select().eq('quiz_id', quizId).order('position');
    return (response as List).map((json) => Question.fromJson(json)).toList();
  }
  
  Future<Question> createQuestion({
    required String quizId,
    required String questionText,
    required QuestionType questionType,
    List<String>? options,
    String? correctOption,
    int position = 0,
    int timerSeconds = 30,
  }) async {
    Map<String, dynamic> data = {
      'quiz_id': quizId,
      'question_text': questionText,
      'question_type': questionType == QuestionType.multipleChoice ? 'multiple_choice' : 'word_cloud',
      'position': position,
      'timer_seconds': timerSeconds,
    };
    
    if (options != null && questionType == QuestionType.multipleChoice) {
      final optionsData = <String, dynamic>{
        'choices': options
      };
      if (correctOption != null) {
        optionsData['correct_option'] = correctOption;
      }
      data['options'] = optionsData;
    }
    
    final response = await _client.from('questions').insert(data).select().single();
    return Question.fromJson(response);
  }
  
  // Response methods
  Future<List<QuizResponse>> getResponsesForQuestion(String questionId) async {
    final response = await _client.from('responses').select().eq('question_id', questionId).order('created_at');
    return (response as List).map((json) => QuizResponse.fromJson(json)).toList();
  }
  
  Future<QuizResponse> submitResponse(String questionId, Map<String, dynamic> responseData) async {
    final response = await _client.from('responses').insert({
      'question_id': questionId,
      'response_data': responseData,
    }).select().single();
    
    return QuizResponse.fromJson(response);
  }
  
  // Quiz Session methods
  Future<QuizSession> createQuizSession(String quizId) async {
    if (currentUser == null) {
      throw Exception('User must be logged in to host a quiz');
    }
    
    // Call the database function to generate a join code
    final codeResponse = await _client.rpc('generate_join_code');
    final joinCode = codeResponse as String;
    
    final response = await _client.from('quiz_sessions').insert({
      'quiz_id': quizId,
      'host_id': currentUser!.id,
      'join_code': joinCode,
      'is_active': true,
    }).select().single();
    
    return QuizSession.fromJson(response);
  }
  
  Future<QuizSession> getSessionByCode(String joinCode) async {
    final response = await _client
        .from('quiz_sessions')
        .select()
        .eq('join_code', joinCode)
        .eq('is_active', true)
        .single();
    
    return QuizSession.fromJson(response);
  }
  
  Future<List<QuizSession>> getUserActiveSessions() async {
    if (currentUser == null) return [];
    
    final response = await _client
        .from('quiz_sessions')
        .select()
        .eq('host_id', currentUser!.id)
        .eq('is_active', true)
        .order('created_at');
    
    return (response as List).map((json) => QuizSession.fromJson(json)).toList();
  }
  
  Future<void> endQuizSession(String sessionId) async {
    await _client
        .from('quiz_sessions')
        .update({'is_active': false})
        .eq('id', sessionId)
        .eq('host_id', currentUser!.id);
  }
  
  // Quiz Attempts methods
  Future<QuizAttempt> startQuizAttempt(String quizId, String quizTitle, int totalQuestions) async {
    if (currentUser == null) {
      throw Exception('User must be logged in to track quiz attempts');
    }
    
    final response = await _client.from('quiz_attempts').insert({
      'quiz_id': quizId,
      'user_id': currentUser!.id,
      'total_questions': totalQuestions,
      'quiz_title': quizTitle,
    }).select().single();
    
    return QuizAttempt.fromJson(response);
  }
  
  Future<void> completeQuizAttempt(String attemptId, int correctAnswers) async {
    await _client.from('quiz_attempts').update({
      'completed_at': DateTime.now().toIso8601String(),
      'correct_answers': correctAnswers,
    }).eq('id', attemptId);
  }
  
  Future<List<QuizAttempt>> getUserQuizAttempts() async {
    if (currentUser == null) return [];
    
    final response = await _client
        .from('quiz_attempts')
        .select()
        .eq('user_id', currentUser!.id)
        .order('started_at', ascending: false);
    
    return (response as List).map((json) => QuizAttempt.fromJson(json)).toList();
  }
  
  Future<Map<String, dynamic>> getUserStats() async {
    if (currentUser == null) {
      return {
        'total_attempts': 0,
        'completed_attempts': 0,
        'avg_score': 0.0,
        'highest_score': 0.0,
      };
    }
    
    final attempts = await getUserQuizAttempts();
    
    if (attempts.isEmpty) {
      return {
        'total_attempts': 0,
        'completed_attempts': 0,
        'avg_score': 0.0,
        'highest_score': 0.0,
      };
    }
    
    final completedAttempts = attempts.where((a) => a.isCompleted).toList();
    
    double avgScore = 0;
    double highestScore = 0;
    
    if (completedAttempts.isNotEmpty) {
      avgScore = completedAttempts.map((a) => a.score).reduce((a, b) => a + b) / completedAttempts.length;
      highestScore = completedAttempts.map((a) => a.score).reduce((a, b) => a > b ? a : b);
    }
    
    return {
      'total_attempts': attempts.length,
      'completed_attempts': completedAttempts.length,
      'avg_score': avgScore,
      'highest_score': highestScore,
    };
  }
  
  // Favorites methods
  Future<List<QuizFavorite>> getUserFavorites() async {
    if (currentUser == null) return [];
    
    final response = await _client
        .from('quiz_favorites')
        .select()
        .eq('user_id', currentUser!.id);
    
    return (response as List).map((json) => QuizFavorite.fromJson(json)).toList();
  }
  
  Future<List<Quiz>> getFavoriteQuizzes({
    QuizDifficulty? difficulty,
    QuizCategory? category,
  }) async {
    if (currentUser == null) return [];
    
    var query = '''
      user_id=eq.${currentUser!.id}
    ''';
    
    if (difficulty != null) {
      String difficultyStr;
      switch (difficulty) {
        case QuizDifficulty.easy:
          difficultyStr = 'easy';
          break;
        case QuizDifficulty.medium:
          difficultyStr = 'medium';
          break;
        case QuizDifficulty.hard:
          difficultyStr = 'hard';
          break;
      }
      query += '&difficulty=eq.$difficultyStr';
    }
    
    if (category != null) {
      String categoryStr;
      switch (category) {
        case QuizCategory.general:
          categoryStr = 'general';
          break;
        case QuizCategory.science:
          categoryStr = 'science';
          break;
        case QuizCategory.history:
          categoryStr = 'history';
          break;
        case QuizCategory.geography:
          categoryStr = 'geography';
          break;
        case QuizCategory.entertainment:
          categoryStr = 'entertainment';
          break;
        case QuizCategory.sports:
          categoryStr = 'sports';
          break;
        case QuizCategory.technology:
          categoryStr = 'technology';
          break;
      }
      query += '&category=eq.$categoryStr';
    }
    
    final response = await _client
        .from('user_favorites_view')
        .select()
        .eq('user_id', currentUser!.id);
    
    final List<Quiz> quizzes = [];
    for (final item in response) {
      final quiz = Quiz(
        id: item['quiz_id'],
        title: item['quiz_title'],
        createdAt: DateTime.parse(item['quiz_created_at']),
        active: true, // These are always active since they are public
        difficulty: _parseDifficulty(item['difficulty']),
        category: _parseCategory(item['category']),
        isFavorite: true,
      );
      quizzes.add(quiz);
    }
    
    return quizzes;
  }
  
  QuizDifficulty _parseDifficulty(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return QuizDifficulty.easy;
      case 'hard':
        return QuizDifficulty.hard;
      default:
        return QuizDifficulty.medium;
    }
  }
  
  QuizCategory _parseCategory(String category) {
    switch (category) {
      case 'science':
        return QuizCategory.science;
      case 'history':
        return QuizCategory.history;
      case 'geography':
        return QuizCategory.geography;
      case 'entertainment':
        return QuizCategory.entertainment;
      case 'sports':
        return QuizCategory.sports;
      case 'technology':
        return QuizCategory.technology;
      default:
        return QuizCategory.general;
    }
  }
  
  Future<void> addFavorite(String quizId) async {
    if (currentUser == null) {
      throw Exception('User must be logged in to add a favorite');
    }
    
    await _client.from('quiz_favorites').insert({
      'quiz_id': quizId,
      'user_id': currentUser!.id,
    });
  }
  
  Future<void> removeFavorite(String quizId) async {
    if (currentUser == null) {
      throw Exception('User must be logged in to remove a favorite');
    }
    
    await _client.from('quiz_favorites')
      .delete()
      .eq('quiz_id', quizId)
      .eq('user_id', currentUser!.id);
  }
  
  Future<void> toggleFavorite(String quizId, bool isFavorite) async {
    if (isFavorite) {
      await removeFavorite(quizId);
    } else {
      await addFavorite(quizId);
    }
  }
} 