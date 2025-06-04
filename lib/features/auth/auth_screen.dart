import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

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

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _schoolController = TextEditingController();
  final _classController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _ageController.dispose();
    _schoolController.dispose();
    _classController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFormMode() {
    setState(() {
      _isLogin = !_isLogin;
      _animationController.reset();
      _animationController.forward();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      if (_isLogin) {
        await authProvider.signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/");
        }
      } else {
        await authProvider.signUpWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          surname: _surnameController.text,
          age: _ageController.text,
          school: _schoolController.text,
          studentClass: _classController.text,
        );
        _passwordController.clear();
        _nameController.clear();
        _surnameController.clear();
        _ageController.clear();
        _schoolController.clear();
        _classController.clear();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isLogin = true;
              _animationController.reset();
              _animationController.forward();
            });
          }
        });
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      _showError('Please enter an email');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      _showError('Please enter a valid email');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.resetPassword(_emailController.text);
      _showError('Password reset email sent');
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.bronze,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
      Positioned.fill(
      child: CustomPaint(
      painter: BackgroundPainter(
        AppColors.primary,
        AppColors.accent,
        AppColors.purple,
      ),
    ),
    ),
    Center(
    child: SingleChildScrollView(
    padding: EdgeInsets.symmetric(
    horizontal: isSmallScreen ? 24.0 : size.width * 0.15,
    vertical: 24.0,
    ),
    child: FadeTransition(
    opacity: _fadeAnimation,
    child: Card(
    elevation: 10,
    shadowColor: AppColors.primary.withOpacity(0.4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    color: AppColors.cardBackground,
    child: Padding(
    padding: const EdgeInsets.all(32.0),
    child: Form(
    key: _formKey,
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    Hero(
    tag: 'auth_icon',
    child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: AppColors.primary.withOpacity(0.2),
    shape: BoxShape.circle,
    ),
    child: Icon(
    _isLogin ? Icons.lock_open_rounded : Icons.person_add_alt_1,
    size: 45,
    color: AppColors.primary,
    ),
    ),
    ),
    const SizedBox(height: 24),
    Text(
    _isLogin ? 'Welcome' : 'Create an Account',
    style: const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
    ),
    ),
    const SizedBox(height: 8),
    Text(
    _isLogin ? 'Sign in to continue' : 'Sign up to get started',
    style: TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
    ),
    ),
    const SizedBox(height: 32),
    TextFormField(
    controller: _emailController,
    decoration: InputDecoration(
    labelText: 'Email',
    labelStyle: TextStyle(color: AppColors.textSecondary),
    prefixIcon: Icon(Icons.email_outlined, color: AppColors.accent),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.silver),
    ),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.silver),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    filled: true,
    fillColor: AppColors.platinum.withOpacity(0.1),
    ),
    keyboardType: TextInputType.emailAddress,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter an email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'Please enter a valid email';
    }
    return null;
    },
    ),
    const SizedBox(height: 20),
    TextFormField(
    controller: _passwordController,
    decoration: InputDecoration(
    labelText: 'Password',
    labelStyle: TextStyle(color: AppColors.textSecondary),
    prefixIcon: Icon(Icons.lock_outline, color: AppColors.accent),
    suffixIcon: IconButton(
    icon: Icon(
    _obscurePassword ? Icons.visibility_off : Icons.visibility,
    color: AppColors.silver,
    ),
    onPressed: () {
    setState(() {
    _obscurePassword = !_obscurePassword;
    });
    },
    ),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.silver),
    ),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.silver),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    filled: true,
    fillColor: AppColors.platinum.withOpacity(0.1),
    ),
    obscureText: _obscurePassword,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter a password';
    }
    if (!_isLogin && value.length < 6) {
    return 'Password must be at least 6 characters';
    }
    return null;
    },
    ),
    if (!_isLogin) ...[
    const SizedBox(height: 20),
    TextFormField(
    controller: _nameController,
    decoration: InputDecoration(
    labelText: 'First Name',
    labelStyle: TextStyle(color: AppColors.textSecondary),
    prefixIcon: Icon(Icons.person_outline, color: AppColors.accent),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.silver),
    ),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.silver),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    filled: true,
    fillColor: AppColors.platinum.withOpacity(0.1),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your first name';
    }
    return null;
    },
    ),
    const SizedBox(height: 20),
    TextFormField(
    controller: _surnameController,
    decoration: InputDecoration(
    labelText: 'Surname',
    labelStyle: TextStyle(color: AppColors.textSecondary),
    prefixIcon: Icon(Icons.person_outline, color: AppColors.accent),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.silver),
    ),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.silver),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    filled: true,
    fillColor: AppColors.platinum.withOpacity(0.1),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your surname';
    }
    return null;
    },
    ),
    const SizedBox(height: 20),
    TextFormField(
    controller: _ageController,
    decoration: InputDecoration(
    labelText: 'Age',
    labelStyle: TextStyle(color: AppColors.textSecondary),
    prefixIcon: Icon(Icons.cake_outlined, color: AppColors.accent),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.silver),
    ),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.silver),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    filled: true,
    fillColor: AppColors.platinum.withOpacity(0.1),
    ),
    keyboardType: TextInputType.number,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your age';
    }
    if (int.tryParse(value) == null || int.parse(value) <= 0) {
    return 'Please enter a valid age';
    }
    return null;
    },
    ),
    const SizedBox(height: 20),
    TextFormField(
    controller: _schoolController,
    decoration: InputDecoration(
    labelText: 'Preparatory School',
    labelStyle: TextStyle(color: AppColors.textSecondary),
    prefixIcon: Icon(Icons.school_outlined, color: AppColors.accent),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.silver),
    ),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.silver),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    filled: true,
    fillColor: AppColors.platinum.withOpacity(0.1),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your school';
    }
    return null;
    },
    ),
    const SizedBox(height: 20),
    TextFormField(
    controller: _classController,
    decoration: InputDecoration(
    labelText: 'Class',
    labelStyle: TextStyle(color: AppColors.textSecondary),
    prefixIcon: Icon(Icons.class_outlined, color: AppColors.accent),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.silver),
    ),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.silver),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    filled: true,
    fillColor: AppColors.platinum.withOpacity(0.1),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please enter your class';
    }
    return null;
    },
    ),
    ],
    if (_isLogin)
    Align(
    alignment: Alignment.centerRight,
    child: TextButton(
    onPressed: _resetPassword,
    style: TextButton.styleFrom(
    foregroundColor: AppColors.purple,
    ),
    child: const Text(
    'Forgot Password?',
    style: TextStyle(
    fontWeight: FontWeight.w500,
    ),
    ),
    ),
    ),
    const SizedBox(height: 30),
    Consumer<AuthProvider>(
    builder: (context, authProvider, child) {
    return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.cardBackground,
    elevation: 3,
    shadowColor: AppColors.primary.withOpacity(0.5),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    ),
    ),
    onPressed: authProvider.isLoading ? null : _submit,
    child: authProvider.isLoading
    ? const SizedBox(
    height: 24,
    width: 24,
    child: CircularProgressIndicator(
    strokeWidth: 3,
    color: AppColors.cardBackground,
    ),
    )
        : Text(
    _isLogin ? 'Sign In' : 'Sign Up',
    style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    ),
    ),
    ),
    );
    },
    ),
    const SizedBox(height: 20),
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    _isLogin ? 'New here? ' : 'Already registered? ',
    style: const TextStyle(color: AppColors.textSecondary),
    ),
    TextButton(
    onPressed: _toggleFormMode,
    style: TextButton.styleFrom(
    foregroundColor: AppColors.purple,
    padding: EdgeInsets.zero,
    minimumSize: const Size(0, 30),
    ),
    child: Text(
    _isLogin ? 'Create an account' : 'Sign in',
    style: const TextStyle(
    fontWeight: FontWeight.bold,
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
    ),
    ),
    ),
    ],
    ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  BackgroundPainter(this.primaryColor, this.secondaryColor, this.accentColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.backgroundLight,
          secondaryColor.withOpacity(0.3),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.25);
    path.quadraticBezierTo(
      size.width * 0.20,
      size.height * 0.32,
      size.width * 0.5,
      size.height * 0.15,
    );
    path.quadraticBezierTo(
      size.width * 0.80,
      size.height * 0.05,
      size.width,
      size.height * 0.12,
    );
    path.lineTo(size.width, 0);
    path.close();

    final wavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryColor,
          primaryColor.withOpacity(0.7),
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height * 0.3));

    canvas.drawPath(path, wavePaint);

    final bottomPath = Path();
    bottomPath.moveTo(0, size.height);
    bottomPath.lineTo(0, size.height * 0.85);
    bottomPath.quadraticBezierTo(
      size.width * 0.30,
      size.height * 0.95,
      size.width * 0.6,
      size.height * 0.85,
    );
    bottomPath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.78,
      size.width,
      size.height * 0.8,
    );
    bottomPath.lineTo(size.width, size.height);
    bottomPath.close();

    final bottomWavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
        colors: [
          accentColor.withOpacity(0.4),
          accentColor.withOpacity(0.2),
        ],
      ).createShader(Rect.fromLTRB(0, size.height * 0.7, size.width, size.height));

    canvas.drawPath(bottomPath, bottomWavePaint);

    for (int i = 0; i < 20; i++) {
      final x = size.width * (i / 20) + (i % 5) * 5;
      final y = size.height * 0.75 + (i % 4) * 15;
      final radius = 3 + (i % 5) * 1.5;
      final bubblePaint = Paint()
        ..color = i % 2 == 0
            ? AppColors.gold.withOpacity(0.1 + (i % 5) * 0.04)
            : AppColors.silver.withOpacity(0.1 + (i % 5) * 0.03)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), radius, bubblePaint);
    }

    final decorPositions = [
      Offset(size.width * 0.2, size.height * 0.4),
      Offset(size.width * 0.3, size.height * 0.45),
      Offset(size.width * 0.4, size.height * 0.5),
      Offset(size.width * 0.5, size.height * 0.55),
      Offset(size.width * 0.6, size.height * 0.6),
    ];

    final decorRadii = [20.0, 35.0, 50.0, 65.0, 80.0];

    for (int i = 0; i < decorPositions.length; i++) {
      final decorPaint = Paint()
        ..color = i % 2 == 0
            ? AppColors.prog.withOpacity(0.05)
            : AppColors.purple.withOpacity(0.05)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(decorPositions[i], decorRadii[i], decorPaint);
    }

    final pencilPath = Path();
    final pencilStart = Offset(size.width * 0.85, size.height * 0.15);
    pencilPath.moveTo(pencilStart.dx, pencilStart.dy);
    pencilPath.lineTo(pencilStart.dx - 20, pencilStart.dy + 60);
    pencilPath.lineTo(pencilStart.dx + 10, pencilStart.dy + 60);
    pencilPath.close();

    final pencilPaint = Paint()
      ..color = AppColors.bronze.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawPath(pencilPath, pencilPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}