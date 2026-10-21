import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/host_dashboard.dart';
import '../home/renter_dashboard.dart';

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

  Future<void> _proceedWithRole(UserRole role) async {
    setState(() {
      _selectedRole = role;
      _isSaving = true;
    });

    try {
      await AuthService.setUserRole(role);
    } catch (e) {
      debugPrint('Error saving user role: $e');
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => role == UserRole.host
            ? const HostDashboard()
            : const RenterDashboard(),
      ),
      (route) => false,
    );
  }

  void _skip() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RenterDashboard()),
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icons/appicon.png',
                height: 30,
                width: 30,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Roommate Finder',
              style: TextStyle(
                color: _kGoldLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Choose How to Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Select your preferred mode below. You can easily switch modes anytime from your dashboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _kMutedText,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Option 1: Continue as User
              _buildRoleCard(
                role: UserRole.renter,
                isSelected: _selectedRole == UserRole.renter,
                icon: Icons.person_search_rounded,
                badgeText: 'Seeker Mode',
                title: 'Continue as User',
                subtitle: 'Find rooms, flatmates & schedule viewings',
                bulletPoints: const [
                  'Browse verified rooms & apartments near you',
                  'Save favorites & chat directly with hosts',
                  'Quick viewing requests & roommate matching',
                ],
                onTap: () => setState(() => _selectedRole = UserRole.renter),
                onProceed: () => _proceedWithRole(UserRole.renter),
              ),
              const SizedBox(height: 16),

              // Option 2: Continue as Host
              _buildRoleCard(
                role: UserRole.host,
                isSelected: _selectedRole == UserRole.host,
                icon: Icons.apartment_rounded,
                badgeText: 'Owner Mode',
                title: 'Continue as Host',
                subtitle: 'List rooms, find tenants & manage inquiries',
                bulletPoints: const [
                  'Post your room & property listings in minutes',
                  'Receive & manage tenant applications directly',
                  'Host dashboard with inquiries & analytics',
                ],
                onTap: () => setState(() => _selectedRole = UserRole.host),
                onProceed: () => _proceedWithRole(UserRole.host),
              ),
              const SizedBox(height: 28),

              // Main Confirm Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [_kMaroonStart, _kMaroonEnd],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _kMaroonStart.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () => _proceedWithRole(_selectedRole),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Setting up dashboard...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedRole == UserRole.host
                                  ? Icons.apartment_rounded
                                  : Icons.person_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Continue as ${_selectedRole == UserRole.host ? 'Host' : 'User'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
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
    required String badgeText,
    required String title,
    required String subtitle,
    required List<String> bulletPoints,
    required VoidCallback onTap,
    required VoidCallback onProceed,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _kSurface : _kCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _kGold : _kBorder,
            width: isSelected ? 1.8 : 1,
          ),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    _kMaroonStart.withValues(alpha: 0.25),
                    _kSurface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _kGold.withValues(alpha: 0.16),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _kGold.withValues(alpha: 0.2)
                        : const Color(0xFF242020),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? _kGold : _kBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: isSelected ? _kGold : _kMutedText,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _kGold.withValues(alpha: 0.18)
                                  : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                color: isSelected ? _kGold : _kMutedText,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: _kMutedText,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? _kGold : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? _kGold : _kBorder,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: _kBackground, size: 14)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? _kGold.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? _kGold.withValues(alpha: 0.25)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final point in bulletPoints) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: isSelected ? _kGold : _kMutedText,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            point,
                            style: TextStyle(
                              color: isSelected ? _kGoldLight : _kMutedText,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (point != bulletPoints.last) const SizedBox(height: 6),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
