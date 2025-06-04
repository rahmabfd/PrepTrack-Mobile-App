import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_navbar.dart';
import 'timetable_model.dart';
import 'timetable_service.dart';

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

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final TimetableService _timetableService = TimetableService();
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final List<String> _sessionTypes = ['Lecture', 'Tutorial', 'Practical', 'Exam'];
  final List<String> _modules = ['Math', 'Physics', 'STA', 'French', 'English', 'Computer Science'];
  final List<String> _groups = ['A', 'B', 'C', 'D', 'E', 'F'];

  int _selectedDayIndex = DateTime.now().weekday - 1;
  int _currentSemester = 1;
  final Map<String, Color> _moduleColors = {
    'Math': AppColors.bronze,
    'Physics': AppColors.secondary,
    'STA': AppColors.accent,
    'French': AppColors.purple,
    'English': AppColors.tertiary,
    'Computer Science': AppColors.prog,
  };

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schedule',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 2,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddClassScreen()),
            ).then((result) {
              if (result != null && result is TimetableEntry) {
                _timetableService.addTimetableEntry(authProvider.user!.uid, result);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Class added successfully', style: TextStyle(color: AppColors.textPrimary)),
                    backgroundColor: AppColors.backgroundLight,
                  ),
                );
              }
            }),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: authProvider.isLoggedIn
          ? _buildTimetable(authProvider.user!.uid)
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Sign in to view your schedule',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/auth'),
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildTimetable(String userId) {
    return Column(
      children: [
        _buildSemesterAndDaySelector(),
        Expanded(
          child: StreamBuilder<List<TimetableEntry>>(
            stream: _timetableService.getUserTimetable(userId, semester: _currentSemester),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No classes',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddClassScreen()),
                        ),
                        child: Text(
                          'Add Class',
                          style: TextStyle(color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final dayClasses = snapshot.data!
                  .where((entry) => entry.day == _days[_selectedDayIndex])
                  .toList()
                ..sort((a, b) => a.startTime.compareTo(b.startTime));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dayClasses.length,
                itemBuilder: (context, index) {
                  final entry = dayClasses[index];
                  return _buildClassCard(entry, userId);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(TimetableEntry entry, String userId) {
    return GestureDetector(
      onTap: () => _showClassOptions(context, entry, userId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardBackground,
              AppColors.backgroundLight,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _moduleColors[entry.module] ?? entry.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  entry.module,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                if (entry.isDS)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.bronze.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Exam',
                                      style: TextStyle(
                                        color: AppColors.bronze,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              '${entry.sessionType} - Group ${entry.group}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.subject,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.startTime} - ${entry.endTime}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        entry.room,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        entry.teacher,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  if (entry.isDS)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Icon(Icons.school, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Weight: ${entry.coefficient}',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (entry.sessionType == 'Practical' || entry.sessionType == 'Tutorial')
              _buildTpLogSection(entry, userId),
          ],
        ),
      ),
    );
  }

  Widget _buildTpLogSection(TimetableEntry entry, String userId) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Practical/Tutorial Logs',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<TpLog>>(
              stream: _timetableService.getTpLogs(userId, entry.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildAddTpLogButton(entry, userId);
                }

                return Column(
                  children: [
                    ...snapshot.data!.map((log) => _buildTpLogItem(log, userId)),
                    _buildAddTpLogButton(entry, userId),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTpLogItem(TpLog log, String userId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Checkbox(
          value: log.isCompleted,
          activeColor: AppColors.secondary,
          onChanged: (value) {
            _timetableService.updateTpLog(
              userId,
              TpLog(
                id: log.id,
                timetableEntryId: log.timetableEntryId,
                title: log.title,
                isCompleted: value ?? false,
                completedDate: value == true ? DateTime.now() : null,
                notes: log.notes,
                dueDate: log.dueDate,
              ),
            );
          },
        ),
        title: Text(
          log.title,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        subtitle: Text(
          log.isCompleted
              ? 'Completed on ${DateFormat('dd/MM/yyyy').format(log.completedDate!)}'
              : 'Due by ${DateFormat('dd/MM/yyyy').format(log.dueDate)}',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, size: 20, color: AppColors.secondary),
              onPressed: () => _showEditTpLogDialog(context, log, userId),
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 20, color: AppColors.bronze),
              onPressed: () => _deleteTpLog(log, userId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTpLogButton(TimetableEntry entry, String userId) {
    return TextButton.icon(
      icon: Icon(Icons.add, color: AppColors.secondary),
      label: Text(
        'Add Practical/Tutorial',
        style: TextStyle(color: AppColors.secondary),
      ),
      onPressed: () => _showAddTpLogDialog(context, entry, userId),
    );
  }

  void _showAddTpLogDialog(BuildContext context, TimetableEntry entry, String userId) {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text('Add Practical/Tutorial', style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  border: const OutlineInputBorder(),
                ),
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Due Date', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy').format(dueDate),
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    dueDate = date;
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  border: const OutlineInputBorder(),
                ),
                style: TextStyle(color: AppColors.textPrimary),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final log = TpLog(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  timetableEntryId: entry.id,
                  title: titleController.text,
                  dueDate: dueDate,
                  notes: notesController.text,
                );
                _timetableService.addTpLog(userId, log);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTpLogDialog(BuildContext context, TpLog log, String userId) {
    final titleController = TextEditingController(text: log.title);
    final notesController = TextEditingController(text: log.notes);
    DateTime dueDate = log.dueDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              title: Text('Edit Practical/Tutorial', style: TextStyle(color: AppColors.textPrimary)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text('Due Date', style: TextStyle(color: AppColors.textPrimary)),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(dueDate),
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => dueDate = date);
                      }
                    },
                  ),
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(color: AppColors.textPrimary),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updatedLog = TpLog(
                      id: log.id,
                      timetableEntryId: log.timetableEntryId,
                      title: titleController.text,
                      isCompleted: log.isCompleted,
                      completedDate: log.completedDate,
                      notes: notesController.text,
                      dueDate: dueDate,
                    );
                    _timetableService.updateTpLog(userId, updatedLog);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteTpLog(TpLog log, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text('Delete Practical/Tutorial?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('This action is irreversible', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              _timetableService.deleteTpLog(userId, log.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: AppColors.bronze)),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterAndDaySelector() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ToggleButtons(
            isSelected: [_currentSemester == 1, _currentSemester == 2],
            onPressed: (index) {
              setState(() {
                _currentSemester = index + 1;
              });
            },
            selectedColor: Colors.white,
            fillColor: AppColors.primary,
            color: AppColors.textSecondary,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Semester 1'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Semester 2'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                  label: Text(_days[index]),
                  selected: _selectedDayIndex == index,
                  onSelected: (selected) => setState(() => _selectedDayIndex = index),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.backgroundLight,
                  labelStyle: TextStyle(
                    color: _selectedDayIndex == index ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClassCardSimple(TimetableEntry entry, String userId) {
    return GestureDetector(
      onTap: () => _showClassOptions(context, entry, userId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardBackground,
              AppColors.backgroundLight,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _moduleColors[entry.module] ?? entry.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              entry.module,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            if (entry.isDS)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.bronze.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Exam',
                                  style: TextStyle(
                                    color: AppColors.bronze,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '${entry.sessionType} - Group ${entry.group}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                entry.subject,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.startTime} - ${entry.endTime}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    entry.room,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    entry.teacher,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              if (entry.isDS)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Icon(Icons.school, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Weight: ${entry.coefficient}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditClassDialog(BuildContext context, TimetableEntry entry, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddClassScreen(entry: entry),
      ),
    ).then((result) {
      if (result != null && result is TimetableEntry) {
        _timetableService.updateTimetableEntry(userId, result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Class updated successfully', style: TextStyle(color: AppColors.textPrimary)),
            backgroundColor: AppColors.backgroundLight,
          ),
        );
      }
    });
  }

  void _showClassOptions(BuildContext context, TimetableEntry entry, String userId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.secondary),
                title: Text('Edit', style: TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _showEditClassDialog(context, entry, userId);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.bronze),
                title: Text('Delete', style: TextStyle(color: AppColors.bronze)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, entry, userId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  void _showDeleteConfirmation(BuildContext context, TimetableEntry entry, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text('Delete Class?', style: TextStyle(color: AppColors.textPrimary)),
          content: Text(
            'Are you sure you want to delete ${entry.subject}?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                await _timetableService.deleteTimetableEntry(userId, entry.id);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${entry.subject} deleted', style: TextStyle(color: AppColors.textPrimary)),
                    backgroundColor: AppColors.backgroundLight,
                  ),
                );
              },
              child: Text('Delete', style: TextStyle(color: AppColors.bronze)),
            ),
          ],
        );
      },

    );

  }
}

class AddClassScreen extends StatefulWidget {
  final TimetableEntry? entry;

  const AddClassScreen({super.key, this.entry});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedModule;
  String? _selectedSessionType;
  String _subject = '';
  String? _selectedDay;
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  String _room = '';
  String _teacher = '';
  String? _selectedGroup;
  bool _isDS = false;
  double _coefficient = 1.0;
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final List<String> _sessionTypes = ['Lecture', 'Tutorial', 'Practical', 'Exam'];
  final List<String> _modules = ['Math', 'Physics', 'STA', 'French', 'English', 'Computer Science'];
  final List<String> _groups = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _selectedModule = widget.entry!.module;
      _selectedSessionType = widget.entry!.sessionType;
      _subject = widget.entry!.subject;
      _selectedDay = widget.entry!.day;
      _startTime = _parseTime(widget.entry!.startTime);
      _endTime = _parseTime(widget.entry!.endTime);
      _room = widget.entry!.room;
      _teacher = widget.entry!.teacher;
      _selectedGroup = widget.entry!.group;
      _isDS = widget.entry!.isDS;
      _coefficient = widget.entry!.coefficient;
    } else {
      _selectedModule = _modules.first;
      _selectedSessionType = _sessionTypes.first;
      _selectedDay = _days.first;
      _selectedGroup = _groups.first;
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.entry != null ? 'Edit Class' : 'New Class',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
                    widget.entry != null ? 'Edit Class Details' : 'Create New Class',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: AppColors.cardBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Module',
                          prefixIcon: Icon(Icons.book, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        isExpanded: true,
                        value: _selectedModule,
                        icon: Icon(Icons.arrow_drop_down_circle, color: AppColors.primary),
                        items: _modules.map((module) => DropdownMenuItem<String>(
                          value: module,
                          child: Text(module, style: TextStyle(color: AppColors.textPrimary)),
                        )).toList(),
                        onChanged: (value) {
                          setState(() => _selectedModule = value);
                        },
                        validator: (value) => value == null ? 'Select a module' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: AppColors.cardBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Session Type',
                          prefixIcon: Icon(Icons.class_, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        isExpanded: true,
                        value: _selectedSessionType,
                        icon: Icon(Icons.arrow_drop_down_circle, color: AppColors.primary),
                        items: _sessionTypes.map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type, style: TextStyle(color: AppColors.textPrimary)),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSessionType = value;
                            _isDS = value == 'Exam';
                          });
                        },
                        validator: (value) => value == null ? 'Select a session type' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: AppColors.cardBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        initialValue: _subject,
                        decoration: InputDecoration(
                          labelText: 'Subject/Details',
                          prefixIcon: Icon(Icons.description, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        ),
                        style: TextStyle(color: AppColors.textPrimary),
                        onChanged: (value) => _subject = value,
                        validator: (value) => value?.isEmpty ?? true ? 'Subject is required' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: AppColors.cardBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Day',
                          prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        isExpanded: true,
                        value: _selectedDay,
                        icon: Icon(Icons.arrow_drop_down_circle, color: AppColors.primary),
                        items: _days.map((day) => DropdownMenuItem<String>(
                          value: day,
                          child: Text(day, style: TextStyle(color: AppColors.textPrimary)),
                        )).toList(),
                        onChanged: (value) {
                          setState(() => _selectedDay = value);
                        },
                        validator: (value) => value == null ? 'Select a day' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          color: AppColors.cardBackground,
                          child: ListTile(
                            title: Text('Start Time', style: TextStyle(color: AppColors.textPrimary)),
                            subtitle: Text(
                              _formatTimeOfDay(_startTime),
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            leading: Icon(Icons.access_time, color: AppColors.primary),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _startTime,
                              );
                              if (time != null) {
                                setState(() => _startTime = time);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          color: AppColors.cardBackground,
                          child: ListTile(
                            title: Text('End Time', style: TextStyle(color: AppColors.textPrimary)),
                            subtitle: Text(
                              _formatTimeOfDay(_endTime),
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            leading: Icon(Icons.access_time, color: AppColors.primary),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _endTime,
                              );
                              if (time != null) {
                                setState(() => _endTime = time);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: AppColors.cardBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        initialValue: _room,
                        decoration: InputDecoration(
                          labelText: 'Room',
                          prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        ),
                        style: TextStyle(color: AppColors.textPrimary),
                        onChanged: (value) => _room = value,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: AppColors.cardBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        initialValue: _teacher,
                        decoration: InputDecoration(
                          labelText: 'Teacher',
                          prefixIcon: Icon(Icons.person, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        ),
                        style: TextStyle(color: AppColors.textPrimary),
                        onChanged: (value) => _teacher = value,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: AppColors.cardBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Group',
                          prefixIcon: Icon(Icons.group, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        isExpanded: true,
                        value: _selectedGroup,
                        icon: Icon(Icons.arrow_drop_down_circle, color: AppColors.primary),
                        items: _groups.map((group) => DropdownMenuItem<String>(
                          value: group,
                          child: Text('Group $group', style: TextStyle(color: AppColors.textPrimary)),
                        )).toList(),
                        onChanged: (value) {
                          setState(() => _selectedGroup = value);
                        },
                        validator: (value) => value == null ? 'Select a group' : null,
                      ),
                    ),
                  ),
                  if (_isDS) ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: AppColors.cardBackground,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exam Weight',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Slider(
                              value: _coefficient,
                              min: 1,
                              max: 4,
                              divisions: 3,
                              label: _coefficient.toStringAsFixed(1),
                              activeColor: AppColors.secondary,
                              onChanged: (value) => setState(() => _coefficient = value),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                      child: Text(
                        widget.entry != null ? 'Update Class' : 'Create Class',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
      final entry = TimetableEntry(
        id: widget.entry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        subject: _subject,
        module: _selectedModule!,
        day: _selectedDay!,
        startTime: _formatTimeOfDay(_startTime),
        endTime: _formatTimeOfDay(_endTime),
        room: _room,
        teacher: _teacher,
        group: _selectedGroup!,
        sessionType: _selectedSessionType!,
        semester: widget.entry?.semester ?? 1,
        color: AppColors.secondary,
        isDS: _isDS,
        coefficient: _coefficient,
      );
      Navigator.pop(context, entry);
    }
  }
}