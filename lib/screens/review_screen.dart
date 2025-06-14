// screens/review_screen.dart
import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mistakes = [
      {'question': '2 + 2 = 5', 'correctAnswer': '4'},
      {'question': 'Capital of France is London', 'correctAnswer': 'Paris'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Review Mistakes')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: mistakes.length,
        itemBuilder: (context, index) {
          return MistakeCard(
            question: mistakes[index]['question']!,
            correctAnswer: mistakes[index]['correctAnswer']!,
          );
        },
      ),
    );
  }
}

class MistakeCard extends StatelessWidget {
  final String question;
  final String correctAnswer;

  const MistakeCard({
    super.key,
    required this.question,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade100,
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Correct Answer: $correctAnswer'),
          ],
        ),
      ),
    );
  }
}
