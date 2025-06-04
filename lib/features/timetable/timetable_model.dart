import 'package:flutter/material.dart';

class TimetableEntry {
  final String id;
  final String subject;
  final String module;
  final String day;
  final String startTime;
  final String endTime;
  final String room;
  final String teacher;
  final String group;
  final String sessionType;
  final int semester;
  final Color color;
  final bool isRecurring;
  final bool isDS;
  final double coefficient;
  final String? taskId;

  TimetableEntry({
    required this.id,
    required this.subject,
    required this.module,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.teacher,
    required this.group,
    required this.sessionType,
    required this.semester,
    required this.color,
    this.isRecurring = false,
    this.isDS = false,
    this.coefficient = 1.0,
    this.taskId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'module': module,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'teacher': teacher,
      'group': group,
      'sessionType': sessionType,
      'semester': semester,
      'color': color.value,
      'isRecurring': isRecurring,
      'isDS': isDS,
      'coefficient': coefficient,
      'taskId': taskId,
    };
  }

  factory TimetableEntry.fromMap(Map<String, dynamic> map) {
    return TimetableEntry(
      id: map['id'] ?? '',
      subject: map['subject'] ?? '',
      module: map['module'] ?? '',
      day: map['day'] ?? 'Monday',
      startTime: map['startTime'] ?? '08:00',
      endTime: map['endTime'] ?? '09:00',
      room: map['room'] ?? '',
      teacher: map['teacher'] ?? '',
      group: map['group'] ?? 'A',
      sessionType: map['sessionType'] ?? 'Cours',
      semester: map['semester'] ?? 1,
      color: Color(map['color'] ?? Colors.blue.value),
      isRecurring: map['isRecurring'] ?? false,
      isDS: map['isDS'] ?? false,
      coefficient: map['coefficient']?.toDouble() ?? 1.0,
      taskId: map['taskId'],
    );
  }
}

class TpLog {
  final String id;
  final String timetableEntryId;
  final String title;
  final bool isCompleted;
  final DateTime? completedDate;
  final String notes;
  final DateTime dueDate;

  TpLog({
    required this.id,
    required this.timetableEntryId,
    required this.title,
    this.isCompleted = false,
    this.completedDate,
    this.notes = '',
    required this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timetableEntryId': timetableEntryId,
      'title': title,
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
      'notes': notes,
      'dueDate': dueDate.toIso8601String(),
    };
  }

  factory TpLog.fromMap(Map<String, dynamic> map) {
    return TpLog(
      id: map['id'] ?? '',
      timetableEntryId: map['timetableEntryId'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      completedDate: map['completedDate'] != null
          ? DateTime.parse(map['completedDate'])
          : null,
      notes: map['notes'] ?? '',
      dueDate: DateTime.parse(map['dueDate']),
    );
  }
}

class Reminder {
  final String id;
  final String timetableEntryId;
  final String title;
  final DateTime date;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.timetableEntryId,
    required this.title,
    required this.date,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timetableEntryId': timetableEntryId,
      'title': title,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] ?? '',
      timetableEntryId: map['timetableEntryId'] ?? '',
      title: map['title'] ?? '',
      date: DateTime.parse(map['date']),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}