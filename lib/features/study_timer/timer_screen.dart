import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/auth_provider.dart';

class TimerScreen extends StatefulWidget {
  final int presetDuration;
  final String? subject;
  final String? sessionId;
  final Color sessionColor;

  const TimerScreen({
    super.key,
    this.presetDuration = 25,
    this.subject,
    this.sessionId,
    this.sessionColor = Colors.blueAccent,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRunning = false;
  late int _secondsRemaining;
  late int _totalSeconds;
  bool _sessionCompleted = false;
  int _completedSeconds = 0;
  bool _initialLoadComplete = false;
  int _pauseCount = 0;
  double _focusScore = 100.0;
  Timestamp? _createdAt;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.presetDuration * 60;
    _secondsRemaining = _totalSeconds;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() => setState(() {}));

    _loadSessionState();
  }

  Future<void> _loadSessionState() async {
    if (widget.sessionId == null) {
      debugPrint('No sessionId provided, initializing new session');
      setState(() => _initialLoadComplete = true);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      debugPrint('User not logged in');
      setState(() => _initialLoadComplete = true);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .collection('study_sessions')
          .doc(widget.sessionId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        debugPrint('Loaded session data: $data');
        if (data['isPaused'] == true && data['remainingDuration'] != null) {
          _secondsRemaining = data['remainingDuration'] as int;
          _completedSeconds = _totalSeconds - _secondsRemaining;
        }
        _pauseCount = data['pauseCount'] as int? ?? 0;
        _focusScore = data['focusScore']?.toDouble() ?? 100.0;
        _createdAt = data['createdAt'] as Timestamp?;
        if (data['completedDuration'] != null) {
          _completedSeconds = (data['completedDuration'] as int) * 60;
          _secondsRemaining = _totalSeconds - _completedSeconds;
        }
        debugPrint('Session state: completedSeconds=$_completedSeconds, secondsRemaining=$_secondsRemaining');
      } else {
        debugPrint('Session document does not exist for sessionId: ${widget.sessionId}');
      }
    } catch (e) {
      debugPrint('Error loading session state: $e');
    }

    setState(() => _initialLoadComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialLoadComplete) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final progress = 1.0 - (_secondsRemaining / _totalSeconds);
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(theme),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimerCard(progress, minutes, seconds),
                    const SizedBox(height: 40),
                    _buildStatsCard(theme),
                    const SizedBox(height: 40),
                    _buildControlButtons(),
                    if (_sessionCompleted) ...[
                      const SizedBox(height: 24),
                      _buildCompletionCard(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: widget.sessionColor, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text(
                widget.subject ?? 'Study Timer',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (widget.subject != null)
            IconButton(
              icon: Icon(Icons.list, color: widget.sessionColor, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(double progress, String minutes, String seconds) {
    return Container(
      width: 260,
      height: 260,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            color: widget.sessionColor,
            backgroundColor: Colors.grey[200],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$minutes:$seconds',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% Complete',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          title: 'Focus Score',
          value: '${_focusScore.toStringAsFixed(0)}%',
          color: widget.sessionColor,
        ),
        _buildStatItem(
          title: 'Pauses',
          value: '$_pauseCount',
          color: widget.sessionColor,
        ),
      ],
    );
  }

  Widget _buildStatItem({required String title, required String value, required Color color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          icon: Icons.refresh,
          onPressed: _resetTimer,
          color: Colors.grey[500]!,
        ),
        const SizedBox(width: 24),
        _buildButton(
          icon: _isRunning ? Icons.pause : Icons.play_arrow,
          onPressed: _toggleTimer,
          color: widget.sessionColor,
          isMain: true,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isMain = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        padding: EdgeInsets.all(isMain ? 16 : 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: isMain ? 32 : 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: widget.sessionColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: widget.sessionColor, size: 20),
          const SizedBox(width: 8),
          Text(
            'Session Completed!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.sessionColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSessionState() async {
    if (widget.sessionId == null) {
      debugPrint('Cannot update session state: sessionId is null');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      debugPrint('Cannot update session state: user not logged in');
      return;
    }

    try {
      final completedDuration = _completedSeconds ~/ 60;
      debugPrint('Updating session state: sessionId=${widget.sessionId}, completedDuration=$completedDuration, remainingDuration=$_secondsRemaining');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .collection('study_sessions')
          .doc(widget.sessionId)
          .update({
        'completedDuration': completedDuration,
        'remainingDuration': _secondsRemaining,
        'isPaused': !_isRunning,
        'completionPercentage': (_completedSeconds / _totalSeconds * 100).round(),
        'pauseCount': _pauseCount,
        'focusScore': _focusScore,
        'lastUpdated': FieldValue.serverTimestamp(),
        'status': _sessionCompleted ? 'completed' : (_isRunning ? 'running' : 'paused'),
      });
      debugPrint('Session state updated successfully');
    } catch (e) {
      debugPrint('Error updating session state: $e');
    }
  }

  Future<void> _completeSession() async {
    if (widget.sessionId == null) {
      debugPrint('Cannot complete session: sessionId is null');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      debugPrint('Cannot complete session: user not logged in');
      return;
    }

    try {
      debugPrint('Completing session: sessionId=${widget.sessionId}, presetDuration=${widget.presetDuration}');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .collection('study_sessions')
          .doc(widget.sessionId)
          .update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'completedDuration': widget.presetDuration,
        'completionPercentage': 100,
        'isPaused': false,
        'remainingDuration': 0,
        'pauseCount': _pauseCount,
        'focusScore': _focusScore,
      });

      final points = await _awardPoints(authProvider);
      setState(() {
        _sessionCompleted = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session completed! Earned $points points!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      debugPrint('Session completed successfully, points earned: $points');
    } catch (e) {
      debugPrint('Error completing session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing session: ${e.toString()}')),
      );
    }
  }

  Future<int> _awardPoints(AuthProvider authProvider) async {
    int points = (widget.presetDuration / 25).ceil() * 20;

    if (_focusScore > 50) {
      points += ((_focusScore - 50) / 10).floor() * 5;
    }

    points -= _pauseCount * 2;
    points = points.clamp(0, double.infinity).toInt();

    if (_createdAt != null) {
      final createdDate = _createdAt!.toDate();
      final now = DateTime.now();
      if (createdDate.year == now.year &&
          createdDate.month == now.month &&
          createdDate.day == now.day) {
        points += 10;
      }
    }

    int streakPoints = await _calculateStreakBonus(authProvider.user!.uid);
    points += streakPoints;

    await authProvider.updatePoints(points);

    await _recordSessionCompletion(authProvider.user!.uid, widget.sessionId!);

    return points;
  }

  Future<void> _recordSessionCompletion(String userId, String sessionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('session_completions')
          .doc('$userId-$sessionId-${DateTime.now().millisecondsSinceEpoch}')
          .set({
        'userId': userId,
        'sessionId': sessionId,
        'completedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Session completion recorded: userId=$userId, sessionId=$sessionId');
    } catch (e) {
      debugPrint('Error recording session completion: $e');
    }
  }

  Future<int> _calculateStreakBonus(String userId) async {
    try {
      final now = DateTime.now();
      final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));
      final completions = await FirebaseFirestore.instance
          .collection('session_completions')
          .where('userId', isEqualTo: userId)
          .where('completedAt', isGreaterThanOrEqualTo: twentyFourHoursAgo)
          .get();
      final sessionCount = completions.docs.length + 1;
      debugPrint('Streak calculation: sessionCount=$sessionCount');
      return (sessionCount >= 3) ? 15 : 0;
    } catch (e) {
      debugPrint('Error calculating streak: $e');
      return 0;
    }
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _controller.repeat();
        _startTimer();
        debugPrint('Timer started');
      } else {
        _controller.stop();
        _pauseCount++;
        _calculateFocusScore();
        _updateSessionState();
        debugPrint('Timer paused, pauseCount=$_pauseCount');
      }
    });
  }

  void _calculateFocusScore() {
    final penalty = _pauseCount * 5.0;
    _focusScore = (100.0 - penalty).clamp(10.0, 100.0);
    debugPrint('Focus score calculated: $_focusScore');
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      if (_isRunning) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
            _completedSeconds++;
            _updateSessionState();
            _startTimer();
          } else {
            _handleTimerCompletion();
          }
        });
      }
    });
  }

  void _handleTimerCompletion() {
    _isRunning = false;
    _controller.stop();
    _completeSession();
    debugPrint('Timer completed');
  }

  void _resetTimer() {
    setState(() {
      _secondsRemaining = _totalSeconds;
      _completedSeconds = 0;
      _isRunning = false;
      _sessionCompleted = false;
      _pauseCount = 0;
      _focusScore = 100.0;
      _controller.reset();
      debugPrint('Timer reset');
    });
    if (widget.sessionId != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(Provider.of<AuthProvider>(context, listen: false).user!.uid)
          .collection('study_sessions')
          .doc(widget.sessionId)
          .update({
        'completedDuration': 0,
        'remainingDuration': _totalSeconds,
        'isPaused': false,
        'completionPercentage': 0,
        'pauseCount': 0,
        'focusScore': 100.0,
        'status': 'pending',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  void dispose() {
    if (_isRunning) {
      _updateSessionState();
    }
    _controller.dispose();
    super.dispose();
    debugPrint('TimerScreen disposed');
  }
}