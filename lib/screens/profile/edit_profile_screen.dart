import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Theme ──────────────────────────────────────────────────────────────────
class AppColors {
  static const background = Color(0xFF0D0B0A);
  static const surface = Color(0xFF141210);
  static const gold = Color(0xFFD4AF6A);
  static const goldLight = Color(0xFFE8C98A);
  static const goldDim = Color(0xFF9C7A3A);
  static const maroon = Color(0xFF7A1F3D);
  static const maroonLight = Color(0xFF9B2B4F);
  static const fieldFill = Color(0xFF1A1613);
  static const fieldBorder = Color(0xFF3A322A);
  static const hintText = Color(0xFF9C9088);
  static const divider = Color(0xFF2A2218);
  static const errorText = Color(0xFFE07A7A);
}

// ── Image upload security helpers ───────────────────────────────────────────
// Centralizes every rule about what is allowed to reach Supabase Storage.
// Nothing here trusts a filename or a declared MIME type — everything is
// verified from the raw bytes of the file itself.
class _ImageSecurity {
  static const int maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB hard cap
  static const Set<String> allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  /// Confirms what the file *actually* is by reading its magic bytes,
  /// rather than trusting the extension reported by the OS/picker.
  /// Returns a canonical extension ('jpg' | 'png' | 'webp') or null if the
  /// bytes don't match any supported, safe image format.
  static String? detectRealType(Uint8List bytes) {
    if (bytes.length < 12) return null;

    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'jpg';
    }
    // PNG: 89 50 4E 47
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'png';
    }
    // WEBP: 'RIFF' .... 'WEBP'
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'webp';
    }
    return null;
  }

  static String contentTypeFor(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  /// A Supabase auth uid is a UUID, but we still refuse to build a storage
  /// path out of anything that doesn't look like one — cheap insurance
  /// against path traversal if that assumption is ever wrong.
  static bool isSafeUid(String uid) =>
      RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(uid);
}

// ── Screen ─────────────────────────────────────────────────────────────────
class EditProfileScreen extends StatefulWidget {
  final Map<String, String> currentData;
  final bool isGuest;

  const EditProfileScreen({
    super.key,
    required this.currentData,
    required this.isGuest,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _supabase = Supabase.instance.client;

  // We keep the picker's XFile only for display bookkeeping; every actual
  // security decision is made against the validated bytes/extension below.
  XFile? _profileImage;
  Uint8List? _profileImageBytes;
  String? _profileImageExt;
  String? _avatarUrl;
  bool _isSaving = false;
  DateTime? _lastPickAttempt;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _profCtrl;
  late final TextEditingController _budgetCtrl;
  late final TextEditingController _locationCtrl;

  static const List<String> _genderOptions = ['Male', 'Female', 'Other'];
  static const List<String> _roommateOptions = [
    'Male',
    'Female',
    'Male / Female',
  ];

  String _gender = 'Male';
  String _preferredRoommate = 'Male / Female';

  String _normalizeGender(String? value) {
    if (value != null && _genderOptions.contains(value)) return value;
    return _genderOptions.first;
  }

  String _normalizePreferredRoommate(String? value) {
    if (value != null && _roommateOptions.contains(value)) return value;
    return _roommateOptions.last;
  }

  // ── Init / dispose ──────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: widget.currentData['name']);
    _phoneCtrl = TextEditingController(text: widget.currentData['phone']);
    _ageCtrl = TextEditingController(text: widget.currentData['age']);
    _profCtrl = TextEditingController(text: widget.currentData['profession']);
    _budgetCtrl = TextEditingController(text: widget.currentData['maxBudget']);
    _locationCtrl = TextEditingController(
      text: widget.currentData['preferredLocation'],
    );

    _gender = _normalizeGender(widget.currentData['gender']);
    _preferredRoommate = _normalizePreferredRoommate(
      widget.currentData['preferredRoommate'],
    );

    final meta = _supabase.auth.currentUser?.userMetadata ?? {};
    _avatarUrl = meta['avatar_url'] as String?;

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    for (final c in [
      _nameCtrl,
      _phoneCtrl,
      _ageCtrl,
      _profCtrl,
      _budgetCtrl,
      _locationCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Pick image (validated) ─────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    // Guests don't have a permanent account row to attach a photo to —
    // block it here instead of letting it silently fail (or worse, upload
    // under a shared "guest" path) later.
    if (widget.isGuest) {
      _snack(
        'Guest accounts can\'t upload a permanent photo. Please sign up first.',
      );
      return;
    }

    // Cheap debounce so rapid taps can't spam the picker / re-trigger
    // repeated reads of large files.
    final now = DateTime.now();
    if (_lastPickAttempt != null &&
        now.difference(_lastPickAttempt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastPickAttempt = now;

    if (kIsWeb && source == ImageSource.camera) {
      _snack('Camera not supported on web. Use gallery instead.');
      return;
    }

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 900,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    if (bytes.length > _ImageSecurity.maxFileSizeBytes) {
      _snack('That photo is too large. Please choose one under 5 MB.');
      return;
    }

    // Never trust the file's declared extension — verify the real format
    // from its bytes before it goes anywhere near storage.
    final realType = _ImageSecurity.detectRealType(bytes);
    if (realType == null ||
        !_ImageSecurity.allowedExtensions.contains(realType)) {
      _snack(
        'Unsupported or corrupted file. Please choose a JPG, PNG, or WEBP photo.',
      );
      return;
    }

    setState(() {
      _profileImage = picked;
      _profileImageBytes = bytes;
      _profileImageExt = realType;
    });
  }

  // ── Upload to Supabase Storage (permanent) ────────────────────────────
  Future<String?> _uploadImage(Uint8List bytes, String ext) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Upload blocked: no authenticated user.');
        return null;
      }

      final uid = user.id;
      if (!_ImageSecurity.isSafeUid(uid)) {
        debugPrint('Upload blocked: unexpected uid format.');
        return null;
      }

      // Path is built entirely from a validated uid + a validated,
      // whitelisted extension — never from anything the client supplied.
      final path = 'profile_images/$uid/avatar.$ext';

      await _supabase.storage
          .from('profile_images')
          .uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
          contentType: _ImageSecurity.contentTypeFor(ext),
        ),
      );

      final url = _supabase.storage.from('profile_images').getPublicUrl(path);
      // Cache-busting query so the previous photo isn't shown from cache.
      return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      // Detailed error stays in the console; the user never sees internals.
      debugPrint('Upload error: $e');
      return null;
    }
  }

  // ── Save profile ───────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String? imageUrl = _avatarUrl;

      if (_profileImageBytes != null && _profileImageExt != null) {
        final uploaded = await _uploadImage(
          _profileImageBytes!,
          _profileImageExt!,
        );
        if (uploaded == null) {
          _snack('Photo upload failed. Other changes will still be saved.');
        } else {
          imageUrl = uploaded;
        }
      }

      final data = {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'gender': _gender,
        'age': _ageCtrl.text.trim(),
        'profession': _profCtrl.text.trim(),
        'preferredRoommate': _preferredRoommate,
        'maxBudget': _budgetCtrl.text.trim(),
        'preferredLocation': _locationCtrl.text.trim(),
        'avatar_url': imageUrl ?? '',
      };

      if (!widget.isGuest) {
        await _supabase.auth.updateUser(UserAttributes(data: data));
        try {
          await _supabase.from('profiles').upsert({
            'id': _supabase.auth.currentUser!.id,
            'full_name': _nameCtrl.text.trim(),
            'phone': _phoneCtrl.text.trim(),
            'avatar_url': imageUrl ?? '',
          });
        } catch (dbError) {
          debugPrint('Failed to update profiles table: $dbError');
        }
      }

      if (mounted) Navigator.pop(context, data);
    } catch (e) {
      debugPrint('Profile update error: $e');
      _snack('Failed to update profile. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.fieldFill,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(msg, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showPhotoSheet() {
    if (widget.isGuest) {
      _snack(
        'Guest accounts can\'t upload a permanent photo. Please sign up first.',
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PhotoSheet(
        onGallery: () {
          Navigator.pop(context);
          _pickImage(ImageSource.gallery);
        },
        onCamera: kIsWeb
            ? null
            : () {
          Navigator.pop(context);
          _pickImage(ImageSource.camera);
        },
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      color: AppColors.hintText,
      fontSize: 13,
      fontFamily: GoogleFonts.urbanist().fontFamily,
    ),
    prefixIcon: Icon(icon, color: AppColors.goldDim, size: 19),
    filled: true,
    fillColor: AppColors.fieldFill,
    contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
    border: _border(AppColors.fieldBorder),
    enabledBorder: _border(AppColors.fieldBorder),
    focusedBorder: _border(AppColors.gold, width: 1.4),
    errorBorder: _border(AppColors.errorText),
    focusedErrorBorder: _border(AppColors.errorText, width: 1.4),
    errorStyle: const TextStyle(color: AppColors.errorText, fontSize: 11),
  );

  OutlineInputBorder _border(Color c, {double width = 1.0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: width),
      );

  // ── Build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Preview is built from validated in-memory bytes, never from a raw
    // file path — keeps the picked-but-not-yet-uploaded state trustworthy.
    ImageProvider? avatar;
    if (_profileImageBytes != null) {
      avatar = MemoryImage(_profileImageBytes!);
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      avatar = NetworkImage(_avatarUrl!);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              22,
              MediaQuery.of(context).padding.top + 72,
              22,
              40,
            ),
            children: [
              // ── Avatar card ──────────────────────────────────────────
              _AvatarCard(
                avatar: avatar,
                isGuest: widget.isGuest,
                onTap: _showPhotoSheet,
              ),

              const SizedBox(height: 32),

              // ── Section: Personal Info ───────────────────────────────
              _SectionLabel(label: 'Personal Information'),
              const SizedBox(height: 12),

              _Field(
                controller: _nameCtrl,
                decoration: _dec('Full Name', Icons.person_outline_rounded),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),

              _Field(
                controller: _phoneCtrl,
                decoration: _dec('Phone Number', Icons.phone_outlined),
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _Dropdown(
                      value: _gender,
                      label: 'Gender',
                      icon: Icons.wc_outlined,
                      items: const ['Male', 'Female', 'Other'],
                      dec: _dec,
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Field(
                      controller: _ageCtrl,
                      decoration: _dec('Age', Icons.cake_outlined),
                      keyboard: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _Field(
                controller: _profCtrl,
                decoration: _dec('Profession', Icons.work_outline_rounded),
              ),

              const SizedBox(height: 28),

              // ── Section: Roommate Preferences ────────────────────────
              _SectionLabel(label: 'Roommate Preferences'),
              const SizedBox(height: 12),

              _Dropdown(
                value: _preferredRoommate,
                label: 'Preferred Roommate',
                icon: Icons.people_outline_rounded,
                items: _roommateOptions,
                dec: _dec,
                onChanged: (v) => setState(() => _preferredRoommate = v!),
              ),
              const SizedBox(height: 12),

              _Field(
                controller: _budgetCtrl,
                decoration: _dec(
                  'Max Budget (PKR)',
                  Icons.account_balance_wallet_outlined,
                ),
                keyboard: TextInputType.number,
              ),
              const SizedBox(height: 12),

              _Field(
                controller: _locationCtrl,
                decoration: _dec(
                  'Preferred Location',
                  Icons.location_on_outlined,
                ),
              ),

              const SizedBox(height: 40),

              // ── Save Button ──────────────────────────────────────────
              _SaveButton(isSaving: _isSaving, onPressed: _saveProfile),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xEE0D0B0A), Color(0x000D0B0A)],
        ),
      ),
    ),
    leading: IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.fieldFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.fieldBorder),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.gold,
          size: 16,
        ),
      ),
      onPressed: () => Navigator.pop(context),
    ),
    // ── Title row now carries the same brand mark used on the login
    // screen, next to the "Edit Profile" text, so the header reads as
    // part of the same app rather than a generic settings page.
    title: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Swap this Image.asset for your actual login-screen logo file,
        // e.g. Image.asset('assets/images/logo.png', height: 18,
        // color: AppColors.gold). Falls back to a simple gold glyph if
        // the asset is missing so the header never breaks.
        Image.asset(
          'assets/images/logo.png',
          height: 18,
          color: AppColors.gold,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.gold,
            size: 16,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          'Edit Profile',
          style: GoogleFonts.urbanist(
            color: AppColors.gold,
            fontWeight: FontWeight.w700,
            fontSize: 19,
            letterSpacing: 0.4,
          ),
        ),
      ],
    ),
    centerTitle: true,
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 14),
        child: _isSaving
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.gold,
          ),
        )
            : GestureDetector(
          onTap: _saveProfile,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'save',
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

// ── Avatar Card ─────────────────────────────────────────────────────────────
class _AvatarCard extends StatelessWidget {
  final ImageProvider? avatar;
  final bool isGuest;
  final VoidCallback onTap;

  const _AvatarCard({
    required this.avatar,
    required this.isGuest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Glow ring
                Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(
                      colors: [
                        AppColors.gold,
                        AppColors.goldDim,
                        AppColors.maroon,
                        AppColors.goldDim,
                        AppColors.gold,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 3,
                  left: 3,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.fieldFill,
                      image: avatar != null
                          ? DecorationImage(image: avatar!, fit: BoxFit.cover)
                          : null,
                    ),
                    child: avatar == null
                        ? const Icon(
                      Icons.person_rounded,
                      color: AppColors.goldDim,
                      size: 54,
                    )
                        : null,
                  ),
                ),
                // Edit badge (shows a lock for guests instead of camera)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.maroonLight, AppColors.maroon],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.maroon.withOpacity(0.55),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      isGuest
                          ? Icons.lock_outline_rounded
                          : Icons.camera_alt_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: Text(
              isGuest ? 'Sign up to add a photo' : 'Change Profile Photo',
              style: GoogleFonts.urbanist(
                color: AppColors.goldLight,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Photo is saved permanently to your account',
            style: GoogleFonts.urbanist(
              color: AppColors.hintText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.urbanist(
            color: AppColors.goldDim,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

// ── Reusable field ─────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.decoration,
    this.keyboard,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      style: GoogleFonts.urbanist(color: Colors.white, fontSize: 14),
      cursorColor: AppColors.gold,
      decoration: decoration,
    );
  }
}

// ── Reusable dropdown ──────────────────────────────────────────────────────
class _Dropdown extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final List<String> items;
  final InputDecoration Function(String, IconData) dec;
  final void Function(String?) onChanged;

  const _Dropdown({
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    required this.dec,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF1F1A15),
      style: GoogleFonts.urbanist(color: Colors.white, fontSize: 14),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.goldDim,
      ),
      decoration: dec(label, icon),
      items: items
          .map(
            (g) => DropdownMenuItem(
          value: g,
          child: Text(g, style: GoogleFonts.urbanist(color: Colors.white)),
        ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ── Save button ────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const _SaveButton({required this.isSaving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSaving
                  ? [
                AppColors.maroon.withOpacity(0.5),
                AppColors.maroon.withOpacity(0.3),
              ]
                  : [
                AppColors.maroonLight,
                AppColors.maroon,
                const Color(0xFF5A1028),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: isSaving
                ? []
                : [
              BoxShadow(
                color: AppColors.maroon.withOpacity(0.45),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: isSaving
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : Text(
              'Save Profile',
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Photo source bottom sheet ──────────────────────────────────────────────
class _PhotoSheet extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback? onCamera;

  const _PhotoSheet({required this.onGallery, this.onCamera});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1613),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.fieldBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Update Profile Photo',
                style: GoogleFonts.urbanist(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'JPG, PNG or WEBP · up to 5 MB · saved permanently to your account.',
                style: GoogleFonts.urbanist(
                  color: AppColors.hintText,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.divider, height: 1),

            _SheetTile(
              icon: Icons.photo_library_outlined,
              label: 'Choose from Gallery',
              onTap: onGallery,
            ),

            if (onCamera != null) ...[
              Divider(color: AppColors.divider, height: 1),
              _SheetTile(
                icon: Icons.camera_alt_outlined,
                label: 'Take a Photo',
                onTap: onCamera!,
              ),
            ],

            Divider(color: AppColors.divider, height: 1),
            _SheetTile(
              icon: Icons.close_rounded,
              label: 'Cancel',
              color: AppColors.errorText,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.urbanist(
          color: color == AppColors.gold ? Colors.white : color,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}