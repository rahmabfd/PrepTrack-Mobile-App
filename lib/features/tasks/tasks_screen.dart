import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../features/auth/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_navbar.dart';
import 'task_model.dart';
import 'task_service.dart';

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

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterSubject = '';
  String _filterCategory = '';
  bool _showCompleted = true;
  bool _sortByNearestDue = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _applyFilters();
      });
    });
  }

  void _loadTasks() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      _taskService.getTasks(authProvider.user!.uid).listen((tasks) {
        setState(() {
          _tasks = tasks;
          _applyFilters();
        });
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTasks = _tasks.where((task) {
        bool matchesSearch = _searchQuery.isEmpty ||
            task.title.toLowerCase().contains(_searchQuery.toLowerCase());
        bool matchesSubject = _filterSubject.isEmpty || task.subject == _filterSubject;
        bool matchesCategory = _filterCategory.isEmpty || task.category == _filterCategory;
        bool matchesCompletionStatus = _showCompleted || !task.isCompleted;

        return matchesSearch && matchesSubject && matchesCategory && matchesCompletionStatus;
      }).toList();

      if (_sortByNearestDue) {
        _filteredTasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      } else {
        _filteredTasks.sort((a, b) => a.priority.compareTo(b.priority));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Assignments'),
        elevation: 2,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          if (authProvider.isLoggedIn)
            PopupMenuButton<String>(
              icon: const Icon(Icons.insert_chart_outlined_rounded),
              onSelected: (value) {}, // No action needed, just displaying stats
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  enabled: false, // Disable interaction, only display
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    width: 200, // Compact width for dropdown
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTaskStat('Total', _tasks.length.toString(), AppColors.primary),
                        _buildTaskStat('Completed', '${_tasks.where((t) => t.isCompleted).length}', Colors.green),
                        _buildTaskStat('Pending', '${_tasks.where((t) => !t.isCompleted).length}', Colors.orange),
                      ],
                    ),
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              elevation: 4,
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search assignments...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintStyle: TextStyle(color: theme.hintColor),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                ),
              ),
            ),
          ),
          if (_tasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _filterSubject.isEmpty,
                      selectedColor: AppColors.primary.withOpacity(0.15),
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        fontWeight: _filterSubject.isEmpty ? FontWeight.bold : FontWeight.normal,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: _filterSubject.isEmpty
                              ? AppColors.primary
                              : theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _filterSubject = '';
                          _applyFilters();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ..._getUniqueSubjects().map((subject) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 0.0),
                        child: FilterChip(
                          label: Text(subject),
                          selected: _filterSubject == subject,
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            fontWeight: _filterSubject == subject ? FontWeight.bold : FontWeight.normal,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _filterSubject == subject
                                  ? AppColors.primary
                                  : theme.colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _filterSubject = selected ? subject : '';
                              _applyFilters();
                            });
                          },
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    ..._getUniqueCategories().map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 0.0),
                        child: FilterChip(
                          label: Text(category),
                          selected: _filterCategory == category,
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            fontWeight: _filterCategory == category ? FontWeight.bold : FontWeight.normal,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _filterCategory == category
                                  ? AppColors.primary
                                  : theme.colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _filterCategory = selected ? category : '';
                              _applyFilters();
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          Expanded(
            child: authProvider.isLoggedIn
                ? (_filteredTasks.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment,
                      size: 80, color: theme.colorScheme.outline.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No assignments yet',
                      style: TextStyle(fontSize: 18, color: theme.colorScheme.outline)),
                  const SizedBox(height: 8),
                  Text('Tap + to add a new assignment',
                      style: TextStyle(
                          fontSize: 14, color: theme.colorScheme.outline.withOpacity(0.7))),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                final task = _filteredTasks[index];
                return _buildTaskItem(task);
              },
            ))
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle,
                      size: 80, color: AppColors.primary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('Sign in to view your assignments',
                      style: TextStyle(fontSize: 18, color: AppColors.primary)),
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
            ),
          ),
        ],
      ),
      floatingActionButton: authProvider.isLoggedIn
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          ).then((_) {
            _searchController.clear();
            _searchQuery = '';
            _applyFilters();
          });
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: authProvider.isLoggedIn ? BottomNavBar(selectedIndex: 2) : null,
    );
  }

  Widget _buildTaskStat(String label, String value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 0) {
      return 'Overdue';
    }
    int days = duration.inDays;
    int hours = duration.inHours % 24;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    if (days > 0) {
      return '$days days $hours hours left';
    } else if (hours > 0) {
      return '$hours hours $minutes minutes left';
    } else if (minutes > 0) {
      return '$minutes minutes $seconds seconds left';
    } else {
      return '$seconds seconds left';
    }
  }

  Widget _buildTaskItem(Task task) {
    final theme = Theme.of(context);
    final bool isOverdue = task.dueDate != null && task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted;

    String countdownText = '';
    if (task.dueDate != null) {
      final now = DateTime.now();
      final duration = task.dueDate!.difference(now);
      countdownText = _formatDuration(duration);
    }

    Color cardColor = task.isCompleted
        ? theme.colorScheme.surfaceVariant.withOpacity(0.5)
        : (isOverdue ? Colors.red.withOpacity(0.1) : task.color);

    print("Task: ${task.title}, Color: ${task.color}, Value: ${task.color.value}");

    return Dismissible(
      key: Key(task.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _taskService.deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Assignment deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                _taskService.addTask(task);
              },
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: Card(
        color: cardColor,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: task.isCompleted
                ? Colors.transparent
                : (isOverdue ? Colors.red.withOpacity(0.3) : Colors.transparent),
            width: 1,
          ),
        ),
        elevation: task.isCompleted ? 0 : 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: task.isCompleted
              ? null
              : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTaskScreen(taskToEdit: task),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Checkbox(
                value: task.isCompleted,
                activeColor: AppColors.primary,
                onChanged: task.isCompleted
                    ? null
                    : (value) {
                  _taskService.updateTask(
                    task.copyWith(isCompleted: value ?? false),
                    context: context,
                  );
                  if (value == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Task completed! Earned 10 points!'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  fontWeight: task.priority == 1 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                  color: task.isCompleted ? theme.hintColor : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.book, size: 14, color: theme.hintColor),
                      const SizedBox(width: 4),
                      Text(
                        task.subject,
                        style: TextStyle(fontSize: 14, color: theme.hintColor),
                      ),
                      const SizedBox(width: 16),
                      if (task.dueDate != null) ...[
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: isOverdue ? Colors.red : theme.hintColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat.yMMMd().format(task.dueDate!),
                          style: TextStyle(
                            fontSize: 14,
                            color: isOverdue ? Colors.red : theme.hintColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: isOverdue ? Colors.red : theme.hintColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          countdownText,
                          style: TextStyle(
                            fontSize: 14,
                            color: isOverdue ? Colors.red : theme.hintColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (task.notes != null && task.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      task.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: _buildPriorityIndicator(task.priority),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(int priority) {
    IconData icon;
    Color color;

    switch (priority) {
      case 1:
        icon = Icons.flag;
        color = Colors.red;
        break;
      case 2:
        icon = Icons.flag;
        color = Colors.orange;
        break;
      case 3:
        icon = Icons.flag;
        color = Colors.blue;
        break;
      default:
        icon = Icons.flag;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 20);
  }

  List<String> _getUniqueSubjects() {
    return _tasks.map((task) => task.subject).toSet().toList();
  }

  List<String> _getUniqueCategories() {
    return _tasks.map((task) => task.category).toSet().toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            return AlertDialog(
              title: Text('Filter Assignments', style: TextStyle(color: AppColors.primary)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subject',
                    style: TextStyle(fontSize: 14, color: theme.hintColor),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    value: _filterSubject.isEmpty ? null : _filterSubject,
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('All Subjects'),
                      ),
                      ..._getUniqueSubjects().map((subject) {
                        return DropdownMenuItem<String>(
                          value: subject,
                          child: Text(subject),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterSubject = value!;
                      });
                    },
                    icon: Icon(Icons.arrow_drop_down_circle, color: AppColors.primary),
                    isExpanded: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Category',
                    style: TextStyle(fontSize: 14, color: theme.hintColor),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    value: _filterCategory.isEmpty ? null : _filterCategory,
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('All Categories'),
                      ),
                      ...['TD', 'TP', 'DS', 'EXAMEN', 'CONCOURS', 'COURSE', 'OTHER'].map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterCategory = value!;
                      });
                    },
                    icon: Icon(Icons.arrow_drop_down_circle, color: AppColors.primary),
                    isExpanded: true,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Sort by Nearest Due Date'),
                    value: _sortByNearestDue,
                    onChanged: (value) {
                      setState(() {
                        _sortByNearestDue = value;
                      });
                    },
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Show Completed Assignments'),
                    value: _showCompleted,
                    onChanged: (value) {
                      setState(() {
                        _showCompleted = value;
                      });
                    },
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: TextStyle(color: theme.colorScheme.secondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Apply'),
                ),
              ],
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({
    super.key,
    this.taskToEdit,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TaskService _taskService = TaskService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  String _selectedSubject = 'General';
  String _selectedCategory = 'TD';
  int _selectedPriority = 2;
  Color _selectedColor = const Color(0xFFE3F2FD);

  final List<Color> pastelColors = [
    const Color(0xFFFFD1DC),
    const Color(0xFFFFECB8),
    const Color(0xFFB5EAD7),
    const Color(0xFFC7CEEA),
    const Color(0xFFE2F0CB),
    const Color(0xFFFFDAC1),
    const Color(0xFFB2B2B2),
    const Color(0xFFD8BFD8),
  ];

  bool get isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.taskToEdit!.title;
      _notesController.text = widget.taskToEdit!.notes ?? '';
      _selectedDueDate = widget.taskToEdit!.dueDate;
      _selectedSubject = widget.taskToEdit!.subject;
      _selectedCategory = widget.taskToEdit!.category;
      _selectedPriority = widget.taskToEdit!.priority;
      _selectedColor = widget.taskToEdit!.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Assignment' : 'Add Assignment'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isEditing)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        'Create New Assignment',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Assignment Title',
                          hintText: 'Enter assignment title',
                          prefixIcon: Icon(Icons.assignment, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        ),
                        style: const TextStyle(fontSize: 16),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an assignment title';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(builder: (context, constraints) {
                    final bool useFullWidth = constraints.maxWidth < 600;
                    final double itemWidth = useFullWidth
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 16) / 2;

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildSubjectDropdown(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildCategoryDropdown(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildPriorityDropdown(),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Color',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 50,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: pastelColors.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final color = pastelColors[index];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedColor = color;
                                    });
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _selectedColor == color ? Colors.black : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: _selectDueDate,
                      borderRadius: BorderRadius.circular(16),
                      splashColor: AppColors.primary.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Due Date',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedDueDate == null
                                      ? 'No date selected'
                                      : DateFormat.yMMMd().add_jm().format(_selectedDueDate!),
                                  style: const TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes (Optional)',
                          hintText: 'Add any additional details',
                          prefixIcon: Icon(Icons.note, color: AppColors.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        ),
                        style: const TextStyle(fontSize: 16),
                        maxLines: 5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        elevation: 3,
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isEditing ? Icons.check : Icons.add),
                          const SizedBox(width: 12),
                          Text(
                            isEditing ? 'Save Changes' : 'Add Assignment',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
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

  Widget _buildSubjectDropdown() {
    final subjects = [
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

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Subject',
        prefixIcon: Icon(Icons.book),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 8),
      ),
      isExpanded: true,
      value: _selectedSubject,
      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
      items: subjects.map((subject) {
        return DropdownMenuItem<String>(
          value: subject,
          child: Text(subject),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSubject = value!;
        });
      },
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = ['TD', 'TP', 'DS', 'EXAMEN', 'CONCOURS', 'COURSE', 'OTHER'];

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 8),
      ),
      isExpanded: true,
      value: _selectedCategory,
      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(
        labelText: 'Priority',
        prefixIcon: Icon(Icons.flag),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 8),
      ),
      isExpanded: true,
      value: _selectedPriority,
      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
      items: [
        DropdownMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.flag, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              const Text('High'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.flag, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              const Text('Medium'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(Icons.flag, color: Colors.blue, size: 18),
              const SizedBox(width: 8),
              const Text('Low'),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedPriority = value!;
        });
      },
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
      _selectDueTime();
    }
  }

  Future<void> _selectDueTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && _selectedDueDate != null) {
      setState(() {
        _selectedDueTime = picked;
        _selectedDueDate = DateTime(
          _selectedDueDate!.year,
          _selectedDueDate!.month,
          _selectedDueDate!.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn) {
        if (isEditing) {
          final updatedTask = widget.taskToEdit!.copyWith(
            title: _titleController.text,
            dueDate: _selectedDueDate,
            subject: _selectedSubject,
            category: _selectedCategory,
            priority: _selectedPriority,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            color: _selectedColor,
          );

          _taskService.updateTask(updatedTask);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Assignment updated'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          final newTask = Task(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: _titleController.text,
            isCompleted: false,
            userId: authProvider.user!.uid,
            dueDate: _selectedDueDate,
            subject: _selectedSubject,
            category: _selectedCategory,
            priority: _selectedPriority,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            color: _selectedColor,
          );

          _taskService.addTask(newTask);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Assignment added'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}