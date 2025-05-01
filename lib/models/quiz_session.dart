class QuizSession {
  final String id;
  final String quizId;
  final String? hostId;
  final String joinCode;
  final bool isActive;
  final DateTime createdAt;
  
  QuizSession({
    required this.id,
    required this.quizId,
    this.hostId,
    required this.joinCode,
    required this.isActive,
    required this.createdAt,
  });
  
  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      id: json['id'],
      quizId: json['quiz_id'],
      hostId: json['host_id'],
      joinCode: json['join_code'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'host_id': hostId,
      'join_code': joinCode,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 