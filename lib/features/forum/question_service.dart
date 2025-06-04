import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfa/features/auth/auth_provider.dart';
import 'package:pfa/features/forum/answer_model.dart';
import 'package:pfa/features/forum/question_model.dart';
import 'package:provider/provider.dart';

class QuestionService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<QuestionModel>> searchQuestions(
      String query, {
        String? subject,
        String? level,
      }) {
    Query<Map<String, dynamic>> questionsQuery = _firestore.collection('questions');

    if (subject != null && subject.isNotEmpty) {
      questionsQuery = questionsQuery.where('subject', isEqualTo: subject);
    }

    if (level != null && level.isNotEmpty) {
      questionsQuery = questionsQuery.where('level', isEqualTo: level);
    }

    return questionsQuery.snapshots().map((snapshot) {
      final questions = snapshot.docs
          .map((doc) => QuestionModel.fromMap(doc.data(), doc.id))
          .where((question) => question.title.toLowerCase().contains(query.toLowerCase()))
          .toList();

      questions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return questions;
    });
  }

  Stream<QuestionModel?> getQuestionById(String questionId) {
    return _firestore.collection('questions').doc(questionId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return QuestionModel.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  Future<void> postQuestion({
    required String title,
    required String description,
    required String subject,
    required String level,
    required BuildContext context,
  }) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid ?? '';
      final userName = authProvider.user?.displayName ?? 'Utilisateur';

      final questionData = {
        'title': title,
        'description': description,
        'userId': userId,
        'authorName': userName,
        'timestamp': Timestamp.now(),
        'subject': subject,
        'level': level,
        'answersCount': 0,
      };

      await _firestore.collection('questions').add(questionData);
      // Award 5 points for posting a question
      await authProvider.updatePoints(5);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to post question: $e');
    }
  }

  Stream<List<AnswerModel>> getAnswersForQuestion(String questionId) {
    return _firestore
        .collection('questions')
        .doc(questionId)
        .collection('answers')
        .snapshots()
        .map((snapshot) {
      final answers =
      snapshot.docs.map((doc) => AnswerModel.fromMap(doc.data(), doc.id)).toList();
      answers.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return answers;
    });
  }

  Future<void> postAnswer({
    required String questionId,
    required String content,
    required BuildContext context,
  }) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid ?? '';
      final userName = authProvider.user?.displayName ?? 'Utilisateur';

      final answerData = {
        'questionId': questionId,
        'userId': userId,
        'authorName': userName,
        'content': content,
        'timestamp': Timestamp.now(),
        'upvotes': 0,
        'downvotes': 0,
      };

      await _firestore
          .collection('questions')
          .doc(questionId)
          .collection('answers')
          .add(answerData);

      await _firestore.collection('questions').doc(questionId).update({
        'answersCount': FieldValue.increment(1),
      });

      // Award 3 points for posting an answer
      await authProvider.updatePoints(3);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to post answer: $e');
    }
  }
}