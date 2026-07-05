import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/local_file.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  User? _currentUser;
  XFile? _profileImage;
  bool _isLoading = true;
  late Map<String, String> _guestData;

  @override
  void initState() {
    super.initState();
    _guestData = {
      'name': 'Demo User',
      'phone': '+92 300 1234567',
      'gender': 'Male',
      'age': '23',
      'profession': 'Student',
      'preferredRoommate': 'Male / Female',
      'maxBudget': 'Rs. 20,000 / Month',
      'preferredLocation': 'Islamabad, Pakistan',
    };
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = Supabase.instance.client.auth.currentUser;
    final metadata = currentUser?.userMetadata ?? {};
    final savedAvatarPath = prefs.getString('profile_avatar_path');
    final avatarPath = (metadata['avatar_path'] as String?) ?? savedAvatarPath;

    if (!mounted) return;

    setState(() {
      _currentUser = currentUser;
      if (!kIsWeb && avatarPath != null && avatarPath.isNotEmpty) {
        final avatarFile = io.File(avatarPath);
        if (avatarFile.existsSync()) {
          _profileImage = XFile(avatarPath);
        } else {
          _profileImage = null;
        }
      }
      _isLoading = false;
    });
  }

  Map<String, String> _getProfileData() {
    if (_currentUser == null) {
      return _guestData;
    }

    final metadata = _currentUser!.userMetadata ?? {};
    return {
      'name':
          metadata['full_name'] ??
          (_currentUser!.email != null
              ? _currentUser!.email!.split('@')[0]
              : 'User'),
      'phone': metadata['phone_number'] ?? '+92 300 1234567',
      'gender': metadata['gender'] ?? 'Not specified',
      'age': metadata['age'] ?? 'Not specified',
      'profession': metadata['profession'] ?? 'Not specified',
      'preferredRoommate': metadata['preferred_roommate'] ?? 'Male / Female',
      'maxBudget': metadata['max_budget'] ?? 'Rs. 20,000 / Month',
      'preferredLocation':
          metadata['preferred_location'] ?? 'Islamabad, Pakistan',
    };
  }

  Future<String> _saveProfilePhotoLocally(XFile file) async {
    return savePickedImageLocally(file);
  }

  Future<void> _updateAvatarPath(String path) async {
    if (_currentUser == null) return;
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'avatar_path': path}),
      );
    } catch (_) {
      // Ignore metadata failures; show locally anyway.
    }
  }

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

    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 600,
      );
      if (pickedFile != null) {
        final savedPath = await _saveProfilePhotoLocally(pickedFile);
        await _updateAvatarPath(savedPath);
        if (mounted) {
          setState(() {
            _profileImage = XFile(savedPath);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to pick image: $e')));
      }
    }
  }

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
            if (kIsWeb)
              const ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera is not supported on web'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      }
    }
  }

  void _navigateToEditProfile(Map<String, String> data, bool isGuest) async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditProfileScreen(currentData: data, isGuest: isGuest),
      ),
    );

    if (result != null) {
      if (isGuest) {
        setState(() {
          _guestData = result;
        });
      } else {
        _loadUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isGuest = _currentUser == null;
    final email = _currentUser?.email ?? 'guest@example.com';
    final profileData = _getProfileData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              child: Column(
                children: [
                  Column(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(60),
                        onTap: _showPhotoSourceSheet,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: Container(
                                  width: 104,
                                  height: 104,
                                  color: primaryColor.withOpacity(0.1),
                                  child: _profileImage != null
                                      ? (kIsWeb
                                            ? Image.network(
                                                _profileImage!.path,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                io.File(_profileImage!.path),
                                                fit: BoxFit.cover,
                                              ))
                                      : Center(
                                          child: Text(
                                            profileData['name']!.isEmpty
                                                ? '?'
                                                : profileData['name']![0]
                                                      .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: primaryColor,
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to change photo',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profileData['name']!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  if (isGuest) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Demo Session',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Profile Sections
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailTile(
                    Icons.phone_outlined,
                    'Phone',
                    profileData['phone']!,
                  ),
                  _buildDetailTile(
                    Icons.person_outline,
                    'Gender',
                    profileData['gender']!,
                  ),
                  _buildDetailTile(
                    Icons.cake_outlined,
                    'Age',
                    profileData['age']!,
                  ),
                  _buildDetailTile(
                    Icons.work_outline,
                    'Profession',
                    profileData['profession']!,
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Roommate Preferences',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  _buildDetailTile(
                    Icons.group_outlined,
                    'Preferred Roommate',
                    profileData['preferredRoommate']!,
                  ),
                  _buildDetailTile(
                    Icons.monetization_on_outlined,
                    'Max Budget',
                    profileData['maxBudget']!,
                  ),
                  _buildDetailTile(
                    Icons.location_on_outlined,
                    'Preferred Location',
                    profileData['preferredLocation']!,
                  ),

                  const SizedBox(height: 30),

                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _navigateToEditProfile(profileData, isGuest),
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, color: Colors.blue[850]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
