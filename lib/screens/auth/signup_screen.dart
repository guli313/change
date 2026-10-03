import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_screen.dart';

// ---- Theme colors (same palette as LoginScreen) ----
const Color _kBackground = Color(0xFF0D0D0D);
const Color _kFieldFill = Color(0xFF1A1717);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMaroonEnd = Color(0xFF4E1220);
const Color _kMutedText = Color(0xFF9B9B9B);
const Color _kBorder = Color(0xFF2A2626);

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = response.user;

      if (user == null) {
        _showError('Unable to create account. Please try again.');
        return;
      }

      // ✅ Insert profile into database
      await Supabase.instance.client.from('profiles').insert({
        'id': user.id,
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'avatar_url': null,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully'),
          backgroundColor: _kFieldFill,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      debugPrint('Signup error details: $e');
      String message = 'Signup failed. Please try again.';
      if (e is AuthException) {
        message = e.message;
      } else if ((e is StateError && e.message.contains('initialized')) ||
          (e is AssertionError && e.toString().contains('initialize')) ||
          e.toString().contains('initialize')) {
        message = 'Supabase is not initialized. Please verify SUPABASE_URL and SUPABASE_ANON_KEY config.';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: _kFieldFill),
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
        borderSide: const BorderSide(color: _kBorder),
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
                const SizedBox(height: 20),

                Center(
                  child: Image.asset(
                    'assets/icons/appicon.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Create Account',
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
                    'Sign up to get started',
                    style: TextStyle(fontSize: 14, color: _kMutedText),
                  ),
                ),
                const SizedBox(height: 28),

                // NAME
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration(
                    hint: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 16),

                // EMAIL
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration(
                    hint: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter email';
                    }
                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value)) {
                      return 'Enter valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // PHONE
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration(
                    hint: 'Phone Number',
                    icon: Icons.phone_outlined,
                  ),
                  validator: (value) => value == null || value.length < 10
                      ? 'Enter valid phone'
                      : null,
                ),
                const SizedBox(height: 16),

                // PASSWORD
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
                  validator: (value) => value != null && value.length < 6
                      ? 'Min 6 characters'
                      : null,
                ),
                const SizedBox(height: 16),

                // CONFIRM PASSWORD
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration(
                    hint: 'Confirm Password',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: _kMutedText,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // BUTTON
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
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: _kMutedText, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Login',
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
