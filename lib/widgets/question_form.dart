import 'package:flutter/material.dart';
import '../models/question.dart';

class QuestionForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onChanged;
  final VoidCallback onRemove;

  const QuestionForm({
    super.key,
    required this.initialData,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<QuestionForm> createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  late TextEditingController _questionController;
  late QuestionType _questionType;
  late List<TextEditingController> _optionControllers;
  late int _timerSeconds;
  String? _correctOption;
  
  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.initialData['text']);
    _questionType = widget.initialData['type'] ?? QuestionType.multipleChoice;
    _timerSeconds = widget.initialData['timerSeconds'] ?? 30;
    _optionControllers = (widget.initialData['options'] as List<dynamic>? ?? [])
        .map((option) => TextEditingController(text: option.toString()))
        .toList();
    _correctOption = widget.initialData['correctOption'];
    
    if (_optionControllers.isEmpty && _questionType == QuestionType.multipleChoice) {
      _optionControllers = [TextEditingController(), TextEditingController()];
    }
  }
  
  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  void _notifyChange() {
    final data = {
      'text': _questionController.text,
      'type': _questionType,
      'options': _optionControllers.map((c) => c.text).toList(),
      'timerSeconds': _timerSeconds,
      'correctOption': _correctOption,
    };
    widget.onChanged(data);
  }
  
  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
    _notifyChange();
  }
  
  void _removeOption(int index) {
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
      
      // If the removed option was the correct answer, reset the correct answer
      if (_correctOption == _optionControllers[index].text) {
        _correctOption = null;
      }
    });
    _notifyChange();
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _notifyChange(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a question';
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onRemove,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<QuestionType>(
                    value: _questionType,
                    decoration: const InputDecoration(
                      labelText: 'Question Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: QuestionType.multipleChoice,
                        child: Text('Multiple Choice'),
                      ),
                      DropdownMenuItem(
                        value: QuestionType.wordCloud,
                        child: Text('Word Cloud'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _questionType = value!;
                      });
                      _notifyChange();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<int>(
                    value: _timerSeconds,
                    decoration: const InputDecoration(
                      labelText: 'Timer (seconds)',
                      border: OutlineInputBorder(),
                    ),
                    items: [15, 30, 45, 60, 90, 120].map((seconds) {
                      return DropdownMenuItem(
                        value: seconds,
                        child: Text('$seconds sec'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _timerSeconds = value!;
                      });
                      _notifyChange();
                    },
                  ),
                ),
              ],
            ),
            if (_questionType == QuestionType.multipleChoice) ...[
              const SizedBox(height: 16),
              const Text(
                'Options',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(_optionControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _optionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Option ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) => _notifyChange(),
                          validator: (value) {
                            if (_questionType == QuestionType.multipleChoice && 
                                (value == null || value.trim().isEmpty)) {
                              return 'Please enter an option';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: _optionControllers.length > 2
                            ? () => _removeOption(index)
                            : null,
                        color: Colors.red,
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _correctOption,
                decoration: const InputDecoration(
                  labelText: 'Correct Answer',
                  border: OutlineInputBorder(),
                  hintText: 'Select the correct answer',
                ),
                items: _optionControllers.map((controller) {
                  final option = controller.text;
                  return DropdownMenuItem(
                    value: option.isNotEmpty ? option : null,
                    child: Text(option.isNotEmpty ? option : 'No option selected'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _correctOption = value;
                  });
                  _notifyChange();
                },
                validator: (value) {
                  if (_questionType == QuestionType.multipleChoice && value == null) {
                    return 'Please select the correct answer';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
} 