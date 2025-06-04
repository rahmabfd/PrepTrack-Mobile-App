import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/auth_provider.dart';

class AppColors {
  static const Color primary = Color(0xFF5D5FEF); // Purple-blue from original
  static const Color secondary = Color(0xFF10B981); // Mint green
  static const Color tertiary = Color(0xFFF59E0B); // Soft orange
  static const Color backgroundLight = Color(0xFFF9FAFB); // Very light gray
  static const Color textPrimary = Color(0xFF111827); // Soft black
  static const Color textSecondary = Color(0xFF6B7280); // Dark gray
  static const Color backgroundDark = Color(0xFF1E293B); // Navy blue
  static const Color accent = Color(0xFF00BFA5); // Teal accent
  static const Color purple = Color(0xFFAB47BC); // Purple accent
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(context, authProvider),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 8),
                _buildNavItem(
                  context,
                  icon: Icons.home_rounded,
                  title: 'Home',
                  route: '/',
                  isActive: ModalRoute.of(context)?.settings.name == '/home',
                ),
                _buildExpansionTile(
                  context,
                  title: 'Planning',
                  icon: Icons.schedule_rounded,
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.task_alt_rounded,
                      title: 'Tasks',
                      route: '/tasks',
                      isActive: ModalRoute.of(context)?.settings.name == '/tasks',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.timer_rounded,
                      title: 'Study Sessions',
                      route: '/study-sessions',
                      isActive: ModalRoute.of(context)?.settings.name == '/study-sessions',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.calendar_today_rounded,
                      title: 'Timetable',
                      route: '/timetable',
                      isActive: ModalRoute.of(context)?.settings.name == '/timetable',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.event_busy_rounded,
                      title: 'Deadlines',
                      route: '/deadlines',
                      isActive: ModalRoute.of(context)?.settings.name == '/deadlines',
                    ),
                  ],
                ),
                _buildExpansionTile(
                  context,
                  title: 'Resources',
                  icon: Icons.book_rounded,
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.menu_book_rounded,
                      title: 'Documents',
                      route: '/docs',
                      isActive: ModalRoute.of(context)?.settings.name == '/docs',
                    ),
                  ],
                ),
                _buildExpansionTile(
                  context,
                  title: 'Community',
                  icon: Icons.group_rounded,
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.chat_rounded,
                      title: 'Chatroom',
                      route: '/chat',
                      isActive: ModalRoute.of(context)?.settings.name == '/chatroom',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.forum_rounded,
                      title: 'Forum',
                      route: '/forum',
                      isActive: ModalRoute.of(context)?.settings.name == '/forum',
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.leaderboard_rounded,
                      title: 'Leaderboard',
                      route: '/leaderboard',
                      isActive: ModalRoute.of(context)?.settings.name == '/leaderboard',
                    ),
                  ],
                ),
                _buildExpansionTile(
                  context,
                  title: 'Personal',
                  icon: Icons.person_outline_rounded,
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.mood_rounded,
                      title: 'Mood Analysis',
                      route: '/mood-analysis',
                      isActive: ModalRoute.of(context)?.settings.name == '/mood-analysis',
                    ),
                  ],
                ),
                if (authProvider.isLoggedIn)
                  _buildNavItem(
                    context,
                    icon: Icons.person_rounded,
                    title: 'Profile',
                    route: '/profile',
                    isActive: ModalRoute.of(context)?.settings.name == '/profile',
                  ),
                _buildDivider(),
                if (!authProvider.isLoggedIn)
                  _buildNavItem(
                    context,
                    icon: Icons.login_rounded,
                    title: 'Sign In',
                    route: '/auth',
                    isActive: ModalRoute.of(context)?.settings.name == '/auth',
                    highlight: true,
                  ),
                _buildNavItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  route: '/settings',
                  isActive: ModalRoute.of(context)?.settings.name == '/settings',
                ),
                _buildNavItem(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Feedback',
                  route: '/help',
                  isActive: ModalRoute.of(context)?.settings.name == '/help',
                ),
                if (authProvider.isLoggedIn) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        authProvider.signOut();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Sign Out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.85),
          ],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'PrepTrack',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          authProvider.isLoggedIn
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600 ),
              ),
              const SizedBox(height: 4),
              Text(
                authProvider.user?.displayName ?? 'Student',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ],
          )
              : Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Sign in to unlock all features',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          childrenPadding: const EdgeInsets.only(left: 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? route,
        bool isActive = false,
        bool isDisabled = false,
        bool highlight = false,
      }) {
    final Color itemColor = isDisabled
        ? AppColors.textSecondary.withOpacity(0.5)
        : isActive || highlight
        ? AppColors.primary
        : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          onTap: isDisabled
              ? null
              : () {
            Navigator.pop(context);
            if (route != null) {
              Navigator.pushNamed(context, route);
            }
          },
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withOpacity(0.1)
                  : highlight
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: itemColor,
              size: 24,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: itemColor,
              fontSize: 16,
              fontWeight: isActive || highlight ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          dense: true,
          visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
          tileColor: isActive ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Divider(
        color: AppColors.textSecondary.withOpacity(0.15),
        thickness: 1,
      ),
    );
  }
}