class QuizResponse {
  final String id;
  final String questionId;
  final Map<String, dynamic> responseData;
  final DateTime createdAt;
  
  QuizResponse({
    required this.id,
    required this.questionId,
    required this.responseData,
    required this.createdAt,
  });
  
  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    return QuizResponse(
      id: json['id'],
      questionId: json['question_id'],
      responseData: json['response_data'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'response_data': responseData,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 