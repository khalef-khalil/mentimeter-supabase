import 'package:flutter/material.dart';
import '../models/question.dart';

class WordCloudQuestion extends StatefulWidget {
  final Question question;
  final Function(Map<String, dynamic>) onSubmit;
  
  const WordCloudQuestion({
    super.key,
    required this.question,
    required this.onSubmit,
  });

  @override
  State<WordCloudQuestion> createState() => _WordCloudQuestionState();
}

class _WordCloudQuestionState extends State<WordCloudQuestion> {
  final TextEditingController _responseController = TextEditingController();
  
  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }
  
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
            TextFormField(
              controller: _responseController,
              decoration: const InputDecoration(
                labelText: 'Your answer',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
              textInputAction: TextInputAction.done,
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _responseController.text.trim().isEmpty
                    ? null
                    : () {
                        widget.onSubmit({
                          'text': _responseController.text.trim(),
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