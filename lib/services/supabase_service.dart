import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz.dart';
import '../models/question.dart';
import '../models/response.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Quiz methods
  Future<List<Quiz>> getQuizzes() async {
    final response = await _client.from('quizzes').select().order('created_at');
    return (response as List).map((json) => Quiz.fromJson(json)).toList();
  }
  
  Future<List<Quiz>> getActiveQuizzes() async {
    final response = await _client.from('quizzes').select().eq('active', true).order('created_at');
    return (response as List).map((json) => Quiz.fromJson(json)).toList();
  }
  
  Future<Quiz> getQuiz(String id) async {
    final response = await _client.from('quizzes').select().eq('id', id).single();
    return Quiz.fromJson(response);
  }
  
  Future<Quiz> createQuiz(String title, {String? createdBy}) async {
    final response = await _client.from('quizzes').insert({
      'title': title,
      'created_by': createdBy,
      'active': false,
    }).select().single();
    
    return Quiz.fromJson(response);
  }
  
  Future<void> updateQuizActive(String id, bool active) async {
    await _client.from('quizzes').update({'active': active}).eq('id', id);
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
    int position = 0,
  }) async {
    Map<String, dynamic> data = {
      'quiz_id': quizId,
      'question_text': questionText,
      'question_type': questionType == QuestionType.multipleChoice ? 'multiple_choice' : 'word_cloud',
      'position': position,
    };
    
    if (options != null && questionType == QuestionType.multipleChoice) {
      data['options'] = {'choices': options};
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
} 