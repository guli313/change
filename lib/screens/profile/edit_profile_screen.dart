import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
            content: Text(
              'Camera is not supported on web. Please use gallery instead.',
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
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
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickProfilePhoto(ImageSource.gallery);
              },
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfilePhoto(ImageSource.camera);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    ImageProvider? avatarImage;

    if (_profileImage != null) {
      avatarImage = kIsWeb
          ? NetworkImage(_profileImage!.path)
          : FileImage(io.File(_profileImage!.path));
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      avatarImage = NetworkImage(_avatarUrl!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _saveProfile),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: InkWell(
                onTap: _showPhotoSourceSheet,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: primaryColor,
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextFormField(
              controller: _professionController,
              decoration: const InputDecoration(labelText: 'Profession'),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
