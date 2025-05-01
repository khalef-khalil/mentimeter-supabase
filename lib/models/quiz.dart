class Quiz {
  final String id;
  final String title;
  final String? createdBy;
  final DateTime createdAt;
  final bool active;
  
  Quiz({
    required this.id,
    required this.title,
    this.createdBy,
    required this.createdAt,
    required this.active,
  });
  
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      active: json['active'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'active': active,
    };
  }
} 