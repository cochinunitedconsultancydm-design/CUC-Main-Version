import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import 'manager_dashboard_screen.dart';
import 'delivery_dashboard_screen.dart';
import '../services/auth_service.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedSettings();
  }

  void _loadRememberedSettings() async {
    final settings = await _auth.getRememberedSettings();
    if (mounted) {
      setState(() {
        _userController.text = settings['username'];
        _rememberMe = settings['remember'];
      });
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // SECURITY: Check rate limit before attempting login
      final rateLimitMsg = _auth.getRateLimitMessage(_userController.text.trim());
      if (rateLimitMsg != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(rateLimitMsg),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      setState(() => _isLoading = true);
      
      final success = await _auth.login(
        _userController.text.trim(),
        _passwordController.text,
      );
      
      setState(() => _isLoading = false);

      if (success) {
        await _auth.saveRememberMe(_userController.text.trim(), _rememberMe);
        final role = await _auth.getUserRole();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                if (role == 'admin') return const AdminDashboardScreen();
                if (role == 'manager') return const ManagerDashboardScreen();
                if (role == 'delivery') return const DeliveryDashboardScreen();
                if (role == 'accountant') return const DashboardScreen();
                return const DashboardScreen();
              },
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      } else {
        if (mounted) {
          // Check if now locked after this attempt
          final lockMsg = _auth.getRateLimitMessage(_userController.text.trim());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(lockMsg ?? 'Login failed. Please check your credentials.'),
              backgroundColor: lockMsg != null ? Colors.orange : Colors.redAccent,
              duration: Duration(seconds: lockMsg != null ? 5 : 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
          // Starry Sky Background
          const StarryBackground(),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Image.asset(
                            'assets/CUnitedGold.png',
                            height: 100,
                            fit: BoxFit.contain,
                          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                          
                          const SizedBox(height: 24),
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                              color: Colors.white,
                            ),
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                          
                          const SizedBox(height: 8),
                          Text(
                            'Enter your credentials to access your dashboard',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                          ).animate().fadeIn(delay: 300.ms),
                          
                          const SizedBox(height: 40),
                          
                          // Username Field
                          _buildTextField(
                            controller: _userController,
                            label: 'Username',
                            hint: 'Enter your username',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter your username';
                              return null;
                            },
                          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                          
                          const SizedBox(height: 20),
                          
                          // Password Field
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            isPasswordVisible: _isPasswordVisible,
                            onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter your password';
                              if (value.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                          ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                          
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) => setState(() => _rememberMe = value ?? false),
                                      activeColor: AppTheme.primaryColor,
                                      checkColor: Colors.white,
                                      side: WidgetStateBorderSide.resolveWith(
                                        (states) => BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                                      ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Remember me', style: TextStyle(fontSize: 14, color: Colors.white)),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.accentColor,
                                ),
                                child: const Text('Forgot password?'),
                              ),
                            ],
                          ).animate().fadeIn(delay: 600.ms),
                          
                          const SizedBox(height: 32),
                          
                          // Login Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryColor, AppTheme.accentColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                            ),
                          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                          
                          const SizedBox(height: 24),
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
    ),
  );
}

  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          validator: validator,
          style: const TextStyle(fontSize: 15, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            prefixIcon: Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.7)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppTheme.accentColor.withValues(alpha: 0.8), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ],
    );
  }
}

/// A custom widget that renders a beautiful twinkling starry night sky
class StarryBackground extends StatefulWidget {
  const StarryBackground({super.key});

  @override
  State<StarryBackground> createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<StarryBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Star> _stars = [];
  final List<_Comet> _comets = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    // 4 seconds for a full twinkle cycle
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _controller.addListener(() {
      _updateComets();
      setState(() {});
    });
  }

  void _updateComets() {
    final size = MediaQuery.of(context).size;
    if (size.width == 0) return;
    for (var comet in _comets) {
      if (comet.isActive) {
        comet.x += cos(comet.angle) * comet.speed;
        comet.y += sin(comet.angle) * comet.speed;
        // Check if off screen
        if (comet.x < -100 || comet.x > size.width + 100 || comet.y < -100 || comet.y > size.height + 100) {
          comet.isActive = false;
        }
      } else {
        // Randomly respawn (small chance each tick)
        if (_rnd.nextDouble() < 0.005) {
          comet.isActive = true;
          // Spawn somewhere along the top or left edge
          if (_rnd.nextBool()) {
            comet.x = _rnd.nextDouble() * size.width;
            comet.y = -50;
          } else {
            comet.x = -50;
            comet.y = _rnd.nextDouble() * size.height * 0.5; // Upper half
          }
          comet.angle = (pi / 4) + (_rnd.nextDouble() - 0.5) * 0.2; // mostly down-right
          comet.speed = _rnd.nextDouble() * 15 + 15;
          comet.length = _rnd.nextDouble() * 100 + 80;
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stars.isEmpty) {
      final size = MediaQuery.of(context).size;
      // Generate 150 random stars
      for (int i = 0; i < 150; i++) {
        _stars.add(_Star(
          x: _rnd.nextDouble() * size.width,
          y: _rnd.nextDouble() * size.height,
          size: _rnd.nextDouble() * 2.0 + 0.5,
          twinkleSpeed: (_rnd.nextInt(3) + 1).toDouble(), // Must be an integer to loop seamlessly! (1, 2, or 3 cycles per 4 seconds)
          twinkleOffset: _rnd.nextDouble() * pi * 2,
        ));
      }
    }
    if (_comets.isEmpty) {
      for (int i = 0; i < 3; i++) {
        _comets.add(_Comet(isActive: false, x: 0, y: 0, length: 0, speed: 0, angle: 0));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B0C10), // Deep night sky blue/black
      child: CustomPaint(
        painter: _StarryPainter(_stars, _comets, _controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class _Star {
  final double x, y, size, twinkleSpeed, twinkleOffset;
  _Star({required this.x, required this.y, required this.size, required this.twinkleSpeed, required this.twinkleOffset});
}

class _Comet {
  bool isActive;
  double x, y, length, speed, angle;
  _Comet({required this.isActive, required this.x, required this.y, required this.length, required this.speed, required this.angle});
}

class _StarryPainter extends CustomPainter {
  final List<_Star> stars;
  final List<_Comet> comets;
  final double animationValue;

  _StarryPainter(this.stars, this.comets, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint();
    for (var star in stars) {
      // Calculate twinkling effect using a sine wave based on the animation value (0.0 to 1.0)
      final opacity = (sin((animationValue * pi * 2 * star.twinkleSpeed) + star.twinkleOffset) + 1.0) / 2.0;
      starPaint.color = Colors.white.withValues(alpha: opacity * 0.7 + 0.3); // Min opacity 0.3, Max 1.0
      canvas.drawCircle(Offset(star.x, star.y), star.size, starPaint);
    }

    // Draw comets
    for (var comet in comets) {
      if (!comet.isActive) continue;

      final tailEndX = comet.x - cos(comet.angle) * comet.length;
      final tailEndY = comet.y - sin(comet.angle) * comet.length;
      
      // Calculate rect that bounds the gradient line
      final rect = Rect.fromPoints(Offset(comet.x, comet.y), Offset(tailEndX, tailEndY));

      final cometPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Colors.white, Colors.transparent],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft, // Approximation, shader applies across the rect
        ).createShader(rect)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      // Make the head a bit brighter
      canvas.drawCircle(Offset(comet.x, comet.y), 1.5, Paint()..color = Colors.white);
      canvas.drawLine(Offset(comet.x, comet.y), Offset(tailEndX, tailEndY), cometPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarryPainter oldDelegate) => true;
}

