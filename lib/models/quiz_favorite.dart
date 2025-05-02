class QuizFavorite {
  final String id;
  final String quizId;
  final String userId;
  final DateTime createdAt;
  
  QuizFavorite({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.createdAt,
  });
  
  factory QuizFavorite.fromJson(Map<String, dynamic> json) {
    return QuizFavorite(
      id: json['id'],
      quizId: json['quiz_id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 