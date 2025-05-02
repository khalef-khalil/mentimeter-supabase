enum QuestionType {
  multipleChoice,
  wordCloud
}

class Question {
  final String id;
  final String quizId;
  final String questionText;
  final QuestionType questionType;
  final List<String>? options;
  final String? correctOption;
  final DateTime createdAt;
  final int position;
  final int timerSeconds;
  
  Question({
    required this.id,
    required this.quizId,
    required this.questionText,
    required this.questionType,
    this.options,
    this.correctOption,
    required this.createdAt,
    required this.position,
    this.timerSeconds = 30,
  });
  
  factory Question.fromJson(Map<String, dynamic> json) {
    QuestionType type;
    switch (json['question_type']) {
      case 'multiple_choice':
        type = QuestionType.multipleChoice;
        break;
      case 'word_cloud':
        type = QuestionType.wordCloud;
        break;
      default:
        type = QuestionType.multipleChoice;
    }
    
    List<String>? optionsList;
    String? correctOptionValue;
    if (json['options'] != null) {
      final options = json['options'] as Map<String, dynamic>;
      if (options.containsKey('choices')) {
        optionsList = List<String>.from(options['choices']);
      }
      if (options.containsKey('correct_option')) {
        correctOptionValue = options['correct_option'] as String;
      }
    }
    
    return Question(
      id: json['id'],
      quizId: json['quiz_id'],
      questionText: json['question_text'],
      questionType: type,
      options: optionsList,
      correctOption: correctOptionValue,
      createdAt: DateTime.parse(json['created_at']),
      position: json['position'] ?? 0,
      timerSeconds: json['timer_seconds'] ?? 30,
    );
  }
  
  Map<String, dynamic> toJson() {
    String typeString;
    switch (questionType) {
      case QuestionType.multipleChoice:
        typeString = 'multiple_choice';
        break;
      case QuestionType.wordCloud:
        typeString = 'word_cloud';
        break;
    }
    
    Map<String, dynamic> json = {
      'id': id,
      'quiz_id': quizId,
      'question_text': questionText,
      'question_type': typeString,
      'created_at': createdAt.toIso8601String(),
      'position': position,
      'timer_seconds': timerSeconds,
    };
    
    if (options != null && questionType == QuestionType.multipleChoice) {
      final optionsJson = <String, dynamic>{
        'choices': options
      };
      if (correctOption != null) {
        optionsJson['correct_option'] = correctOption;
      }
      json['options'] = optionsJson;
    }
    
    return json;
  }
} 