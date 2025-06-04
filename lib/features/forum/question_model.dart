import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String title;
  final String description;
  final String userId;
  final String authorName;
  final DateTime timestamp;
  final String subject;
  final String level;
  final int views;
  final int answersCount;

  QuestionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userId,
    required this.authorName,
    required this.timestamp,
    required this.subject,
    required this.level,
    required this.views,
    required this.answersCount,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> data, String id) {
    String convertToString(dynamic value) {
      if (value is String) {
        return value;
      } else if (value is List<dynamic> && value.isNotEmpty) {
        return value.first.toString();
      }
      return '';
    }

    return QuestionModel(
      id: id,
      title: convertToString(data['title']),
      description: convertToString(data['description']),
      userId: convertToString(data['userId']),
      authorName: convertToString(data['authorName']).isNotEmpty
          ? convertToString(data['authorName'])
          : 'Ghaida',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      subject: convertToString(data['subject']).isNotEmpty
          ? convertToString(data['subject'])
          : 'Other',
      level: convertToString(data['level']).isNotEmpty
          ? convertToString(data['level'])
          : '1st Year',
      views: (data['views'] as num?)?.toInt() ?? 0,
      answersCount: (data['answersCount'] as num?)?.toInt() ?? 0,
    );
  }
}