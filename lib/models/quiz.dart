enum QuizDifficulty {
  easy,
  medium,
  hard,
}

enum QuizCategory {
  general,
  science,
  history,
  geography,
  entertainment,
  sports,
  technology,
}

class Quiz {
  final String id;
  final String title;
  final String? userId;
  final DateTime createdAt;
  final bool active;
  final QuizDifficulty difficulty;
  final QuizCategory category;
  final bool isFavorite;
  
  Quiz({
    required this.id,
    required this.title,
    this.userId,
    required this.createdAt,
    required this.active,
    this.difficulty = QuizDifficulty.medium,
    this.category = QuizCategory.general,
    this.isFavorite = false,
  });
  
  factory Quiz.fromJson(Map<String, dynamic> json) {
    QuizDifficulty difficultyValue = QuizDifficulty.medium;
    if (json['difficulty'] != null) {
      switch (json['difficulty']) {
        case 'easy':
          difficultyValue = QuizDifficulty.easy;
          break;
        case 'medium':
          difficultyValue = QuizDifficulty.medium;
          break;
        case 'hard':
          difficultyValue = QuizDifficulty.hard;
          break;
      }
    }
    
    QuizCategory categoryValue = QuizCategory.general;
    if (json['category'] != null) {
      switch (json['category']) {
        case 'general':
          categoryValue = QuizCategory.general;
          break;
        case 'science':
          categoryValue = QuizCategory.science;
          break;
        case 'history':
          categoryValue = QuizCategory.history;
          break;
        case 'geography':
          categoryValue = QuizCategory.geography;
          break;
        case 'entertainment':
          categoryValue = QuizCategory.entertainment;
          break;
        case 'sports':
          categoryValue = QuizCategory.sports;
          break;
        case 'technology':
          categoryValue = QuizCategory.technology;
          break;
      }
    }
    
    return Quiz(
      id: json['id'],
      title: json['title'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      active: json['active'] ?? false,
      difficulty: difficultyValue,
      category: categoryValue,
      isFavorite: json['is_favorite'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    String difficultyString;
    switch (difficulty) {
      case QuizDifficulty.easy:
        difficultyString = 'easy';
        break;
      case QuizDifficulty.medium:
        difficultyString = 'medium';
        break;
      case QuizDifficulty.hard:
        difficultyString = 'hard';
        break;
    }
    
    String categoryString;
    switch (category) {
      case QuizCategory.general:
        categoryString = 'general';
        break;
      case QuizCategory.science:
        categoryString = 'science';
        break;
      case QuizCategory.history:
        categoryString = 'history';
        break;
      case QuizCategory.geography:
        categoryString = 'geography';
        break;
      case QuizCategory.entertainment:
        categoryString = 'entertainment';
        break;
      case QuizCategory.sports:
        categoryString = 'sports';
        break;
      case QuizCategory.technology:
        categoryString = 'technology';
        break;
    }
    
    return {
      'id': id,
      'title': title,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'active': active,
      'difficulty': difficultyString,
      'category': categoryString,
    };
  }
  
  Quiz copyWith({
    String? id,
    String? title,
    String? userId,
    DateTime? createdAt,
    bool? active,
    QuizDifficulty? difficulty,
    QuizCategory? category,
    bool? isFavorite,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
} 