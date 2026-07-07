import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---- Theme colors matched to the login screen design ----
class AppColors {
  static const background = Color(0xFF0D0B0A); // near-black background
  static const gold = Color(0xFFD4AF6A); // headings / icons
  static const goldLight = Color(0xFFE8C98A);
  static const maroon = Color(0xFF7A1F3D); // primary button
  static const fieldFill = Color(0xFF1A1613); // input background
  static const fieldBorder = Color(0xFF3A322A);
  static const hintText = Color(0xFF9C9088);
}

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

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  XFile? _profileImage;
  String? _avatarUrl;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _professionController;
  late TextEditingController _budgetController;
  late TextEditingController _locationController;

  String _selectedGender = 'Male';
  String _selectedPreferredRoommate = 'Male / Female';
  bool _isSaving = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.currentData['name']);
    _phoneController = TextEditingController(text: widget.currentData['phone']);
    _ageController = TextEditingController(text: widget.currentData['age']);
    _professionController = TextEditingController(
      text: widget.currentData['profession'],
    );
    _budgetController = TextEditingController(
      text: widget.currentData['maxBudget'],
    );
    _locationController = TextEditingController(
      text: widget.currentData['preferredLocation'],
    );

    _selectedGender = widget.currentData['gender'] ?? 'Male';
    _selectedPreferredRoommate =
        widget.currentData['preferredRoommate'] ?? 'Male / Female';

    final user = supabase.auth.currentUser;
    final metadata = user?.userMetadata ?? {};
    _avatarUrl = metadata['avatar_url'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _professionController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ---------------- PICK IMAGE ----------------
  Future<void> _pickProfilePhoto(ImageSource source) async {
    if (kIsWeb && source == ImageSource.camera) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.fieldFill,
            content: Text(
              'Camera is not supported on web. Please use gallery instead.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      return;
    }

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (picked != null) {
      setState(() {
        _profileImage = picked;
      });
    }
  }

  // ---------------- UPLOAD TO SUPABASE ----------------
  Future<String?> _uploadImageToSupabase(XFile file) async {
    try {
      final fileBytes = await file.readAsBytes();
      final fileExt = file.path.split('.').last;

      final fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      final storagePath = 'profile_images/$fileName';

      await supabase.storage
          .from('profile_images')
          .uploadBinary(
        storagePath,
        fileBytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final publicUrl = supabase.storage
          .from('profile_images')
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  // ---------------- SAVE PROFILE ----------------
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      String? savedImagePath = _avatarUrl;

      if (_profileImage != null) {
        savedImagePath = await _uploadImageToSupabase(_profileImage!);
      }

      final updatedData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'gender': _selectedGender,
        'age': _ageController.text.trim(),
        'profession': _professionController.text.trim(),
        'preferredRoommate': _selectedPreferredRoommate,
        'maxBudget': _budgetController.text.trim(),
        'preferredLocation': _locationController.text.trim(),
        'avatar_url': savedImagePath ?? '',
      };

      if (!widget.isGuest) {
        await supabase.auth.updateUser(UserAttributes(data: updatedData));
      }

      if (mounted) {
        Navigator.pop(context, updatedData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.fieldFill,
            content: Text(
              'Failed to update profile: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ---------------- BOTTOM SHEET ----------------
  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fieldFill,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.fieldBorder,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.gold),
              title: const Text('Choose from Gallery',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickProfilePhoto(ImageSource.gallery);
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.gold),
                title: const Text('Take a Photo',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfilePhoto(ImageSource.camera);
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ---------------- STYLE HELPERS ----------------
  InputDecoration _fieldDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.hintText),
      prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
      filled: true,
      fillColor: AppColors.fieldFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
      ),
      errorStyle: const TextStyle(color: Color(0xFFE07A7A)),
    );
  }

  Widget _sectionSpacing() => const SizedBox(height: 16);

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;

    if (_profileImage != null) {
      avatarImage = kIsWeb
          ? NetworkImage(_profileImage!.path)
          : FileImage(io.File(_profileImage!.path)) as ImageProvider;
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      avatarImage = NetworkImage(_avatarUrl!);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.gold),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.gold,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.gold),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            // ---- Profile picture with edit badge ----
            Center(
              child: InkWell(
                onTap: _showPhotoSourceSheet,
                borderRadius: BorderRadius.circular(60),
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.fieldFill,
                        border: Border.all(color: AppColors.gold, width: 1.5),
                        image: avatarImage != null
                            ? DecorationImage(image: avatarImage, fit: BoxFit.cover)
                            : null,
                      ),
                      child: avatarImage == null
                          ? const Icon(Icons.person, color: AppColors.gold, size: 48)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.maroon,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: _showPhotoSourceSheet,
                child: const Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _fieldDecoration(label: 'Name', icon: Icons.person_outline),
            ),
            _sectionSpacing(),

            TextFormField(
              controller: _phoneController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: _fieldDecoration(label: 'Phone', icon: Icons.phone_outlined),
            ),
            _sectionSpacing(),

            // ---- Gender dropdown ----
            DropdownButtonFormField<String>(
              value: _selectedGender,
              dropdownColor: AppColors.fieldFill,
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gold),
              decoration: _fieldDecoration(label: 'Gender', icon: Icons.wc_outlined),
              items: const ['Male', 'Female', 'Other']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedGender = value);
              },
            ),
            _sectionSpacing(),

            TextFormField(
              controller: _ageController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: _fieldDecoration(label: 'Age', icon: Icons.cake_outlined),
            ),
            _sectionSpacing(),

            TextFormField(
              controller: _professionController,
              style: const TextStyle(color: Colors.white),
              decoration: _fieldDecoration(
                  label: 'Profession', icon: Icons.work_outline),
            ),
            _sectionSpacing(),

            // ---- Preferred roommate dropdown ----
            DropdownButtonFormField<String>(
              value: _selectedPreferredRoommate,
              dropdownColor: AppColors.fieldFill,
              style: const TextStyle(color: Colors.white),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gold),
              decoration: _fieldDecoration(
                  label: 'Preferred Roommate', icon: Icons.people_outline),
              items: const ['Male', 'Female', 'Male / Female']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPreferredRoommate = value);
                }
              },
            ),
            _sectionSpacing(),

            TextFormField(
              controller: _budgetController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: _fieldDecoration(
                  label: 'Max Budget', icon: Icons.attach_money),
            ),
            _sectionSpacing(),

            TextFormField(
              controller: _locationController,
              style: const TextStyle(color: Colors.white),
              decoration: _fieldDecoration(
                  label: 'Preferred Location', icon: Icons.location_on_outlined),
            ),

            const SizedBox(height: 32),

            // ---- Save button styled like the Login button ----
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                  disabledBackgroundColor: AppColors.maroon.withOpacity(0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 4,
                ),
                child: _isSaving
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Save Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}