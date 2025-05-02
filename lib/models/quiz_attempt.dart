class QuizAttempt {
  final String id;
  final String quizId;
  final String userId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int correctAnswers;
  final int totalQuestions;
  final String quizTitle;
  
  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.startedAt,
    this.completedAt,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.quizTitle,
  });
  
  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'],
      quizId: json['quiz_id'],
      userId: json['user_id'],
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      correctAnswers: json['correct_answers'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      quizTitle: json['quiz_title'] ?? 'Untitled Quiz',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'user_id': userId,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'correct_answers': correctAnswers,
      'total_questions': totalQuestions,
      'quiz_title': quizTitle,
    };
  }
  
  double get score {
    if (totalQuestions == 0) return 0;
    return correctAnswers / totalQuestions;
  }
  
  String get scoreFormatted {
    return '${(score * 100).toStringAsFixed(0)}%';
  }
  
  bool get isCompleted => completedAt != null;
} 