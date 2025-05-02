import 'package:flutter/material.dart';
import '../models/question.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  final Question question;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback? onNext;
  
  const MultipleChoiceQuestion({
    super.key,
    required this.question,
    required this.onSubmit,
    this.onNext,
  });

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  String? _selectedOption;
  bool _hasSubmitted = false;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question.questionText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...widget.question.options?.map((option) {
              final isCorrect = widget.question.correctOption == option;
              final isSelected = _selectedOption == option;
              
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _selectedOption,
                onChanged: _hasSubmitted ? null : (value) {
                  setState(() {
                    _selectedOption = value;
                  });
                },
                tileColor: _hasSubmitted && isCorrect
                    ? Colors.green.withOpacity(0.2)
                    : _hasSubmitted && isSelected
                        ? Colors.red.withOpacity(0.2)
                        : null,
                subtitle: _hasSubmitted && isCorrect
                    ? const Text('Correct Answer', style: TextStyle(color: Colors.green))
                    : _hasSubmitted && isSelected && !isCorrect
                        ? const Text('Your Answer', style: TextStyle(color: Colors.red))
                        : null,
              );
            }).toList() ?? [],
            const Spacer(),
            if (_hasSubmitted)
              Center(
                child: Text(
                  _selectedOption == widget.question.correctOption
                      ? 'You got it right! 🎉'
                      : 'Correct answer: ${widget.question.correctOption}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _selectedOption == widget.question.correctOption
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: _hasSubmitted
                  ? ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Next Question'),
                    )
                  : ElevatedButton(
                      onPressed: _selectedOption == null
                          ? null
                          : () {
                              setState(() {
                                _hasSubmitted = true;
                              });
                              widget.onSubmit({
                                'selected_option': _selectedOption,
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Submit'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 