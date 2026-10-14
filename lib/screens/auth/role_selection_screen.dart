import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

const Color _kBackground = Color(0xFF0D0D0D);
const Color _kSurface = Color(0xFF1A1717);
const Color _kCardBg = Color(0xFF1C1919);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMaroonEnd = Color(0xFF4E1220);
const Color _kMutedText = Color(0xFF9B9B9B);
const Color _kBorder = Color(0xFF2A2626);

class RoleSelectionScreen extends StatefulWidget {
  final bool showSkip;
  final bool onboardingMode;

  const RoleSelectionScreen({
    super.key,
    this.showSkip = true,
    this.onboardingMode = false,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.renter;
  bool _isSaving = false;

  Future<void> _confirm() async {
    setState(() => _isSaving = true);
    await AuthService.setUserRole(_selectedRole);
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  void _skip() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/icons/appicon.png',
            height: 32,
            width: 32,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          if (widget.showSkip)
            TextButton(
              onPressed: _isSaving ? null : _skip,
              child: const Text(
                'Skip',
                style: TextStyle(color: _kMutedText, fontSize: 13),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Welcome to Roommate Finder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'What best describes you? We will tailor your experience.',
                style: TextStyle(color: _kMutedText, fontSize: 13.5, height: 1.4),
              ),
              const SizedBox(height: 28),
              _buildRoleCard(
                role: UserRole.renter,
                isSelected: _selectedRole == UserRole.renter,
                icon: Icons.search_rounded,
                emoji: '🏠',
                title: 'I am looking for a room',
                subtitle: AuthService.roleSubtitle(UserRole.renter),
                bulletPoints: const [
                  'Browse rooms near your location',
                  'Save favorites & compare listings',
                  'Chat with hosts & request viewings',
                ],
                onTap: () => setState(() => _selectedRole = UserRole.renter),
              ),
              const SizedBox(height: 14),
              _buildRoleCard(
                role: UserRole.host,
                isSelected: _selectedRole == UserRole.host,
                icon: Icons.apartment_rounded,
                emoji: '🏢',
                title: 'I have a room to rent',
                subtitle: AuthService.roleSubtitle(UserRole.host),
                bulletPoints: const [
                  'Post your rooms & reach tenants globally',
                  'Track requests & manage applications',
                  'Post a Room, Post Job - single dashboard',
                ],
                onTap: () => setState(() => _selectedRole = UserRole.host),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [_kMaroonStart, _kMaroonEnd],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Setting things up...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Continue as ${AuthService.roleDisplay(_selectedRole)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required bool isSelected,
    required IconData icon,
    required String emoji,
    required String title,
    required String subtitle,
    required List<String> bulletPoints,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? _kGold : _kBorder,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _kGold.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _kGold.withValues(alpha: 0.18)
                        : _kSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? _kGold.withValues(alpha: 0.5)
                          : _kBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: _kMutedText,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? _kGold : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? _kGold : _kBorder,
                      width: 1.4,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: _kBackground, size: 14)
                      : null,
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final point in bulletPoints) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: Icon(Icons.check_circle, color: _kGold, size: 12),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(
                                color: _kGoldLight,
                                fontSize: 11.5,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (point != bulletPoints.last) const SizedBox(height: 5),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
