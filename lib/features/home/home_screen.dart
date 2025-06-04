import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:async/async.dart'; // For StreamZip
import '../../features/auth/auth_provider.dart';
import '../../widgets/bottom_navbar.dart';
import '../../widgets/app_drawer.dart';
import '../tasks/task_model.dart';
import '../tasks/task_service.dart';

// Define AppColors for consistency
class AppColors {
  static const Color primary = Color(0xFF5D5FEF); // Purple-blue
  static const Color secondary = Color(0xFF10B981); // Mint green
  static const Color tertiary = Color(0xFFF59E0B); // Soft orange
  static const Color backgroundLight = Color(0xFFF9FAFB); // Very light gray
  static const Color textPrimary = Color(0xFF111827); // Soft black
  static const Color textSecondary = Color(0xFF6B7280); // Dark gray
  static const Color backgroundDark = Color(0xFF1E293B); // Navy blue
  static const Color cardBackground = Colors.white;
  static const Color accent = Color(0xFF00BFA5); // Teal accent
  static const Color purple = Color(0xFFAB47BC); // Purple accent
  static const Color bronze = Color(0xFFCD7F32); // Bronze badge color
  static const Color silver = Color(0xFFC0C0C0); // Silver badge color
  static const Color gold = Color(0xFFFFD700); // Gold badge color
  static const Color platinum = Color(0xFFE5E4E2); // Platinum badge color
  static const Color prog = Color(0xFF20B2AA); // Progress color
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService _taskService = TaskService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final weekRange = _getWeekRange();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 24, color: AppColors.backgroundLight),
            SizedBox(width: 8),
            Text(
              'PrepTrack',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppColors.backgroundLight,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary, // Solid background color
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.7),
                  AppColors.secondary.withOpacity(0.7),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Gamified Player Card or Welcome Container
                  if (authProvider.isLoggedIn)
                    _buildGamifiedPlayerCard(context, authProvider)
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.5),
                            AppColors.secondary.withOpacity(0.5),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome to PrepTrack',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cardBackground,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Track progress & compete!',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.cardBackground,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(context, '/auth'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.cardBackground,
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                shadowColor: AppColors.primary.withOpacity(0.3),
                              ),
                              child: Text(
                                'Get Started',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.cardBackground,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),
                  // Study Stats
                  if (authProvider.isLoggedIn) ...[
                    _buildSectionTitle('Your Progress'),
                    authProvider.user?.uid != null
                        ? StreamBuilder(
                      stream: StreamZip([
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(authProvider.user!.uid)
                            .collection('study_sessions')
                            .where('date', isGreaterThanOrEqualTo: weekRange['start'])
                            .where('date', isLessThanOrEqualTo: weekRange['end'])
                            .snapshots(),
                        _taskService.getTasks(authProvider.user!.uid),
                      ]),
                      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (snapshot.hasError) {
                          return _buildErrorCard('Error loading progress');
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 3,
                            ),
                          );
                        }

                        // Process study sessions
                        final sessions = snapshot.data![0] as QuerySnapshot;
                        int totalMinutes = 0;
                        for (var session in sessions.docs) {
                          final data = session.data() as Map<String, dynamic>;
                          final completedDuration = data['completedDuration'] as int? ?? 0;
                          totalMinutes += completedDuration;
                        }
                        final studyHours = (totalMinutes / 60).toStringAsFixed(1);

                        // Process tasks
                        final tasks = snapshot.data![1] as List<Task>;
                        final completedTasks = tasks.where((task) => task.isCompleted).length;
                        final totalTasks = tasks.length;

                        return _buildProgressCards(studyHours, completedTasks, totalTasks);
                      },
                    )
                        : Container(),
                    SizedBox(height: 20),
                  ],
                  // Upcoming Deadlines
                  if (authProvider.isLoggedIn) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Upcoming Deadlines'),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/stats');
                          },
                          child: Text(
                            'See all',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    authProvider.user?.uid != null
                        ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(authProvider.user!.uid)
                          .collection('deadlines')
                          .orderBy('date')
                          .limit(3)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _buildErrorCard('Error loading deadlines');
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 3,
                            ),
                          );
                        }
                        final deadlines = snapshot.data!.docs;
                        if (deadlines.isEmpty) {
                          return _buildEmptyCard(
                            'No upcoming deadlines',
                            'Add a deadline to track assignments',
                            Icons.calendar_today_rounded,
                          );
                        }
                        return Column(
                          children: deadlines.map((deadline) => _buildDeadlineCard(deadline)).toList(),
                        );
                      },
                    )
                        : Container(),
                    SizedBox(height: 20),
                  ],
                  // Mood Tracker Button
                  if (authProvider.isLoggedIn) ...[
                    _buildSectionTitle('Your Well-Being'),
                    _buildMoodTrackerButton(context),
                    SizedBox(height: 20),
                  ],
                  // Quick Actions Grid
                  _buildSectionTitle('Explore More'),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildActionCard(
                        context,
                        Icons.timer,
                        'Study Timer',
                        '/studysessions',
                        Color(0xFF5D5FEF),
                        'Track your study sessions',
                      ),
                      _buildActionCard(
                        context,
                        Icons.task,
                        'Tasks',
                        '/tasks',
                        Color(0xFF00BFA5),
                        'Manage your to-do list',
                      ),
                      _buildActionCard(
                        context,
                        Icons.event,
                        'Deadlines',
                        '/stats',
                        Color(0xFFF59E0B),
                        'Stay on top of due dates',
                      ),
                      _buildActionCard(
                        context,
                        Icons.book,
                        'Documents',
                        '/docs',
                        Color(0xFFAB47BC),
                        'Access study materials',
                      ),
                      _buildActionCard(
                        context,
                        Icons.calendar_today,
                        'Timetable',
                        '/timetable',
                        Color(0xFF0288D1),
                        'Plan your schedule',
                      ),
                      _buildActionCard(
                        context,
                        Icons.forum,
                        'Community',
                        '/community',
                        Color(0xFF7CB342),
                        'Join the Q&A forum',
                      ),
                      if (!authProvider.isLoggedIn)
                        _buildActionCard(
                          context,
                          Icons.login,
                          'Sign In',
                          '/auth',
                          Color(0xFF7CB342),
                          'Log in to access features',
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 4),
    );
  }

  // Calculate week range
  Map<String, String> _getWeekRange() {
    final now = DateTime.now();
    final currentDay = now.weekday;
    final startOfWeek = now.subtract(Duration(days: currentDay - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    return {
      'start': DateFormat('yyyy-MM-dd').format(startOfWeek),
      'end': DateFormat('yyyy-MM-dd').format(endOfWeek),
    };
  }

  // Get badge color
  Color _getBadgeColor(BadgeLevel badge) {
    switch (badge) {
      case BadgeLevel.bronze:
        return AppColors.bronze;
      case BadgeLevel.silver:
        return AppColors.silver;
      case BadgeLevel.gold:
        return AppColors.gold;
      case BadgeLevel.platinum:
        return AppColors.platinum;
      case BadgeLevel.none:
      default:
        return AppColors.textSecondary;
    }
  }

  // Gamified Player Card
  Widget _buildGamifiedPlayerCard(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardBackground,
            AppColors.cardBackground.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 300;
          final fontScale = isNarrow ? 0.85 : 1.0;
          return Row(
            children: [
              Container(
                width: 60 * fontScale,
                height: 60 * fontScale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                  gradient: LinearGradient(
                    colors: [AppColors.cardBackground, AppColors.cardBackground.withOpacity(0.8)],
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 36 * fontScale,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Player Nesrine',
                      style: GoogleFonts.poppins(
                        fontSize: 18 * fontScale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 16 * fontScale,
                                color: AppColors.tertiary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${authProvider.points} XP',
                                style: GoogleFonts.poppins(
                                  fontSize: 14 * fontScale,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.tertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getBadgeColor(authProvider.badge).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                size: 16 * fontScale,
                                color: _getBadgeColor(authProvider.badge),
                              ),
                              SizedBox(width: 4),
                              Text(
                                authProvider.badge.toString().split('.').last.capitalize(),
                                style: GoogleFonts.poppins(
                                  fontSize: 14 * fontScale,
                                  fontWeight: FontWeight.w600,
                                  color: _getBadgeColor(authProvider.badge),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (authProvider.points % 100) / 100,
                      backgroundColor: AppColors.textSecondary.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.leaderboard_rounded,
                    size: 24 * fontScale,
                    color: AppColors.tertiary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // Mood tracker button
  Widget _buildMoodTrackerButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/mood'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.cardBackground,
              AppColors.cardBackground,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mood,
                size: 28,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you feeling today?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Track your mood to stay balanced',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20,
              color: Colors.black.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  // Progress Cards (Separated)
  Widget _buildProgressCards(String studyHours, int completedTasks, int totalTasks) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.only(right: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.tertiary.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tertiary.withOpacity(0.15),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tertiary,
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$studyHours hrs',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Study Hours',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.15),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                  ),
                  child: Icon(
                    Icons.task_alt_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completedTasks/$totalTasks',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Tasks Done',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Action card (for Quick Actions and Community)
  Widget _buildActionCard(
      BuildContext context,
      IconData icon,
      String title,
      String route,
      Color color,
      String subtitle,
      ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardBackground,
              AppColors.cardBackground.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: color.withOpacity(0.3),
          highlightColor: Colors.transparent,
          onTap: () => Navigator.pushNamed(context, route),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(
                    icon,
                    size: 24,
                    color: color,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Deadline card
  Widget _buildDeadlineCard(DocumentSnapshot deadline) {
    final date = (deadline['date'] as Timestamp).toDate();
    final formattedDate = DateFormat('dd MMM, yyyy').format(date);
    final timeLeft = _calculateTimeLeft(date);
    final isExpired = timeLeft == 'Expired';
    final isUrgent = !isExpired && date.difference(DateTime.now()).inDays <= 3;
    Color statusColor = isExpired
        ? Colors.red
        : isUrgent
        ? AppColors.tertiary
        : AppColors.secondary;
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 54,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deadline['subject'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isExpired ? AppColors.textSecondary : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${deadline['type']} • $formattedDate',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  timeLeft,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Error card
  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Empty card
  Widget _buildEmptyCard(String title, String subtitle, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary.withOpacity(0.5),
            size: 42,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Calculate time left
  String _calculateTimeLeft(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    if (difference.isNegative) return 'Expired';
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    if (days > 0) return '$days ${days == 1 ? 'day' : 'days'}';
    return '$hours ${hours == 1 ? 'hour' : 'hours'}';
  }
}

// String extension for capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}