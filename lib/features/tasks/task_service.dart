import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../features/auth/auth_provider.dart';
import 'task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'tasks';
  final String _completionsPath = 'task_completions';

  Stream<List<Task>> getTasks(String userId) {
    return _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Task.fromMap(doc.data()))
        .toList());
  }

  Future<void> addTask(Task task) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(task.id)
          .set(task.toMap());
      print("Task added successfully: ${task.title} with color: ${task.color}");
    } catch (e) {
      print("Error adding task: $e");
      throw e;
    }
  }

  Future<void> updateTask(Task task, {BuildContext? context}) async {
    try {
      // Lock the task if it is being marked as completed
      final updatedTask = task.isCompleted
          ? task.copyWith(isLocked: true)
          : task;
      await _firestore
          .collection(_collectionPath)
          .doc(updatedTask.id)
          .update(updatedTask.toMap());
      print("Task updated successfully: ${updatedTask.title}");

      // Award points if task is marked as completed
      if (updatedTask.isCompleted && context != null) {
        await _awardPoints(updatedTask, context);
      }
    } catch (e) {
      print("Error updating task: $e");
      throw e;
    }
  }

  Future<void> _awardPoints(Task task, BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    int points = 10; // Base points

    // Priority bonus
    switch (task.priority) {
      case 1:
        points += 5; // High
        break;
      case 2:
        points += 2; // Medium
        break;
      case 3:
        points += 0; // Low
        break;
    }

    // Category multiplier
    double multiplier = 1.0;
    switch (task.category) {
      case 'EXAMEN':
      case 'CONCOURS':
        multiplier = 1.5;
        break;
      case 'DS':
      case 'TP':
        multiplier = 1.2;
        break;
      case 'TD':
      case 'COURSE':
      case 'OTHER':
        multiplier = 1.0;
        break;
    }
    points = (points * multiplier).round();

    // Timeliness bonus
    if (task.dueDate != null && task.dueDate!.isAfter(DateTime.now())) {
      points += 3;
    }

    // Streak bonus
    int streakPoints = await _calculateStreakBonus(authProvider.user!.uid);
    points += streakPoints;

    // Update points in AuthProvider
    await authProvider.updatePoints(points);

    // Record task completion for streak tracking
    await _recordTaskCompletion(authProvider.user!.uid, task.id);
  }

  Future<void> _recordTaskCompletion(String userId, String taskId) async {
    try {
      await _firestore
          .collection(_completionsPath)
          .doc('$userId-$taskId-${DateTime.now().millisecondsSinceEpoch}')
          .set({
        'userId': userId,
        'taskId': taskId,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error recording task completion: $e");
    }
  }

  Future<int> _calculateStreakBonus(String userId) async {
    try {
      final now = DateTime.now();
      final twentyFourHoursAgo = now.subtract(Duration(hours: 24));
      final completions = await _firestore
          .collection(_completionsPath)
          .where('userId', isEqualTo: userId)
          .where('completedAt', isGreaterThanOrEqualTo: twentyFourHoursAgo)
          .get();
      final taskCount = completions.docs.length + 1; // Include current task
      return (taskCount >= 3) ? 5 : 0;
    } catch (e) {
      print("Error calculating streak: $e");
      return 0;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection(_collectionPath).doc(taskId).delete();
      print("Task deleted successfully: $taskId");
    } catch (e) {
      print("Error deleting task: $e");
      throw e;
    }
  }

  Stream<List<Task>> getTasksByCategory(String userId, String category) {
    return _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .where('subject', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Task.fromMap(doc.data()))
        .toList());
  }
}