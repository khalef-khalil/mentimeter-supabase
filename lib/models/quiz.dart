class Quiz {
  final String id;
  final String title;
  final String? userId;
  final DateTime createdAt;
  final bool active;
  
  Quiz({
    required this.id,
    required this.title,
    this.userId,
    required this.createdAt,
    required this.active,
  });
  
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      active: json['active'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'active': active,
    };
  }
} 