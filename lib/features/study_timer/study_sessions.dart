import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_navbar.dart';
import '../auth/auth_provider.dart';
import 'timer_screen.dart';

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
  static const Color platinum = Color(0xFFE5E4E2);
  static const Color prog = Color(0xFF20B2AA); // Purple-blue (matches primary)
// Platinum badge color
}
class StudySessionsPage extends StatefulWidget {
  const StudySessionsPage({super.key});

  @override
  State<StudySessionsPage> createState() => _StudySessionsPageState();
}

class _StudySessionsPageState extends State<StudySessionsPage> {
  DateTime _currentDate = DateTime.now();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(_currentDate);
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Study Sessions', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            onPressed: () => _openAddSession(context, authProvider),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: authProvider.isLoggedIn
          ? _buildSessionList(authProvider, formattedDate)
          : _buildGuestView(),
      bottomNavigationBar: BottomNavBar(selectedIndex: 1),
    );
  }

  Widget _buildSessionList(AuthProvider authProvider, String formattedDate) {
    return Column(
      children: [
        _buildDateSelector(),
        _buildTotalTime(authProvider, formattedDate),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(authProvider.user!.uid)
                .collection('study_sessions')
                .where('date', isEqualTo: formattedDate)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                debugPrint('Error fetching sessions: ${snapshot.error}');
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final sessions = snapshot.data?.docs ?? [];
              debugPrint('Fetched ${sessions.length} sessions for $formattedDate');
              sessions.sort((a, b) {
                final aCreatedAt = a['createdAt']?.toDate() ?? DateTime.now();
                final bCreatedAt = b['createdAt']?.toDate() ?? DateTime.now();
                return bCreatedAt.compareTo(aCreatedAt);
              });

              if (sessions.isEmpty) {
                return _buildEmptyState();
              }

              return _buildAnimatedList(sessions);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTotalTime(AuthProvider authProvider, String formattedDate) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .collection('study_sessions')
          .where('date', isEqualTo: formattedDate)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          debugPrint('Error loading total time: ${snapshot.error}');
          return const Text('Error loading total time');
        }

        int totalMinutes = 0;
        final sessions = snapshot.data?.docs ?? [];
        for (var session in sessions) {
          final data = session.data() as Map<String, dynamic>;
          final completedDuration = data['completedDuration'] as int? ?? 0;
          debugPrint('Session ${session.id}: completedDuration=$completedDuration');
          totalMinutes += completedDuration;
        }
        debugPrint('Total minutes for $formattedDate: $totalMinutes');

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Total Studied: $totalMinutes min',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedList(List<QueryDocumentSnapshot> sessions) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index].data() as Map<String, dynamic>;
        final color = _getColorFromSession(session);
        return _buildSessionCard(session, sessions[index].id, index, color, sessions.length);
      },
    );
  }

  Color _getColorFromSession(Map<String, dynamic> session) {
    try {
      if (session['color'] != null) {
        return Color(session['color'] as int);
      }
    } catch (e) {
      debugPrint('Error parsing color: $e');
    }
    return Theme.of(context).colorScheme.primary;
  }

  Widget _buildSessionCard(Map<String, dynamic> session, String id, int index, Color color, int totalSessions) {
    final status = session['status'] as String? ?? 'pending';
    final createdAt = session['createdAt']?.toDate() ?? DateTime.now();
    final plannedDuration = session['plannedDuration'] as int? ?? 25;
    final completedDuration = session['completedDuration'] as int? ?? 0;
    final pauseCount = session['pauseCount'] as int? ?? 0;
    final completionPercentage = session['completionPercentage'] as int? ?? 0;
    final displayDuration = (status == 'completed' || status == 'paused' || status == 'running')
        ? completedDuration
        : plannedDuration;
    debugPrint('Rendering session $id: status=$status, plannedDuration=$plannedDuration, completedDuration=$completedDuration, displayDuration=$displayDuration, completionPercentage=$completionPercentage');

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: index == totalSessions - 1 ? 16 : 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _startSession(context, session, id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session['subject'] ?? 'No Subject',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$displayDuration min',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ),
                        ),



                        const SizedBox(width: 16),
                        Icon(
                          Icons.percent,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$completionPercentage%',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('hh:mm a').format(createdAt),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      status == 'completed' ? Icons.check : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                    onPressed: () => _deleteSession(context, id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteSession(BuildContext context, String sessionId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .collection('study_sessions')
          .doc(sessionId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Session deleted'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      debugPrint('Error deleting session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting session: ${e.toString()}')),
      );
    }
  }

  Widget _buildDateSelector() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 28),
              onPressed: () => _changeDate(-1),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Text(
              DateFormat('EEEE, MMM d').format(_currentDate),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 28),
              onPressed: () => _changeDate(1),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No sessions today',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new session',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestView() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 80,
            color: AppColors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in to view your sessions',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/auth'),
            icon: const Icon(Icons.login),
            label: const Text('Sign In'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddSession(BuildContext context, AuthProvider authProvider) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSessionScreen(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      await _addSession(
        context,
        authProvider,
        result['subject'],
        result['duration'],
        result['color'].value,
      );

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  Future<void> _addSession(
      BuildContext context,
      AuthProvider authProvider,
      String subject,
      int duration,
      int color,
      ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .collection('study_sessions')
          .add({
        'subject': subject,
        'plannedDuration': duration,
        'color': color,
        'date': DateFormat('yyyy-MM-dd').format(_currentDate),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'pauseCount': 0,
        'focusScore': 100,
        'completedDuration': 0,
        'completionPercentage': 0,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Session added'),
          backgroundColor: AppColors.primary,
        ),
      );
      debugPrint('Session added: subject=$subject, duration=$duration');
    } catch (e) {
      debugPrint('Error creating session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating session: ${e.toString()}')),
      );
    }
  }

  void _startSession(BuildContext context, Map<String, dynamic> session, String sessionId) {
    final duration = session['plannedDuration'];
    final int presetDuration = duration is int ? duration : 25;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerScreen(
          presetDuration: presetDuration,
          subject: session['subject'] as String?,
          sessionId: sessionId,
          sessionColor: _getColorFromSession(session),
        ),
      ),
    );
  }

  void _changeDate(int days) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: days));
    });
  }
}

class AddSessionScreen extends StatefulWidget {
  const AddSessionScreen({super.key});

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSubject;
  int _selectedDuration = 25;
  Color _selectedColor = const Color(0xFFC7CEEA);
  final List<String> _subjects = [
    'Analysis',
    'Algebra',
    'Physics',
    'General Chemistry',
    'Organic Chemistry',
    'English',
    'French',
    'Computer Science',
    'STA',
    'General',
  ];
  final List<Color> _availableColors = [
    const Color(0xFFFF8A80),
    const Color(0xFFFFE082),
    const Color(0xFF80DEEA),
    const Color(0xFFC7CEEA),
    const Color(0xFFA5D6A7),
    const Color(0xFFFFB74D),
    const Color(0xFFE1BEE7),
    const Color(0xFFFFCC80),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Session', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Session',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Subject',
                          prefixIcon: Icon(Icons.book, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        isExpanded: true,
                        value: _selectedSubject,
                        icon: Icon(Icons.arrow_drop_down_circle, color: AppColors.primary),
                        items: _subjects.map((subject) => DropdownMenuItem<String>(
                          value: subject,
                          child: Text(subject, style: const TextStyle(color: Colors.black87)),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubject = value;
                          });
                        },
                        validator: (value) => value == null ? 'Select a subject' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Duration',
                          prefixIcon: Icon(Icons.timer, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        isExpanded: true,
                        value: _selectedDuration,
                        icon: Icon(Icons.arrow_drop_down_circle, color: AppColors.primary),
                        items: [15, 25, 30, 45, 50, 60, 90, 120]
                            .map((minutes) => DropdownMenuItem<int>(
                          value: minutes,
                          child: Text('$minutes minutes', style: const TextStyle(color: Colors.black87)),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDuration = value!;
                          });
                        },
                        validator: (value) => value == null ? 'Select duration' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Color',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 40,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _availableColors.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final color = _availableColors[index];
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedColor = color),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: _selectedColor == color
                                          ? Border.all(color: Colors.black87, width: 2)
                                          : null,
                                    ),
                                    child: _selectedColor == color
                                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Create Session',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(
        context,
        {
          'subject': _selectedSubject,
          'duration': _selectedDuration,
          'color': _selectedColor,
        },
      );
    }
  }
}