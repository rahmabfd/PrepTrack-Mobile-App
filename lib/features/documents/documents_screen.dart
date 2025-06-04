import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/auth_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/app_drawer.dart' show AppDrawer;
import '../../widgets/bottom_navbar.dart';

// Model for DocumentType
class DocumentType {
  final String label;
  final Color color;
  final int count;

  DocumentType(this.label, this.color, this.count);
}

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> with SingleTickerProviderStateMixin {
  String selectedLevel = '1st';
  String selectedTrack = 'MP';
  bool isFilterExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _filterHeightAnimation;
  late TextEditingController _searchController;
  String searchQuery = '';

  final Map<String, Map<String, Map<String, List<String>>>> subjects = {
    '1st': {
      'MP': {
        'Sciences': ['Analysis', 'Algebra', 'Physics', 'Computer Science', 'Inorganic Chemistry'],
        'Others': ['STA'],
        'Languages': ['English', 'French'],
      },
      'PC': {
        'Sciences': ['Analysis', 'Algebra', 'Physics', 'Inorganic Chemistry', 'Organic Chemistry'],
        'Others': ['STA'],
        'Languages': ['English', 'French'],
      },
      'PT': {
        'Sciences': ['Analysis', 'Algebra', 'Physics', 'Inorganic Chemistry'],
        'Technical': ['Mechanical Design', 'CFM'],
        'Others': ['STA'],
        'Languages': ['English', 'French'],
      },
    },
    '2nd': {
      'MP': {
        'Sciences': ['Analysis', 'Algebra', 'Physics', 'Computer Science', 'Inorganic Chemistry'],
        'Others': ['STA'],
        'Languages': ['English', 'French'],
      },
      'PC': {
        'Sciences': ['Analysis', 'Algebra', 'Physics', 'Inorganic Chemistry', 'Organic Chemistry'],
        'Others': ['STA'],
        'Languages': ['English', 'French'],
      },
      'PT': {
        'Sciences': ['Analysis', 'Algebra', 'Physics', 'Inorganic Chemistry'],
        'Technical': ['Mechanical Design', 'CFM'],
        'Others': ['STA'],
        'Languages': ['English', 'French'],
      },
    },
  };

  final Map<String, IconData> subjectIcons = {
    'Analysis': Icons.analytics,
    'Algebra': Icons.calculate,
    'Physics': Icons.science,
    'Computer Science': Icons.computer,
    'Inorganic Chemistry': Icons.science,
    'Organic Chemistry': Icons.biotech,
    'STA': Icons.calculate,
    'English': Icons.language,
    'French': Icons.menu_book,
    'Mechanical Design': Icons.engineering,
    'CFM': Icons.engineering,
  };

  final Map<String, List<DocumentType>> _subjectDocuments = {
    'Analysis': [
      DocumentType('Supervised Tests', Colors.blue, 10),
      DocumentType('Exams', Colors.red, 6),
      DocumentType('TD', Colors.purple, 15),
    ],
    'Algebra': [
      DocumentType('Supervised Tests', Colors.blue, 10),
      DocumentType('Exams', Colors.green, 20),
      DocumentType('TD', Colors.red, 6),
    ],
    'Physics': [
      DocumentType('Supervised Tests', Colors.blue, 10),
      DocumentType('Exams', Colors.purple, 15),
      DocumentType('TD', Colors.red, 6),
    ],
    'Computer Science': [
      DocumentType('Supervised Tests', Colors.blue, 8),
      DocumentType('Exams', Colors.orange, 12),
      DocumentType('TD', Colors.red, 5),
    ],
    'Inorganic Chemistry': [
      DocumentType('Supervised Tests', Colors.blue, 9),
      DocumentType('Exams', Colors.purple, 10),
      DocumentType('TD', Colors.red, 4),
    ],
    'Organic Chemistry': [
      DocumentType('Supervised Tests', Colors.blue, 7),
      DocumentType('Exams', Colors.purple, 8),
      DocumentType('TD', Colors.red, 3),
    ],
    'STA': [
      DocumentType('Supervised Tests', Colors.blue, 6),
      DocumentType('Exams', Colors.green, 10),
      DocumentType('TD', Colors.red, 4),
    ],
    'English': [
      DocumentType('Supervised Tests', Colors.blue, 5),
      DocumentType('Exams', Colors.green, 8),
      DocumentType('TD', Colors.red, 3),
    ],
    'French': [
      DocumentType('Supervised Tests', Colors.blue, 5),
      DocumentType('Exams', Colors.green, 7),
      DocumentType('TD', Colors.red, 3),
    ],
    'Mechanical Design': [
      DocumentType('Supervised Tests', Colors.blue, 7),
      DocumentType('Exams', Colors.orange, 9),
      DocumentType('TD', Colors.red, 4),
    ],
    'CFM': [
      DocumentType('Supervised Tests', Colors.blue, 7),
      DocumentType('Exams', Colors.orange, 9),
      DocumentType('TD', Colors.red, 4),
    ],
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _filterHeightAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<String>> get filteredSubjects {
    final subjectCategories = subjects[selectedLevel]?[selectedTrack] ?? {};
    final Map<String, List<String>> filtered = {};

    for (var category in subjectCategories.keys) {
      final subjectsList = subjectCategories[category] ?? [];
      if (searchQuery.isEmpty) {
        filtered[category] = subjectsList;
      } else {
        filtered[category] = subjectsList
            .where((subject) => subject.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      }
    }

    return filtered;
  }

  List<DocumentType> _getDocumentTypesForSubject(String subject) {
    List<DocumentType> baseDocuments = _subjectDocuments[subject] ?? [
      DocumentType('Supervised Tests', Colors.blue, 5),
      DocumentType('Exams', Colors.green, 8),
      DocumentType('TD', Colors.red, 3),
    ];

    if (selectedLevel == '2nd') {
      if (!baseDocuments.any((doc) => doc.label == 'National Exams')) {
        baseDocuments.add(DocumentType('National Exams', Colors.orange, _getRandomDocumentCount()));
      }
    }

    return baseDocuments;
  }

  int _getRandomDocumentCount() {
    return 5 + (DateTime.now().millisecondsSinceEpoch % 15);
  }

  void _toggleFilterPanel() {
    setState(() {
      isFilterExpanded = !isFilterExpanded;
    });

    if (isFilterExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _navigateToSubjectDetails(BuildContext context, String subject) {
    // Placeholder for navigation logic, assuming handled elsewhere
    // You can integrate with your existing navigation setup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Color(0xFF5D5FEF),
        elevation: 0,
        title: const Text(
          'Documents',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: _toggleFilterPanel,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$selectedLevel • $selectedTrack',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isFilterExpanded ? Icons.expand_less : Icons.tune,
                        color: const Color(0xFF3B82F6),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search for documents...',
                  hintStyle: TextStyle(
                    color: const Color(0xFF6B7280).withOpacity(0.8),
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF3B82F6),
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF6B7280)),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        searchQuery = '';
                      });
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  heightFactor: _filterHeightAnimation.value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedLevel = '1st';
                              selectedTrack = 'MP';
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Level',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                    width: 1,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedLevel,
                                    isExpanded: true,
                                    isDense: true,
                                    icon: const Icon(
                                      Icons.expand_more_rounded,
                                      size: 20,
                                      color: Color(0xFF6B7280),
                                    ),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => selectedLevel = value);
                                      }
                                    },
                                    items: ['1st', '2nd']
                                        .map((level) => DropdownMenuItem(
                                      value: level,
                                      child: Text(
                                        level,
                                        style: const TextStyle(
                                          color: Color(0xFF111827),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Track',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                    width: 1,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedTrack,
                                    isExpanded: true,
                                    isDense: true,
                                    icon: const Icon(
                                      Icons.expand_more_rounded,
                                      size: 20,
                                      color: Color(0xFF6B7280),
                                    ),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() => selectedTrack = value);
                                      }
                                    },
                                    items: ['MP', 'PC', 'PT']
                                        .map((track) => DropdownMenuItem(
                                      value: track,
                                      child: Text(
                                        track,
                                        style: const TextStyle(
                                          color: Color(0xFF111827),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _toggleFilterPanel,
                            icon: const Icon(
                              Icons.check,
                              size: 18,
                            ),
                            label: const Text(
                              'Apply',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF3B82F6),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: _toggleFilterPanel,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  'Available Subjects',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${filteredSubjects.values.fold(0, (sum, list) => sum + list.length)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort, color: Color(0xFF6B7280)),
                  tooltip: 'Sort by',
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'name',
                      child: Text('Sort by name'),
                    ),
                    const PopupMenuItem(
                      value: 'recent',
                      child: Text('Most recent first'),
                    ),
                  ],
                  onSelected: (value) {
                    // TODO: Implement sorting logic
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredSubjects.values.every((list) => list.isEmpty)
                ? _buildEmptyState()
                : _buildSubjectsList(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 4),
    );
  }

  Widget _buildSubjectsList() {
    final categories = filteredSubjects;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: categories.keys.length,
      itemBuilder: (context, index) {
        final category = categories.keys.elementAt(index);
        final subjects = categories[category] ?? [];

        if (subjects.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            ...subjects.map((subject) {
              final icon = subjectIcons[subject] ?? Icons.book;
              final color = _getSubjectColor(subject);
              final docTypes = _getDocumentTypesForSubject(subject);
              final docCount = docTypes.fold(0, (sum, type) => sum + type.count);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _navigateToSubjectDetails(context, subject);
                    },
                    borderRadius: BorderRadius.circular(12),
                    splashColor: color.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              icon,
                              color: color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$docCount documents available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF6B7280).withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: docTypes
                                      .map((type) => _buildDocTypeChip(type.label, type.color, type.count))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF9CA3AF),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildDocTypeChip(String label, Color color, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: const Color(0xFF6B7280).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6B7280).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different search terms\nor adjust your filters',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF6B7280).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchController.clear();
                searchQuery = '';
                selectedLevel = '1st';
                selectedTrack = 'MP';
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFF3B82F6),
              backgroundColor: const Color(0xFFEFF6FF),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Analysis':
      case 'Algebra':
        return const Color(0xFF3B82F6);
      case 'Physics':
        return const Color(0xFFF59E0B);
      case 'Computer Science':
      case 'Inorganic Chemistry':
      case 'Organic Chemistry':
        return const Color(0xFF10B981);
      case 'Mechanical Design':
      case 'CFM':
        return const Color(0xFF8B5CF6);
      case 'English':
      case 'French':
        return const Color(0xFFEC4899);
      case 'STA':
        return const Color(0xFF6B7280);
      default:
        return HSLColor.fromAHSL(1, (subject.hashCode % 360).toDouble(), 0.7, 0.6).toColor();
    }
  }
}