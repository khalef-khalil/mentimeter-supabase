import 'package:flutter/material.dart';
import '../models/question.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  final Question question;
  final Function(Map<String, dynamic>) onSubmit;
  
  const MultipleChoiceQuestion({
    super.key,
    required this.question,
    required this.onSubmit,
  });

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  String? _selectedOption;
  
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
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value;
                  });
                },
              );
            }).toList() ?? [],
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _selectedOption == null
                    ? null
                    : () {
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