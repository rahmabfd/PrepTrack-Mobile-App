import 'package:cloud_firestore/cloud_firestore.dart';
import 'timetable_model.dart';

class TimetableService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Timetable methods
  Stream<List<TimetableEntry>> getUserTimetable(String userId, {int? semester}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('timetables')
        .doc(userId)
        .collection('entries');

    if (semester != null) {
      query = query.where('semester', isEqualTo: semester);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => TimetableEntry.fromMap(doc.data()))
        .toList());
  }

  Future<void> addTimetableEntry(String userId, TimetableEntry entry) async {
    await _firestore
        .collection('timetables')
        .doc(userId)
        .collection('entries')
        .doc(entry.id)
        .set(entry.toMap());
  }

  Future<void> updateTimetableEntry(String userId, TimetableEntry entry) async {
    await _firestore
        .collection('timetables')
        .doc(userId)
        .collection('entries')
        .doc(entry.id)
        .update(entry.toMap());
  }

  Future<void> deleteTimetableEntry(String userId, String entryId) async {
    await _firestore
        .collection('timetables')
        .doc(userId)
        .collection('entries')
        .doc(entryId)
        .delete();
  }

  // TP/TD Log methods
  Stream<List<TpLog>> getTpLogs(String userId, String timetableEntryId) {
    return _firestore
        .collection('timetables')
        .doc(userId)
        .collection('tpLogs')
        .where('timetableEntryId', isEqualTo: timetableEntryId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TpLog.fromMap(doc.data()))
        .toList());
  }

  Future<void> addTpLog(String userId, TpLog log) async {
    await _firestore
        .collection('timetables')
        .doc(userId)
        .collection('tpLogs')
        .doc(log.id)
        .set(log.toMap());
  }

  Future<void> updateTpLog(String userId, TpLog log) async {
    await _firestore
        .collection('timetables')
        .doc(userId)
        .collection('tpLogs')
        .doc(log.id)
        .update(log.toMap());
  }

  // Reminder methods
  Stream<List<Reminder>> getReminders(String userId, String timetableEntryId) {
    return _firestore
        .collection('timetables')
        .doc(userId)
        .collection('reminders')
        .where('timetableEntryId', isEqualTo: timetableEntryId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Reminder.fromMap(doc.data()))
        .toList());
  }

  Future<void> addReminder(String userId, Reminder reminder) async {
    await _firestore
        .collection('timetables')
        .doc(userId)
        .collection('reminders')
        .doc(reminder.id)
        .set(reminder.toMap());
  }

  Future<void> updateReminder(String userId, Reminder reminder) async {
    await _firestore
        .collection('timetables')
        .doc(userId)
        .collection('reminders')
        .doc(reminder.id)
        .update(reminder.toMap());
  }

  Future<void> deleteTpLog(String userId, String logId) async {
    await _firestore
        .collection('timetables')
        .doc(userId)
        .collection('tpLogs')
        .doc(logId)
        .delete();
  }

  Future<void> deleteReminder(String userId, String reminderId) async {
    await _firestore
        .collection('timetables')
        .doc(userId)
        .collection('reminders')
        .doc(reminderId)
        .delete();
  }
}