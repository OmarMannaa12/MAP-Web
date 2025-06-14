// screens/hot_mode_screen.dart
import 'package:flutter/material.dart';

class HotModeScreen extends StatefulWidget {
  const HotModeScreen({super.key});

  @override
  State<HotModeScreen> createState() => _HotModeScreenState();
}

class _HotModeScreenState extends State<HotModeScreen> {
  int _mistakesRemaining = 3;
  int _currentQuestionIndex = 0;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'What is 2 + 2?',
      'options': ['3', '4', '5'],
      'correctIndex': 1,
    },
    {
      'question': 'Capital of France?',
      'options': ['London', 'Paris', 'Berlin'],
      'correctIndex': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hot Mode'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text('Mistakes Left: $_mistakesRemaining'),
              backgroundColor: Colors.red.shade100,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              questions[_currentQuestionIndex]['question'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ..._buildOptions(),
            const Spacer(),
            if (_mistakesRemaining <= 0)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Return to Menu'),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptions() {
    return (questions[_currentQuestionIndex]['options'] as List<String>)
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key;
      final option = entry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ElevatedButton(
          onPressed: _mistakesRemaining > 0 ? () => _checkAnswer(index) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.black,
          ),
          child: Text(option),
        ),
      );
    }).toList();
  }

  void _checkAnswer(int selectedIndex) {
    final correctIndex = questions[_currentQuestionIndex]['correctIndex'];

    if (selectedIndex != correctIndex) {
      setState(() => _mistakesRemaining--);
    }

    if (_mistakesRemaining > 0) {
      setState(() {
        _currentQuestionIndex = (_currentQuestionIndex + 1) % questions.length;
      });
    }
  }
}