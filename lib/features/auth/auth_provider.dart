import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum BadgeLevel {
  none,
  bronze,
  silver,
  gold,
  platinum,
}

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  int _points = 0;

  bool get isLoggedIn => _user != null;
  User? get user => _user;
  bool get isLoading => _isLoading;
  int get points => _points;
  BadgeLevel get badge {
    if (_points >= 2000) return BadgeLevel.platinum;
    if (_points >= 1000) return BadgeLevel.gold;
    if (_points >= 500) return BadgeLevel.silver;
    if (_points >= 0) return BadgeLevel.bronze;
    return BadgeLevel.none;
  }

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        await _fetchUserPoints(user.uid);
      } else {
        _points = 0;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserPoints(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        _points = doc.get('points') ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching points: $e');
    }
  }

  Future<void> updatePoints(int additionalPoints) async {
    if (_user == null) return;
    try {
      _points += additionalPoints;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({
        'points': _points,
        'badge': badge.toString().split('.').last,
      });
      notifyListeners();
    } catch (e) {
      print('Error updating points: $e');
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    } catch (e) {
      throw 'An error occurred';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String age,
    required String school,
    required String studentClass,

  }) async {
    try {
      _setLoading(true);
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email.trim(),
        'name': name.trim(),
        'surname': surname.trim(),
        'age': age.trim(),
        'school': school.trim(),
        'class': studentClass.trim(),

        'createdAt': FieldValue.serverTimestamp(),
        'points': 0,
        'badge': BadgeLevel.bronze.toString().split('.').last,
      });

      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    } catch (e) {
      throw 'An error occurred';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    } catch (e) {
      throw 'An error occurred';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _authError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password too weak';
      case 'invalid-email':
        return 'Invalid email';
      default:
        return 'Authentication error';
    }
  }
}