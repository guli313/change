import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roommate_finder/screens/auth/forgot_password_screen.dart';
import 'package:roommate_finder/screens/auth/signup_screen.dart';
import 'package:roommate_finder/screens/home/home_screen.dart';
import 'package:roommate_finder/screens/home/host_dashboard.dart';
import 'package:roommate_finder/screens/home/renter_dashboard.dart';
import 'package:roommate_finder/services/auth_service.dart';

// ---- Theme colors matching the design ----
const Color _kBackground = Color(0xFF0D0D0D);
const Color _kFieldFill = Color(0xFF1A1717);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMaroonEnd = Color(0xFF4E1220);
const Color _kMutedText = Color(0xFF9B9B9B);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.renter;

  @override
  void initState() {
    super.initState();
    _loadInitialRole();
  }

  Future<void> _loadInitialRole() async {
    final role = await AuthService.getUserRole();
    if (mounted) {
      setState(() => _selectedRole = role);
    }
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => _selectedRole == UserRole.host
            ? const HostDashboard()
            : const RenterDashboard(),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_logged_in', true);
        await AuthService.setUserRole(_selectedRole);

        _navigateToDashboard();
        return;
      }

      _showError('Unable to login. Please check your credentials.');
    } catch (e) {
      debugPrint('Login error details: $e');
      String message = 'Login failed. Please try again.';
      if (e is AuthException) {
        message = e.message;
      } else if ((e is StateError && e.message.contains('initialized')) ||
          (e is AssertionError && e.toString().contains('initialize')) ||
          e.toString().contains('initialize')) {
        message =
            'Supabase is not initialized. Please verify SUPABASE_URL and SUPABASE_ANON_KEY config.';
      } else {
        message = e.toString();
      }
      _showError(message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: _kFieldFill),
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() => _isLoading = true);

    try {
      if (provider == 'Google') {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? null : 'roommate-finder://login-callback',
          scopes: 'email profile',
        );
      } else if (provider == 'Apple') {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: kIsWeb ? null : 'roommate-finder://login-callback',
        );
      } else if (provider == 'Phone') {
        final phone = await _promptForPhoneNumber();
        if (phone == null || phone.isEmpty) return;

        await Supabase.instance.client.auth.signInWithOtp(phone: phone);
      }

      if (!mounted) return;

      if (Supabase.instance.client.auth.currentSession != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_logged_in', true);
        await AuthService.setUserRole(_selectedRole);

        _navigateToDashboard();
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Social login error details: $e');
      String message = 'Unable to start $provider login right now.';
      if (e is AuthException) {
        message = e.message;
      } else if ((e is StateError && e.message.contains('initialized')) ||
          (e is AssertionError && e.toString().contains('initialize')) ||
          e.toString().contains('initialize')) {
        message =
            'Supabase is not initialized. Please verify SUPABASE_URL and SUPABASE_ANON_KEY config.';
      } else {
        message = e.toString();
      }
      _showError(message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _promptForPhoneNumber() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _kFieldFill,
          title: const Text(
            'Phone login',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter phone number',
              hintStyle: TextStyle(color: _kMutedText),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _kGold),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _kGold),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: _kGold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kGold),
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text(
                'Send OTP',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _skipForNow() async {
    await AuthService.setLocalRole(_selectedRole);
    _navigateToDashboard();
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tune_rounded, color: _kGold, size: 16),
            const SizedBox(width: 6),
            const Text(
              'SELECT ROLE / ACCOUNT TYPE',
              style: TextStyle(
                color: _kGoldLight,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _kFieldFill,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2E2A2A)),
              ),
              child: Text(
                _selectedRole == UserRole.host ? 'Host Mode' : 'User Mode',
                style: const TextStyle(
                  color: _kGold,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRoleCard(
                role: UserRole.renter,
                title: 'User / Seeker',
                subtitle: 'Find Rooms & Mates',
                icon: Icons.person_search_rounded,
                badge: 'Kamra Dhoondhein',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleCard(
                role: UserRole.host,
                title: 'Host / Owner',
                subtitle: 'Rent Out & Manage',
                icon: Icons.apartment_rounded,
                badge: 'Kamra Dein',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _selectedRole == UserRole.host
                ? _kMaroonStart.withValues(alpha: 0.25)
                : _kGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedRole == UserRole.host
                  ? _kMaroonStart.withValues(alpha: 0.5)
                  : _kGold.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _selectedRole == UserRole.host
                    ? Icons.real_estate_agent_rounded
                    : Icons.check_circle_rounded,
                color: _selectedRole == UserRole.host ? _kGoldLight : _kGold,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedRole == UserRole.host
                      ? 'Host Mode Active: Takes you directly to Host Dashboard to manage your properties, post rooms & view tenant leads.'
                      : 'User Mode Active: Takes you directly to User Dashboard to explore nearby rooms, find roommates & save favorites.',
                  style: TextStyle(
                    color: _selectedRole == UserRole.host ? Colors.white70 : _kGoldLight,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required String badge,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedRole = role);
        AuthService.setLocalRole(role);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _kFieldFill : const Color(0xFF141212),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _kGold : const Color(0xFF282525),
            width: isSelected ? 1.8 : 1,
          ),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    _kMaroonStart.withValues(alpha: 0.35),
                    _kFieldFill,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _kGold.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _kGold.withValues(alpha: 0.2)
                        : const Color(0xFF201D1D),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? _kGold : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? _kGold : _kMutedText,
                    size: 20,
                  ),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? _kGold : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? _kGold : _kMutedText.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 13, color: Colors.black)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: _kMutedText,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? _kGold.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: isSelected ? _kGold : _kMutedText,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _kMutedText, fontSize: 14),
      prefixIcon: Icon(icon, color: _kGold, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _kFieldFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2A2626)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _kGold),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => Navigator.maybePop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Center(
                  child: Image.asset(
                    'assets/icons/appicon.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                const Center(
                  child: Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _kGoldLight,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Login to continue',
                    style: TextStyle(fontSize: 14, color: _kMutedText),
                  ),
                ),
                const SizedBox(height: 22),
                _buildRoleSelector(),
                const SizedBox(height: 22),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration(
                    hint: 'Email or Phone',
                    icon: Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration(
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: _kMutedText,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(
                            initialEmail: _emailController.text.trim(),
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Password Bhool Gaye?',
                      style: TextStyle(color: _kGold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [_kMaroonStart, _kMaroonEnd],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedRole == UserRole.host
                                    ? Icons.apartment_rounded
                                    : Icons.person_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Login as ${_selectedRole == UserRole.host ? 'Host' : 'User'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _skipForNow,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Skip & Enter as ${_selectedRole == UserRole.host ? 'Host' : 'User'}',
                      style: const TextStyle(
                        color: _kGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: _kMutedText, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: _kGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
