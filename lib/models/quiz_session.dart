class QuizSession {
  final String id;
  final String quizId;
  final String? hostId;
  final String joinCode;
  final bool isActive;
  final bool hasStarted;
  final DateTime createdAt;
  
  QuizSession({
    required this.id,
    required this.quizId,
    this.hostId,
    required this.joinCode,
    required this.isActive,
    this.hasStarted = false,
    required this.createdAt,
  });
  
  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      id: json['id'],
      quizId: json['quiz_id'],
      hostId: json['host_id'],
      joinCode: json['join_code'],
      isActive: json['is_active'] ?? true,
      hasStarted: json['has_started'] ?? false,
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
      'has_started': hasStarted,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 