import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../features/auth/auth_provider.dart';
import '../../widgets/bottom_navbar.dart'; // Ensure this path matches your project structure

class DeadlineTrackerPage extends StatefulWidget {
  const DeadlineTrackerPage({super.key});

  @override
  State<DeadlineTrackerPage> createState() => _DeadlineTrackerPageState();
}

class _DeadlineTrackerPageState extends State<DeadlineTrackerPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  String _type = 'DS';
  String _subject = 'Analysis';
  String _typeFilter = 'All';
  String _subjectFilter = 'All';

  final List<String> subjects = [
    'Analysis',
    'Algebra',
    'Physics',
    'General Chemistry',
    'Organic Chemistry',
    'English',
    'French',
    'Computer Science',
    'STA',
  ];

  final Map<String, Color> typeColors = {
    'DS': Color(0xFF5D5FEF),       // Purple
    'Exam': Color(0xFF00BFA5),     // Teal
    'Concours': Color(0xFFF85C50), // Coral
    'Test': Color(0xFFAB47BC),     // Magenta
    'TP Exam': Color(0xFF0288D1),  // Blue
    'TD Evaluation': Color(0xFF7CB342), // Green
  };

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5D5FEF),
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  void _addDeadline(String userId) {
    if (_formKey.currentState!.validate()) {
      final parsedDate = DateFormat('dd/MM/yyyy').parse(_dateController.text);
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('deadlines')
          .add({
        'date': Timestamp.fromDate(parsedDate),
        'type': _type,
        'subject': _subject,
        'createdAt': Timestamp.now(),
      });
      _dateController.clear();
      setState(() {
        _type = 'DS';
        _subject = 'Analysis';
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Deadline added'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _cancelForm() {
    _dateController.clear();
    setState(() {
      _type = 'DS';
      _subject = 'Analysis';
    });
    Navigator.of(context).pop();
  }

  void _showAddDeadlineDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Add Deadline',
            style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF5D5FEF)),
                  ),
                  onTap: () => _selectDate(context),
                  validator: (value) => value!.isEmpty ? 'Please select a date' : null,
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: ['DS', 'Exam', 'Concours', 'Test', 'TP Exam', 'TD Evaluation']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => _type = value!),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _subject,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: subjects
                      .map((subject) => DropdownMenuItem(value: subject, child: Text(subject)))
                      .toList(),
                  onChanged: (value) => setState(() => _subject = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _cancelForm,
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => _addDeadline(userId),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5D5FEF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String docId, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Delete Deadline', style: TextStyle(fontWeight: FontWeight.w600)),
          content: Text('Are you sure you want to delete this deadline?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('deadlines')
                    .doc(docId)
                    .delete();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Deadline deleted'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _calculateTimeLeft(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    if (difference.isNegative) return 'Expired';

    final days = difference.inDays;
    final hours = difference.inHours % 24;

    if (days > 0) return '$days ${days == 1 ? 'day' : 'days'}';
    return '$hours ${hours == 1 ? 'hour' : 'hours'}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;
    final isAuthenticated = authProvider.isLoggedIn;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(

        title: const Text(
          'Deadlines',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true, // Fixed 'personally' typo
        backgroundColor: Color(0xFF5D5FEF),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Color(0xFF5D5FEF)),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: !isAuthenticated || userId == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle,
                size: 80,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Sign in to view your deadlines',
              style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/auth'),
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('deadlines')
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading deadlines',
                    style: TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Color(0xFF5D5FEF)));
          }

          final deadlines = snapshot.data!.docs.where((doc) {
            final typeMatch = _typeFilter == 'All' || doc['type'] == _typeFilter;
            final subjectMatch =
                _subjectFilter == 'All' || doc['subject'] == _subjectFilter;
            return typeMatch && subjectMatch;
          }).toList();

          if (deadlines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note,
                      size: 80,
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No deadlines yet',
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.outline),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a new deadline',
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.7)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: deadlines.length,
            itemBuilder: (context, index) {
              final deadline = deadlines[index];
              return _buildTimelineItem(
                  deadline, index == 0, index == deadlines.length - 1, userId);
            },
          );
        },
      ),
      floatingActionButton: isAuthenticated && userId != null
          ? FloatingActionButton(
        onPressed: () => _showAddDeadlineDialog(context, userId),
        backgroundColor: Color(0xFF5D5FEF),
        child: Icon(Icons.add, color: Colors.white),
      )
          : null,
      bottomNavigationBar: BottomNavBar(selectedIndex: 4),
    );
  }

  Widget _buildTimelineItem(
      DocumentSnapshot deadline, bool isFirst, bool isLast, String userId) {
    final date = (deadline['date'] as Timestamp).toDate();
    final formattedDate = DateFormat('dd MMM yyyy').format(date);
    final dayName = DateFormat('EEEE').format(date);
    final timeLeft = _calculateTimeLeft(date);
    final isExpired = timeLeft == 'Expired';
    final isUrgent = !isExpired && date.difference(DateTime.now()).inDays <= 3;
    final color = typeColors[deadline['type']] ?? Color(0xFF5D5FEF);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dot and line
        Column(
          children: [
            if (!isFirst) SizedBox(height: 16),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isExpired ? Colors.red : isUrgent ? Colors.orange : color,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: Colors.grey[300],
              ),
          ],
        ),
        SizedBox(width: 16),
        // Deadline card
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      deadline['subject'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isExpired ? Colors.grey : Color(0xFF1A1A1A),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.grey[400], size: 20),
                      onPressed: () =>
                          _showDeleteConfirmation(context, deadline.id, userId),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    deadline['type'],
                    style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      isExpired
                          ? Icons.event_busy
                          : isUrgent
                          ? Icons.timelapse
                          : Icons.event_available,
                      size: 16,
                      color: isExpired
                          ? Colors.red
                          : isUrgent
                          ? Colors.orange
                          : Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      timeLeft,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isExpired
                            ? Colors.red
                            : isUrgent
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '$dayName, $formattedDate',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  void _showFilterDialog(BuildContext context) {
    String localTypeFilter = ['All', 'DS', 'Exam', 'Concours', 'Test', 'TP Exam', 'TD Evaluation'].contains(_typeFilter)
        ? _typeFilter
        : 'All';
    String localSubjectFilter = ['All', ...subjects].contains(_subjectFilter)
        ? _subjectFilter
        : 'All';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Filter Deadlines', style: TextStyle(fontWeight: FontWeight.w600)),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: localTypeFilter,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: ['All', 'DS', 'Exam', 'Concours', 'Test', 'TP Exam', 'TD Evaluation']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => localTypeFilter = value!);
                      setState(() => _typeFilter = value!);
                    },
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: localSubjectFilter,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: ['All', ...subjects]
                        .map((subject) => DropdownMenuItem(value: subject, child: Text(subject)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() => localSubjectFilter = value!);
                      setState(() => _subjectFilter = value!);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }
}