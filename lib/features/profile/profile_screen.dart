import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_navbar.dart';
import '../auth/auth_provider.dart';


// Define color palette
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

// Define app version
const String appVersion = '1.0.0';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  late TabController _tabController;
  bool _isDarkMode = false;
  BadgeLevel _badge = BadgeLevel.none;
  int _points = 0;
  String? _selectedLanguage;

  final List<String> _classes = [
    '1st Year Preparatory MP',
    '1st Year Preparatory PC',
    '1st Year Preparatory PT',
    '2nd Year Preparatory MP',
    '2nd Year Preparatory PC',
    '2nd Year Preparatory PT',
  ];
  String? _selectedClass;

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Arabic',
    'Chinese',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedClass = _classes[0];
    _selectedLanguage = _languages[0];
    _loadUserData();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    _user = _auth.currentUser;
    if (_user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data() as Map<String, dynamic>?;
          _selectedClass = _userData?['class'] as String? ?? _classes[0];
          _selectedLanguage = _userData?['language'] as String? ?? _languages[0];
          _isDarkMode = _userData?['darkMode'] as bool? ?? false;
          _points = _userData?['points'] as int? ?? 0;
          _badge = _getBadgeLevel(_points);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showMessage('Error loading data: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  BadgeLevel _getBadgeLevel(int points) {
    if (points >= 2000) return BadgeLevel.platinum;
    if (points >= 1000) return BadgeLevel.gold;
    if (points >= 500) return BadgeLevel.silver;
    if (points >= 0) return BadgeLevel.bronze;
    return BadgeLevel.none;
  }

  Future<void> _updateProfile() async {
    if (_user == null) return;
    try {
      setState(() => _isLoading = true);
      await _firestore.collection('users').doc(_user!.uid).set({
        'name': _userData?['name'] as String? ?? 'User',
        'class': _selectedClass,
        'language': _selectedLanguage,
        'darkMode': _isDarkMode,
        'lastUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      setState(() => _isLoading = false);
      _showMessage('Profile updated successfully');
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Error updating profile: $e', isError: true);
    }
  }

  Future<void> _signOut() async {
    try {
      setState(() => _isLoading = true);
      await _auth.signOut();
      if (ModalRoute.of(context)?.settings.name != '/login') {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('Error signing out: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red : AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    Color badgeColor;
    switch (_badge) {
      case BadgeLevel.bronze:
        badgeColor = AppColors.bronze;
        break;
      case BadgeLevel.silver:
        badgeColor = AppColors.silver;
        break;
      case BadgeLevel.gold:
        badgeColor = AppColors.gold;
        break;
      case BadgeLevel.platinum:
        badgeColor = AppColors.platinum;
        break;
      default:
        badgeColor = AppColors.textSecondary;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDarkMode
              ? [AppColors.primary.withOpacity(0.9), AppColors.purple.withOpacity(0.7)]
              : [AppColors.primary, AppColors.purple.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.cardBackground,
            child: Icon(
              Icons.person_rounded,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _userData?['name'] as String? ?? 'Unknown Name',
            style: TextStyle(
              color: AppColors.backgroundLight,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'nesrinebt922@gmail.com',
            style: TextStyle(
              color: AppColors.backgroundLight.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('$_points', 'Points', Icons.star),
                Container(
                  height: 40,
                  width: 1,
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
                _buildStatColumn(
                  _badge.toString().split('.').last.capitalize(),
                  'Badge',
                  Icons.badge,
                  badgeColor: badgeColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, IconData icon, {Color? badgeColor}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: badgeColor ?? AppColors.accent,
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                color: badgeColor ?? AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          elevation: 4,
          color: _isDarkMode ? AppColors.backgroundDark : AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _isDarkMode ? AppColors.backgroundLight : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1),
              ListTile(
                leading: Icon(Icons.person_outline, color: AppColors.accent),
                title: Text(
                  'Name',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.backgroundLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${_userData?['name'] as String? ?? 'Not specified'} ${_userData?['surname'] as String? ?? ''}',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.cake_outlined, color: AppColors.accent),
                title: Text(
                  'Age',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.backgroundLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _userData?['age']?.toString() ?? 'Not specified',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.school_outlined, color: AppColors.accent),
                title: Text(
                  'School',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.backgroundLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _userData?['school'] as String? ?? 'Not specified',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.class_outlined, color: AppColors.accent),
                title: Text(
                  'Class',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.backgroundLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _selectedClass ?? 'Not specified',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.accent,
                  size: 18,
                ),
                onTap: _showClassPicker,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'SETTINGS',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: _isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Card(
          elevation: 4,
          color: _isDarkMode ? AppColors.backgroundDark : AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'Language',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.backgroundLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _selectedLanguage ?? 'Select language',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                leading: Icon(Icons.language, color: AppColors.accent),
                trailing: Icon(Icons.arrow_forward_ios, color: AppColors.accent, size: 18),
                onTap: _showLanguagePicker,
              ),
              const Divider(height: 1, thickness: 1),
              SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.backgroundLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Toggle between light and dark theme',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                value: _isDarkMode,
                activeColor: AppColors.accent,
                onChanged: (value) {
                  setState(() => _isDarkMode = value);
                  _updateProfile();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 4,
          color: _isDarkMode ? AppColors.backgroundDark : AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'Privacy',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.backgroundLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leading: Icon(Icons.privacy_tip_outlined, color: AppColors.accent),
                trailing: Icon(Icons.arrow_forward_ios, color: AppColors.accent, size: 18),
                onTap: () {
                  _showMessage('Privacy settings not implemented yet');
                },
              ),
              const Divider(height: 1, thickness: 1),
              ListTile(
                title: Text(
                  'About',
                  style: TextStyle(
                    color: _isDarkMode ? AppColors.backgroundLight : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leading: Icon(Icons.info_outline, color: AppColors.accent),
                trailing: Icon(Icons.arrow_forward_ios, color: AppColors.accent, size: 18),
                onTap: () {
                  _showMessage('About page not implemented yet');
                },
              ),
              const Divider(height: 1, thickness: 1),
              ListTile(
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.red.shade300 : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leading: Icon(
                  Icons.logout,
                  color: _isDarkMode ? Colors.red.shade300 : Colors.red,
                ),
                onTap: _showSignOutDialog,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Text(
            'Version $appVersion',
            style: TextStyle(
              color: _isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _showClassPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDarkMode ? AppColors.backgroundDark : AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _isDarkMode ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Study Level',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _isDarkMode ? AppColors.backgroundLight : AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _classes.length,
                itemBuilder: (context, index) {
                  final level = _classes[index];
                  return ListTile(
                    title: Text(
                      level,
                      style: TextStyle(
                        color: _isDarkMode ? AppColors.backgroundLight : AppColors.textPrimary,
                        fontWeight: _selectedClass == level ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: _selectedClass == level
                        ? Icon(Icons.check_circle, color: AppColors.accent)
                        : null,
                    onTap: () {
                      setState(() => _selectedClass = level);
                      _updateProfile();
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDarkMode ? AppColors.backgroundDark : AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _isDarkMode ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _isDarkMode ? AppColors.backgroundLight : AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  return ListTile(
                    title: Text(
                      language,
                      style: TextStyle(
                        color: _isDarkMode ? AppColors.backgroundLight : AppColors.textPrimary,
                        fontWeight: _selectedLanguage == language ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: _selectedLanguage == language
                        ? Icon(Icons.check_circle, color: AppColors.accent)
                        : null,
                    onTap: () {
                      setState(() => _selectedLanguage = language);
                      _updateProfile();
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDarkMode ? AppColors.backgroundDark : AppColors.cardBackground,
        title: Text(
          'Confirm Logout',
          style: TextStyle(
            color: _isDarkMode ? AppColors.backgroundLight : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: _isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: _isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
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
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildProfileHeader(),
          Container(
            decoration: BoxDecoration(
              color: _isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Profile'),
                Tab(text: 'Settings'),
              ],
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.accent,
              indicatorWeight: 4,
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 3),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}