import 'package:flutter/material.dart';

import '../features/auth/auth_screen.dart';
import '../features/forum/forum_screen.dart';

import '../features/home/mood_analysis.dart';
import '../features/profile/group_chat_screen.dart';
import '../features/chat/leaderboard_chart.dart';
import '../features/documents/documents_screen.dart';
import '../features/home/home_screen.dart';

import '../features/profile/profile_screen.dart';
import '../features/stats/stats_screen.dart';
import '../features/study_timer/study_sessions.dart';
import '../features/study_timer/timer_screen.dart';
import '../features/tasks/tasks_screen.dart';
import '../features/timetable/timetable_screen.dart';
import '../widgets/settings.dart';



class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/auth':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case '/mood':
        return MaterialPageRoute(builder: (_) => const SentimentAnalysisPage());
      case '/forum':
        return MaterialPageRoute(builder: (_) => const ForumScreen());
      case '/leaderboard':
        return MaterialPageRoute(builder: (_) => const LeaderboardPage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsTab());
      case '/chat':
        return MaterialPageRoute(builder: (_) => const GroupChatScreen());
      case '/stats':
        return MaterialPageRoute(builder: (_) => const DeadlineTrackerPage());
      case '/timer':
        return MaterialPageRoute(builder: (_) => const TimerScreen());
      case '/tasks':
        return MaterialPageRoute(builder: (_) => const TasksScreen());
      case '/docs':
        return MaterialPageRoute(builder: (_) => DocumentsScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case '/studysessions':
        return MaterialPageRoute(builder: (_) => const StudySessionsPage());
      
      case '/timetable':  // Add this case
        return MaterialPageRoute(builder: (_) => const TimetableScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}