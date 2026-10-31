import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/host_request_service.dart';
import 'host_request_status_screen.dart';

const Color _kBackground = Color(0xFF0D0D0D);
const Color _kSurface = Color(0xFF1A1717);
const Color _kCardBg = Color(0xFF1F1B1B);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMaroonEnd = Color(0xFF4E1220);
const Color _kMutedText = Color(0xFF9E9E9E);
const Color _kBorder = Color(0xFF2E2929);
const Color _kError = Color(0xFFE74C3C);

const List<String> _kCities = [
  'Islamabad',
  'Lahore',
  'Karachi',
  'Rawalpindi',
  'Peshawar',
  'Faisalabad',
  'Multan',
  'Quetta',
  'Sialkot',
  'Gujranwala',
  'Hyderabad',
  'Other',
];

const List<String> _kRoomTypes = [
  'Single Room',
  'Shared Room',
  'Master Bed Room',
  'Studio Apartment',
  'Full Flat / Apartment',
  'Hostel Room',
];

const List<String> _kGenderPreferences = [
  'Anyone',
  'Male Only',
  'Female Only',
  'Students Only',
  'Families Only',
];

const List<String> _kAvailableAmenities = [
  'WiFi',
  'Air Conditioning',
  'Attached Bath',
  'Furnished',
  'Geyser / Hot Water',
  'Shared Kitchen',
  'Car / Bike Parking',
  'Security Guard / CCTV',
  'UPS / Generator Backup',
  'Mess / Food Facility',
  'Laundry / Washing Machine',
  'Study Desk & Chair',
];

class CreateOwnerAccountScreen extends StatefulWidget {
  final HostRequest? initialRequest; // If re-applying or editing

  const CreateOwnerAccountScreen({super.key, this.initialRequest});

  @override
  State<CreateOwnerAccountScreen> createState() =>
      _CreateOwnerAccountScreenState();
}

class _CreateOwnerAccountScreenState extends State<CreateOwnerAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Owner Info Controllers
  late TextEditingController _ownerNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _cnicCtrl;
  late TextEditingController _addressCtrl;

  // Room Details Controllers
  late TextEditingController _roomTitleCtrl;
  late TextEditingController _areaCtrl;
  late TextEditingController _rentCtrl;
  late TextEditingController _depositCtrl;
  late TextEditingController _descCtrl;

  String _selectedCity = 'Islamabad';
  String _selectedRoomType = 'Single Room';
  String _selectedGender = 'Anyone';
  final Set<String> _selectedAmenities = {};

  // Room pictures (stored as base64 or URLs)
  final List<String> _roomImages = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata ?? {};

    final init = widget.initialRequest;

    _ownerNameCtrl = TextEditingController(
      text: init?.ownerName ?? meta['name'] ?? meta['full_name'] ?? '',
    );
    _phoneCtrl = TextEditingController(
      text: init?.phone ?? meta['phone'] ?? meta['phone_number'] ?? '',
    );
    _cnicCtrl = TextEditingController(
      text: init?.cnic ?? '',
    );
    _addressCtrl = TextEditingController(
      text: init?.address ?? meta['preferredLocation'] ?? '',
    );

    _roomTitleCtrl = TextEditingController(
      text: init?.roomTitle ?? '',
    );
    _areaCtrl = TextEditingController(
      text: init?.area ?? '',
    );
    _rentCtrl = TextEditingController(
      text: init != null && init.rent > 0 ? init.rent.toString() : '',
    );
    _depositCtrl = TextEditingController(
      text: init != null && init.deposit > 0 ? init.deposit.toString() : '',
    );
    _descCtrl = TextEditingController(
      text: init?.description ?? '',
    );

    if (init != null) {
      if (_kCities.contains(init.city)) {
        _selectedCity = init.city;
      }
      if (_kRoomTypes.contains(init.roomType)) {
        _selectedRoomType = init.roomType;
      }
      if (_kGenderPreferences.contains(init.genderPreference)) {
        _selectedGender = init.genderPreference;
      }
      _selectedAmenities.addAll(init.amenities);
      _roomImages.addAll(init.roomImages);
    } else {
      // Default sample amenities
      _selectedAmenities.addAll(['WiFi', 'Attached Bath', 'Furnished']);
    }
  }

  @override
  void dispose() {
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _cnicCtrl.dispose();
    _addressCtrl.dispose();
    _roomTitleCtrl.dispose();
    _areaCtrl.dispose();
    _rentCtrl.dispose();
    _depositCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _roomImages.add(base64String);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick room image: $e'),
            backgroundColor: _kError,
          ),
        );
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Upload Room Picture',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _kGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: _kGold),
                ),
                title: const Text('Choose from Gallery',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _kGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: _kGold),
                  ),
                  title: const Text('Take a Photo',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields correctly.'),
          backgroundColor: _kError,
        ),
      );
      return;
    }

    if (_roomImages.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _kSurface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Row(
            children: [
              Icon(Icons.add_photo_alternate, color: _kGold),
              SizedBox(width: 8),
              Text('Room Pics Required',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Admin approval requires at least 1 clear photo of the room you want to list. Please upload room pictures.',
            style: TextStyle(color: _kMutedText),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGold,
                foregroundColor: _kBackground,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _showImagePickerModal();
              },
              child: const Text('Add Room Photo'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final rent = int.tryParse(_rentCtrl.text.trim()) ?? 0;
      final deposit = int.tryParse(_depositCtrl.text.trim()) ?? 0;

      final submittedReq = await HostRequestService.submitHostRequest(
        ownerName: _ownerNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        cnic: _cnicCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        roomTitle: _roomTitleCtrl.text.trim(),
        city: _selectedCity,
        area: _areaCtrl.text.trim(),
        roomType: _selectedRoomType,
        rent: rent,
        deposit: deposit,
        genderPreference: _selectedGender,
        description: _descCtrl.text.trim(),
        amenities: _selectedAmenities.toList(),
        roomImages: _roomImages,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      // Open Waiting for Admin Approval Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HostRequestStatusScreen(request: submittedReq),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit host request: $e'),
          backgroundColor: _kError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kBackground,
        elevation: 0,
        title: const Text(
          'Create Owner Account',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_kGold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Submitting to Admin for approval...',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kMaroonStart, _kMaroonEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: _kGold.withOpacity(0.4), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _kGold.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.home_work_rounded,
                                color: _kGoldLight, size: 28),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Become a Verified Host',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Fill in your room details and room pictures. Once Admin approves your application, your host account and room will be activated.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Section 1: Owner Info
                    _buildSectionHeader(
                        '1. OWNER / HOST INFORMATION', Icons.person_pin_rounded),
                    const SizedBox(height: 12),
                    _buildCard([
                      _buildTextField(
                        controller: _ownerNameCtrl,
                        label: 'Full Name / Owner Name *',
                        icon: Icons.person_outline,
                        hint: 'e.g. Muhammad Usman',
                        validator: (v) => (v == null || v.trim().length < 3)
                            ? 'Please enter valid name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _phoneCtrl,
                        label: 'Contact Phone Number *',
                        icon: Icons.phone_outlined,
                        hint: 'e.g. +92 300 1234567',
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().length < 8)
                            ? 'Please enter a valid phone number'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _cnicCtrl,
                        label: 'CNIC / National Identity (Optional for ID)',
                        icon: Icons.badge_outlined,
                        hint: 'e.g. 37405-1234567-1',
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _addressCtrl,
                        label: 'Owner Address / City *',
                        icon: Icons.location_city_outlined,
                        hint: 'e.g. Sector F-8, Islamabad',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter owner address'
                            : null,
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Section 2: Room Details
                    _buildSectionHeader(
                        '2. ROOM & PROPERTY DETAILS', Icons.apartment_rounded),
                    const SizedBox(height: 12),
                    _buildCard([
                      _buildTextField(
                        controller: _roomTitleCtrl,
                        label: 'Room Title *',
                        icon: Icons.title_rounded,
                        hint: 'e.g. Fully Furnished Master Bed Room in F-10',
                        validator: (v) => (v == null || v.trim().length < 6)
                            ? 'Title should be at least 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'City *',
                              value: _selectedCity,
                              items: _kCities,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedCity = val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Room Type *',
                              value: _selectedRoomType,
                              items: _kRoomTypes,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedRoomType = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _areaCtrl,
                        label: 'Specific Area / Sector / Street *',
                        icon: Icons.pin_drop_outlined,
                        hint: 'e.g. F-10/2, Street 34',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter specific area / sector'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _rentCtrl,
                              label: 'Monthly Rent (PKR) *',
                              icon: Icons.payments_outlined,
                              hint: '25000',
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  (v == null || int.tryParse(v.trim()) == null)
                                      ? 'Valid amount required'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _depositCtrl,
                              label: 'Security Deposit (PKR)',
                              icon: Icons.shield_outlined,
                              hint: '10000',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildDropdown(
                        label: 'Preferred Tenant / Gender *',
                        value: _selectedGender,
                        items: _kGenderPreferences,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedGender = val);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _descCtrl,
                        label: 'Full Room Details & Description *',
                        icon: Icons.description_outlined,
                        hint:
                            'Describe room features, attached bath, silent environment, nearby university/markets, house rules...',
                        maxLines: 4,
                        validator: (v) => (v == null || v.trim().length < 15)
                            ? 'Please provide detailed description (min 15 chars)'
                            : null,
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Section 3: Room Pics
                    _buildSectionHeader('3. ROOM PICTURES (REQUIRED)',
                        Icons.photo_library_outlined),
                    const SizedBox(height: 8),
                    Text(
                      'Upload high-quality pictures of the room, washroom, bed, and building. Admin reviews these photos before approving your host profile.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    _buildCard([
                      if (_roomImages.isNotEmpty) ...[
                        SizedBox(
                          height: 130,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _roomImages.length + 1,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              if (index == _roomImages.length) {
                                return InkWell(
                                  onTap: _showImagePickerModal,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 100,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: _kSurface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: _kGold.withOpacity(0.5),
                                          style: BorderStyle.solid),
                                    ),
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo,
                                            color: _kGold, size: 28),
                                        SizedBox(height: 6),
                                        Text('Add More',
                                            style: TextStyle(
                                                color: _kGold, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final imgStr = _roomImages[index];
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _buildImageThumbnail(imgStr, 110, 130),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _roomImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black87,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_roomImages.length} picture(s) attached',
                              style: const TextStyle(
                                  color: _kGoldLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              onPressed: _showImagePickerModal,
                              icon: const Icon(Icons.add_photo_alternate,
                                  color: _kGold, size: 16),
                              label: const Text('Add Another',
                                  style: TextStyle(
                                      color: _kGold, fontSize: 12)),
                            ),
                          ],
                        ),
                      ] else ...[
                        InkWell(
                          onTap: _showImagePickerModal,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 28),
                            decoration: BoxDecoration(
                              color: _kSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: _kGold.withOpacity(0.5), width: 1.5),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _kGold.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      Icons.add_photo_alternate_rounded,
                                      color: _kGold,
                                      size: 32),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Tap to Upload Room Pictures',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Select gallery or camera photos (Min 1 picture)',
                                  style: TextStyle(
                                    color: _kMutedText,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 24),

                    // Section 4: Amenities
                    _buildSectionHeader(
                        '4. AMENITIES INCLUDED', Icons.check_circle_outline),
                    const SizedBox(height: 12),
                    _buildCard([
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _kAvailableAmenities.map((amenity) {
                          final isSelected =
                              _selectedAmenities.contains(amenity);
                          return FilterChip(
                            label: Text(amenity),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAmenities.add(amenity);
                                } else {
                                  _selectedAmenities.remove(amenity);
                                }
                              });
                            },
                            selectedColor: _kGold.withOpacity(0.25),
                            checkmarkColor: _kGoldLight,
                            backgroundColor: _kSurface,
                            labelStyle: TextStyle(
                              color: isSelected ? _kGoldLight : Colors.white70,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected ? _kGold : _kBorder,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ]),
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _submitApplication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kGold,
                          foregroundColor: _kBackground,
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Submit for Admin Approval',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'You will receive a notification once the Admin reviews your request.',
                        style: TextStyle(color: _kMutedText, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _kGold, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _kGoldLight,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _kMutedText, fontSize: 13),
            prefixIcon: Icon(icon, color: _kGold, size: 18),
            filled: true,
            fillColor: _kSurface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kGold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kError),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kError, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              dropdownColor: _kSurface,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: _kGold),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(String source, double width, double height) {
    if (source.startsWith('data:image')) {
      final base64Part = source.split(',').last;
      return Image.memory(
        base64Decode(base64Part),
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
    if (source.startsWith('http')) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: _kSurface,
          child: const Icon(Icons.broken_image, color: _kMutedText),
        ),
      );
    }
    return Container(
      width: width,
      height: height,
      color: _kSurface,
      child: const Icon(Icons.image, color: _kMutedText),
    );
  }
}

