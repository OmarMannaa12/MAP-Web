// lib/models/quiz_card.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for DocumentSnapshot

class QuizCard {
  final String id; // Firestore document ID
  final String prompt;
  final String answer;
  final List<String> distractors;
  final String? explanation; // Make nullable
  final String? hint; // Make nullable
  final String cardType;
  final String deckId; // Denormalized info
  final String deckName; // Denormalized info
  final String? category; // Denormalized info
  final String? subCategory; // Denormalized info

  QuizCard({
    required this.id,
    required this.prompt,
    required this.answer,
    required this.distractors,
    this.explanation,
    this.hint,
    required this.cardType,
    required this.deckId,
    required this.deckName,
    this.category,
    this.subCategory,
  });

  factory QuizCard.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {}; // Handle null data

    // Safer list parsing
    List<String> distractorsList = [];
    if (data['distractors'] is List) {
      // Filter out non-strings or nulls if necessary
      distractorsList = List<String>.from(data['distractors']
          .map((item) => item?.toString()) // Convert items to string safely
          .where((item) => item != null)); // Remove nulls
    }

    return QuizCard(
      id: doc.id,
      prompt: data['prompt']?.toString() ?? 'Error: Missing prompt', // Use toString()
      answer: data['answer']?.toString() ?? 'Error: Missing answer',
      distractors: distractorsList, // Use the safely parsed list
      explanation: data['explanation']?.toString(),
      hint: data['hint']?.toString(),
      cardType: data['cardType']?.toString() ?? 'multipleChoice',
      deckId: data['deckId']?.toString() ?? 'unknown_deck',
      deckName: data['deckName']?.toString() ?? 'Unknown Deck',
      category: data['category']?.toString(),
      subCategory: data['subCategory']?.toString(),
    );
  }
}

// --- ChoiceCard definition ---
// This class is used by the UI (GameScreen) to represent the choices
// It's often convenient to keep it with the data model it relates to,
// but it could also live in the GameScreen file if preferred.
class ChoiceCard {
  final String text;
  final bool isCorrect;
  ChoiceCard({required this.text, required this.isCorrect});
}