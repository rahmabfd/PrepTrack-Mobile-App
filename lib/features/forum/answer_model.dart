import 'package:cloud_firestore/cloud_firestore.dart';

class AnswerModel {
  final String id;
  final String questionId;
  final String userId;
  final String authorName;
  final String content;
  final DateTime timestamp;
  final int upvotes;
  final int downvotes;

  AnswerModel({
    required this.id,
    required this.questionId,
    required this.userId,
    required this.authorName,
    required this.content,
    required this.timestamp,
    this.upvotes = 0,
    this.downvotes = 0,
  });

  factory AnswerModel.fromMap(Map<String, dynamic> data, String id) {
    return AnswerModel(
      id: id,
      questionId: data['questionId'] ?? '',
      userId: data['userId'] ?? '',
      authorName: data['authorName'] ?? 'Utilisateur',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      upvotes: (data['upvotes'] as num?)?.toInt() ?? 0,
      downvotes: (data['downvotes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'userId': userId,
      'authorName': authorName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'upvotes': upvotes,
      'downvotes': downvotes,
    };
  }
}