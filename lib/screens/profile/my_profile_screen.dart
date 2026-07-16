import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/local_file.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

// ---- Theme colors (matching Login/Signup/Home screens) ----
const Color _kBackground = Color(0xFF0D0D0D);
const Color _kSurface = Color(0xFF1A1717);
const Color _kGold = Color(0xFFCBA35C);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMaroonEnd = Color(0xFF4E1220);
const Color _kMutedText = Color(0xFF9B9B9B);
const Color _kBorder = Color(0xFF2A2626);

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  User? _currentUser;
  XFile? _profileImage;
  String? _avatarUrl;
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
    final avatarUrl = metadata['avatar_url'] as String?;

    if (!mounted) return;

    setState(() {
      _currentUser = currentUser;
      _avatarUrl = avatarUrl;
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
    final gender = metadata['gender'] as String?;
    final preferredRoommate = metadata['preferredRoommate'] as String? ?? metadata['preferred_roommate'] as String?;

    final normalizedGender = ['Male', 'Female', 'Other'].contains(gender)
        ? gender!
        : 'Male';
    final normalizedPreferredRoommate =
        ['Male', 'Female', 'Male / Female'].contains(preferredRoommate)
        ? preferredRoommate!
        : 'Male / Female';

    return {
      'name':
          metadata['name'] ??
          metadata['full_name'] ??
          (_currentUser!.email != null
              ? _currentUser!.email!.split('@')[0]
              : 'User'),
      'phone': metadata['phone'] ?? metadata['phone_number'] ?? '+92 300 1234567',
      'gender': normalizedGender,
      'age': metadata['age'] ?? 'Not specified',
      'profession': metadata['profession'] ?? 'Not specified',
      'preferredRoommate': normalizedPreferredRoommate,
      'maxBudget': metadata['maxBudget'] ?? metadata['max_budget'] ?? 'Rs. 20,000 / Month',
      'preferredLocation':
          metadata['preferredLocation'] ?? metadata['preferred_location'] ?? 'Islamabad, Pakistan',
    };
  }

  Future<String> _saveProfilePhotoLocally(XFile file) async {
    return savePickedImageLocally(file);
  }

  Future<String?> _uploadImage(Uint8List bytes, String ext) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return null;
      final uid = user.id;
      final path = 'profile_images/$uid/avatar.$ext';

      await Supabase.instance.client.storage
          .from('profile_images')
          .uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
          contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
        ),
      );

      final url = Supabase.instance.client.storage.from('profile_images').getPublicUrl(path);
      return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  Future<void> _updateAvatarUrl(String url, String localPath) async {
    if (_currentUser == null) return;
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {
          'avatar_url': url,
          'avatar_path': localPath,
        }),
      );
      try {
        await Supabase.instance.client.from('profiles').upsert({
          'id': _currentUser!.id,
          'avatar_url': url,
        });
      } catch (dbError) {
        debugPrint('Failed to update profiles table: $dbError');
      }
    } catch (_) {
      // Ignore metadata failures
    }
  }

  Future<void> _updateAvatarPath(String path) async {
    if (_currentUser == null) return;
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {
          'avatar_path': path,
          'avatar_url': '', // Clear network url so it uses the local path
        }),
      );
      try {
        await Supabase.instance.client.from('profiles').upsert({
          'id': _currentUser!.id,
          'avatar_url': '',
        });
      } catch (dbError) {
        debugPrint('Failed to update profiles table: $dbError');
      }
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
        // Save locally first so the user gets instant visual feedback
        final savedPath = await _saveProfilePhotoLocally(pickedFile);
        if (mounted) {
          setState(() {
            _profileImage = XFile(savedPath);
            _avatarUrl = null; // Clear network URL to show local image
          });
        }

        // If logged in, upload to Supabase Storage for permanent cloud save
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser != null) {
          final bytes = await pickedFile.readAsBytes();
          final ext = pickedFile.path.split('.').last.toLowerCase();
          final uploadUrl = await _uploadImage(bytes, ext);
          if (uploadUrl != null) {
            await _updateAvatarUrl(uploadUrl, savedPath);
            if (mounted) {
              setState(() {
                _avatarUrl = uploadUrl;
              });
            }
          } else {
            // If upload fails, at least save the local path in metadata
            await _updateAvatarPath(savedPath);
          }
        } else {
          // Guest user: just update local path in metadata
          await _updateAvatarPath(savedPath);
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
    await _signOut(navigateToLogin: true);
  }

  Future<void> _switchAccount() async {
    await _signOut(navigateToLogin: true);
  }

  Future<void> _signOut({required bool navigateToLogin}) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted && navigateToLogin) {
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

  void _confirmSignOut({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kSurface,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          content,
          style: const TextStyle(color: _kMutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _kGold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _kBackground,
        body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_kGold))),
      );
    }

    final isGuest = _currentUser == null;
    final email = _currentUser?.email ?? 'guest@example.com';
    final profileData = _getProfileData();

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kBackground,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            color: _kSurface,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'switch') {
                _confirmSignOut(
                  title: 'Switch Account',
                  content:
                      'You will be logged out and can sign in with a different account.',
                  onConfirm: _switchAccount,
                );
              } else if (value == 'logout') {
                _confirmSignOut(
                  title: 'Logout',
                  content: 'Are you sure you want to logout?',
                  onConfirm: _logout,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'switch',
                child: Text('Switch Account', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Card
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kMaroonStart, _kMaroonEnd],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
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
                              backgroundColor: _kGold,
                              child: ClipOval(
                                child: Container(
                                  width: 104,
                                  height: 104,
                                  color: _kSurface,
                                  child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                      ? Image.network(
                                          _avatarUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return _buildLocalOrPlaceholderImage(profileData);
                                          },
                                        )
                                      : _buildLocalOrPlaceholderImage(profileData),
                                ),
                              ),
                            ),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: _kBackground,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: _kGold,
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: _kBackground,
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
                        color: _kGold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Demo Session',
                        style: TextStyle(
                          color: _kBackground,
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
                        backgroundColor: _kGold,
                        foregroundColor: _kBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _confirmSignOut(
                              title: 'Switch Account',
                              content:
                                  'You will be logged out and can sign in with a different account.',
                              onConfirm: _switchAccount,
                            );
                          },
                          icon: const Icon(Icons.switch_account),
                          label: const Text('Switch Account'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: _kBorder),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _confirmSignOut(
                              title: 'Logout',
                              content: 'Are you sure you want to logout?',
                              onConfirm: _logout,
                            );
                          },
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
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
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _kGold.withOpacity(0.1),
            child: Icon(icon, color: _kGold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: _kMutedText),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalOrPlaceholderImage(Map<String, String> profileData) {
    if (_profileImage != null) {
      return kIsWeb
          ? Image.network(
              _profileImage!.path,
              fit: BoxFit.cover,
            )
          : Image.file(
              io.File(_profileImage!.path),
              fit: BoxFit.cover,
            );
    } else {
      return Center(
        child: Text(
          profileData['name']!.isEmpty
              ? '?'
              : profileData['name']![0].toUpperCase(),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: _kGold,
          ),
        ),
      );
    }
  }
}
