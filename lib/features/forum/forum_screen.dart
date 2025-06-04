import 'package:flutter/material.dart';
import 'package:pfa/features/auth/auth_provider.dart';
import 'package:pfa/features/forum/answer_model.dart';
import 'package:pfa/features/forum/question_model.dart';
import 'package:pfa/features/forum/question_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_navbar.dart';

class AppColors {
  static const Color primary = Color(0xFF5D5FEF);
  static const Color secondary = Color(0xFF10B981);
  static const Color tertiary = Color(0xFFF59E0B);
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color backgroundDark = Color(0xFF1E293B);
  static const Color cardBackground = Colors.white;
  static const Color accent = Color(0xFF00BFA5);
  static const Color purple = Color(0xFFAB47BC);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  static const Color platinum = Color(0xFFE5E4E2);
  static const Color prog = Color(0xFF20B2AA);
}

class ForumScreen extends StatefulWidget {
  const ForumScreen({Key? key}) : super(key: key);

  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final _searchController = TextEditingController();
  String? _selectedSubject;
  String? _selectedLevel;
  String? _selectedQuestionId;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _answerController = TextEditingController();
  bool _showPostQuestion = false;
  bool _showPostAnswer = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QuestionService(),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.backgroundLight,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            scaffoldBackgroundColor: AppColors.backgroundLight,
            textTheme: Theme.of(context).textTheme.apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
            cardColor: AppColors.cardBackground,
            hintColor: AppColors.textSecondary,
          );

          return Scaffold(
            appBar: AppBar(
              title: const Text('Community Forum'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,

            ),
            drawer: const AppDrawer(),
            body: Column(
              children: [
                _buildSearchBar(context, theme),
                if (_showPostQuestion)
                  _buildPostQuestionForm(context, theme)
                else if (_showPostAnswer && _selectedQuestionId != null)
                  _buildPostAnswerForm(context, theme)
                else if (_selectedQuestionId != null)
                    _buildQuestionDetails(context, theme)
                  else
                    _buildQuestionList(context, theme),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showPostQuestion = true;
                  _showPostAnswer = false;
                  _selectedQuestionId = null;
                  _titleController.clear();
                  _contentController.clear();
                });
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            ),
            bottomNavigationBar: BottomNavBar(selectedIndex: 4),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search questions...',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showFilterDialog(context, theme),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.filter_list, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList(BuildContext context, ThemeData theme) {
    final questionService = Provider.of<QuestionService>(context);
    return Expanded(
      child: StreamBuilder<List<QuestionModel>>(
        stream: questionService.searchQuestions(
          _searchController.text,
          subject: _selectedSubject,
          level: _selectedLevel,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No questions found',
                style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final question = snapshot.data![index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      _selectedQuestionId = question.id;
                      _showPostQuestion = false;
                      _showPostAnswer = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.1),

                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Chip(
                              label: Text(question.subject),
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              labelStyle: TextStyle(color: AppColors.primary),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(question.level),
                              backgroundColor: AppColors.secondary.withOpacity(0.1),
                              labelStyle: TextStyle(color: AppColors.secondary),
                            ),
                            const Spacer(),
                            Text(
                              '${question.answersCount} answers',
                              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildQuestionDetails(BuildContext context, ThemeData theme) {
    if (_selectedQuestionId == null) {
      return Expanded(
        child: Center(
          child: Text(
            'No question selected',
            style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    final questionService = Provider.of<QuestionService>(context);
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.cardBackground,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.primary),
                    onPressed: () {
                      setState(() {
                        _selectedQuestionId = null;
                        _showPostAnswer = false;
                      });
                    },
                  ),
                  Text(
                    'Back to Questions',
                    style: theme.textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuestionModel?>(
              stream: questionService.getQuestionById(_selectedQuestionId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Text(
                      'Question not found',
                      style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }
                final question = snapshot.data!;
                return Column(
                  children: [
                    _buildQuestionContent(question, theme),
                    _buildAnswersSection(question, questionService, context, theme),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_comment),
                        label: const Text('Add Answer'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPostAnswer = true;
                            _answerController.clear();
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent(QuestionModel question, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    'G',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.authorName.isNotEmpty ? question.authorName : 'Ghaida',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${question.timestamp.day}/${question.timestamp.month}/${question.timestamp.year}',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(question.subject),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppColors.primary),
                ),
                Chip(
                  label: Text(question.level),
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppColors.secondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question.description,
              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswersSection(
      QuestionModel question, QuestionService questionService, BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Answers (${question.answersCount})',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<AnswerModel>>(
            stream: questionService.getAnswersForQuestion(question.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No answers yet',
                    style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final answer = snapshot.data![index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.secondary.withOpacity(0.1),

                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    answer.authorName.isNotEmpty ? answer.authorName : 'Rahma',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${answer.timestamp.day}/${answer.timestamp.month}/${answer.timestamp.year}',
                                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            answer.content,
                            style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostQuestionForm(BuildContext context, ThemeData theme) {
    final questionService = Provider.of<QuestionService>(context, listen: false);
    final _formKey = GlobalKey<FormState>();
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask a Question',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Question Title',
                        hintText: 'Enter your question title',
                        prefixIcon: Icon(Icons.question_answer, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                      ),
                      validator: (value) => value?.isEmpty == true ? 'Please enter a title' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        prefixIcon: Icon(Icons.book, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                      ),
                      value: _selectedSubject,
                      items: const [
                        DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics')),
                        DropdownMenuItem(value: 'Physics', child: Text('Physics')),
                        DropdownMenuItem(value: 'Chemistry', child: Text('Chemistry')),
                        DropdownMenuItem(value: 'Computer Science', child: Text('Computer Science')),
                        DropdownMenuItem(value: 'Engineering Sciences', child: Text('Engineering Sciences')),
                        DropdownMenuItem(value: 'French', child: Text('French')),
                        DropdownMenuItem(value: 'Philosophy', child: Text('Philosophy')),
                        DropdownMenuItem(value: 'Languages', child: Text('Languages')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) => setState(() => _selectedSubject = value),
                      validator: (value) => value == null ? 'Please select a subject' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Level',
                        prefixIcon: Icon(Icons.school, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                      ),
                      value: _selectedLevel,
                      items: const [
                        DropdownMenuItem(value: '1st Year', child: Text('1st Year')),
                        DropdownMenuItem(value: '2nd Year', child: Text('2nd Year')),
                      ],
                      onChanged: (value) => setState(() => _selectedLevel = value),
                      validator: (value) => value == null ? 'Please select a level' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        labelText: 'Question Details',
                        hintText: 'Describe your question in detail',
                        prefixIcon: Icon(Icons.description, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                      ),
                      maxLines: 6,
                      validator: (value) => value?.isEmpty == true ? 'Please provide details' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedSubject == null || _selectedLevel == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please select both subject and level'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      try {
                        final user = firebase_auth.FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Please log in to post a question'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        final questionService = Provider.of<QuestionService>(context, listen: false);
                        final initialPoints = authProvider.points;
                        final initialBadge = authProvider.badge;
                        await questionService.postQuestion(
                          title: _titleController.text,
                          description: _contentController.text,
                          subject: _selectedSubject!,
                          level: _selectedLevel!,
                          context: context,
                        );
                        final newPoints = authProvider.points;
                        final newBadge = authProvider.badge;
                        setState(() {
                          _showPostQuestion = false;
                          _titleController.clear();
                          _contentController.clear();
                          _selectedSubject = null;
                          _selectedLevel = null;
                        });
                        String message = 'Question posted successfully! +5 points';
                        if (newPoints > initialPoints && newBadge != initialBadge) {
                          message += ' (New badge: ${newBadge.toString().split('.').last})';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            backgroundColor: AppColors.secondary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Post Question'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() {
                    _showPostQuestion = false;
                    _selectedSubject = null;
                    _selectedLevel = null;
                  }),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostAnswerForm(BuildContext context, ThemeData theme) {
    if (_selectedQuestionId == null) {
      return Expanded(
        child: Center(
          child: Text(
            'No question selected',
            style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }
    final questionService = Provider.of<QuestionService>(context, listen: false);
    final _formKey = GlobalKey<FormState>();
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share Your Answer',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _answerController,
                      decoration: InputDecoration(
                        labelText: 'Your Answer',
                        hintText: 'Provide your answer in detail',
                        prefixIcon: Icon(Icons.comment, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                      ),
                      maxLines: 5,
                      validator: (value) => value?.isEmpty == true ? 'Please enter an answer' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final user = firebase_auth.FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Please log in to post an answer'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        final questionService = Provider.of<QuestionService>(context, listen: false);
                        final initialPoints = authProvider.points;
                        final initialBadge = authProvider.badge;
                        await questionService.postAnswer(
                          questionId: _selectedQuestionId!,
                          content: _answerController.text,
                          context: context,
                        );
                        final newPoints = authProvider.points;
                        final newBadge = authProvider.badge;
                        setState(() {
                          _showPostAnswer = false;
                          _answerController.clear();
                        });
                        String message = 'Answer posted successfully! +3 points';
                        if (newPoints > initialPoints && newBadge != initialBadge) {
                          message += ' (New badge: ${newBadge.toString().split('.').last})';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            backgroundColor: AppColors.secondary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Post Answer'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _showPostAnswer = false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) {
        String? tempSubject = _selectedSubject;
        String? tempLevel = _selectedLevel;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Filter Questions',
            style: theme.textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                ),
                value: tempSubject,
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics')),
                  DropdownMenuItem(value: 'Physics', child: Text('Physics')),
                  DropdownMenuItem(value: 'Chemistry', child: Text('Chemistry')),
                  DropdownMenuItem(value: 'Computer Science', child: Text('Computer Science')),
                  DropdownMenuItem(value: 'Engineering Sciences', child: Text('Engineering Sciences')),
                  DropdownMenuItem(value: 'French', child: Text('French')),
                  DropdownMenuItem(value: 'Philosophy', child: Text('Philosophy')),
                  DropdownMenuItem(value: 'Languages', child: Text('Languages')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) => tempSubject = value,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Level',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                ),
                value: tempLevel,
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: '1st Year', child: Text('1st Year')),
                  DropdownMenuItem(value: '2nd Year', child: Text('2nd Year')),
                ],
                onChanged: (value) => tempLevel = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedSubject = tempSubject;
                  _selectedLevel = tempLevel;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _answerController.dispose();
    super.dispose();
  }
}