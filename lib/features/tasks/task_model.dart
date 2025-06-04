import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final String userId;
  final DateTime? dueDate;
  final String subject;
  final int priority;
  final String? notes;
  final Color color;
  final String category;
  final bool isLocked; // New property

  Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.userId,
    this.dueDate,
    required this.subject,
    required this.priority,
    this.notes,
    required this.color,
    required this.category,
    this.isLocked = false, // Default to false
  });

  // Convert Task to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'userId': userId,
      'dueDate': dueDate?.toIso8601String(),
      'subject': subject,
      'priority': priority,
      'notes': notes,
      'color': color.value,
      'category': category,
      'isLocked': isLocked, // Add to map
    };
  }

  // Create Task from Firestore data
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      userId: map['userId'] ?? '',
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      subject: map['subject'] ?? 'General',
      priority: (map['priority'] ?? 2).toInt(),
      notes: map['notes'],
      color: Color(map['color'] ?? 0xFFE3F2FD),
      category: map['category'] ?? 'TD',
      isLocked: map['isLocked'] ?? false, // Read from map
    );
  }

  // Updated copyWith method
  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? userId,
    DateTime? dueDate,
    String? subject,
    int? priority,
    String? notes,
    Color? color,
    String? category,
    bool? isLocked,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
      dueDate: dueDate ?? this.dueDate,
      subject: subject ?? this.subject,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      color: color ?? this.color,
      category: category ?? this.category,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}