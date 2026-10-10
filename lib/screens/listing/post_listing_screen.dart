import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/listings_service.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';

const Color _kBg = Color(0xFF0D0B0A);
const Color _kSurface = Color(0xFF141210);
const Color _kCardBg = Color(0xFF1A1613);
const Color _kGold = Color(0xFFD4AF6A);
const Color _kGoldLight = Color(0xFFE8C98A);
const Color _kMaroon = Color(0xFF7A1F3D);
const Color _kMaroonDark = Color(0xFF4E1220);
const Color _kMuted = Color(0xFF9C9088);
const Color _kBorder = Color(0xFF2A2218);
const Color _kError = Color(0xFFE07A7A);
const Color _kSuccess = Color(0xFF6EC96A);

const List<Map<String, String>> _kCities = [
  // Pakistan
  {'city': 'Lahore', 'country': '🇵🇰'},
  {'city': 'Islamabad', 'country': '🇵🇰'},
  {'city': 'Karachi', 'country': '🇵🇰'},
  {'city': 'Rawalpindi', 'country': '🇵🇰'},
  {'city': 'Faisalabad', 'country': '🇵🇰'},
  {'city': 'Multan', 'country': '🇵🇰'},
  {'city': 'Peshawar', 'country': '🇵🇰'},
  {'city': 'Quetta', 'country': '🇵🇰'},
  {'city': 'Gujranwala', 'country': '🇵🇰'},
  {'city': 'Sialkot', 'country': '🇵🇰'},
  // UK
  {'city': 'London', 'country': '🇬🇧'},
  {'city': 'Manchester', 'country': '🇬🇧'},
  {'city': 'Birmingham', 'country': '🇬🇧'},
  {'city': 'Leeds', 'country': '🇬🇧'},
  {'city': 'Edinburgh', 'country': '🇬🇧'},
  {'city': 'Sheffield', 'country': '🇬🇧'},
  {'city': 'Nottingham', 'country': '🇬🇧'},
  // USA
  {'city': 'New York', 'country': '🇺🇸'},
  {'city': 'Los Angeles', 'country': '🇺🇸'},
  {'city': 'Chicago', 'country': '🇺🇸'},
  {'city': 'Houston', 'country': '🇺🇸'},
  {'city': 'Boston', 'country': '🇺🇸'},
  {'city': 'San Francisco', 'country': '🇺🇸'},
  {'city': 'Seattle', 'country': '🇺🇸'},
  {'city': 'Austin', 'country': '🇺🇸'},
  // Canada
  {'city': 'Toronto', 'country': '🇨🇦'},
  {'city': 'Vancouver', 'country': '🇨🇦'},
  {'city': 'Montreal', 'country': '🇨🇦'},
  {'city': 'Calgary', 'country': '🇨🇦'},
  // Australia
  {'city': 'Melbourne', 'country': '🇦🇺'},
  {'city': 'Sydney', 'country': '🇦🇺'},
  {'city': 'Brisbane', 'country': '🇦🇺'},
  {'city': 'Adelaide', 'country': '🇦🇺'},
  {'city': 'Perth', 'country': '🇦🇺'},
  // Middle East
  {'city': 'Dubai', 'country': '🇦🇪'},
  {'city': 'Abu Dhabi', 'country': '🇦🇪'},
  {'city': 'Riyadh', 'country': '🇸🇦'},
  {'city': 'Jeddah', 'country': '🇸🇦'},
  {'city': 'Doha', 'country': '🇶🇦'},
  {'city': 'Kuwait City', 'country': '🇰🇼'},
  {'city': 'Muscat', 'country': '🇴🇲'},
  // Europe
  {'city': 'Berlin', 'country': '🇩🇪'},
  {'city': 'Munich', 'country': '🇩🇪'},
  {'city': 'Hamburg', 'country': '🇩🇪'},
  {'city': 'Paris', 'country': '🇫🇷'},
  {'city': 'Lyon', 'country': '🇫🇷'},
  {'city': 'Amsterdam', 'country': '🇳🇱'},
  {'city': 'Rotterdam', 'country': '🇳🇱'},
  {'city': 'Barcelona', 'country': '🇪🇸'},
  {'city': 'Madrid', 'country': '🇪🇸'},
  {'city': 'Rome', 'country': '🇮🇹'},
  {'city': 'Milan', 'country': '🇮🇹'},
  {'city': 'Dublin', 'country': '🇮🇪'},
  {'city': 'Lisbon', 'country': '🇵🇹'},
  {'city': 'Stockholm', 'country': '🇸🇪'},
  {'city': 'Oslo', 'country': '🇳🇴'},
  {'city': 'Copenhagen', 'country': '🇩🇰'},
  {'city': 'Helsinki', 'country': '🇫🇮'},
  {'city': 'Warsaw', 'country': '🇵🇱'},
  {'city': 'Prague', 'country': '🇨🇿'},
  {'city': 'Budapest', 'country': '🇭🇺'},
  {'city': 'Vienna', 'country': '🇦🇹'},
  {'city': 'Zurich', 'country': '🇨🇭'},
  {'city': 'Geneva', 'country': '🇨🇭'},
  // East Asia
  {'city': 'Tokyo', 'country': '🇯🇵'},
  {'city': 'Osaka', 'country': '🇯🇵'},
  {'city': 'Seoul', 'country': '🇰🇷'},
  {'city': 'Beijing', 'country': '🇨🇳'},
  {'city': 'Shanghai', 'country': '🇨🇳'},
  {'city': 'Hong Kong', 'country': '🇭🇰'},
  {'city': 'Singapore', 'country': '🇸🇬'},
  {'city': 'Taipei', 'country': '🇹🇼'},
  // Southeast Asia
  {'city': 'Bangkok', 'country': '🇹🇭'},
  {'city': 'Chiang Mai', 'country': '🇹🇭'},
  {'city': 'Kuala Lumpur', 'country': '🇲🇾'},
  {'city': 'Penang', 'country': '🇲🇾'},
  {'city': 'Jakarta', 'country': '🇮🇩'},
  {'city': 'Manila', 'country': '🇵🇭'},
  {'city': 'Hanoi', 'country': '🇻🇳'},
  {'city': 'Ho Chi Minh City', 'country': '🇻🇳'},
  // South Asia
  {'city': 'Delhi', 'country': '🇮🇳'},
  {'city': 'Mumbai', 'country': '🇮🇳'},
  {'city': 'Bangalore', 'country': '🇮🇳'},
  {'city': 'Pune', 'country': '🇮🇳'},
  {'city': 'Hyderabad', 'country': '🇮🇳'},
  {'city': 'Chennai', 'country': '🇮🇳'},
  {'city': 'Kolkata', 'country': '🇮🇳'},
  {'city': 'Ahmedabad', 'country': '🇮🇳'},
  {'city': 'Colombo', 'country': '🇱🇰'},
  {'city': 'Kathmandu', 'country': '🇳🇵'},
  {'city': 'Dhaka', 'country': '🇧🇩'},
  // Africa
  {'city': 'Cairo', 'country': '🇪🇬'},
  {'city': 'Cape Town', 'country': '🇿🇦'},
  {'city': 'Johannesburg', 'country': '🇿🇦'},
  {'city': 'Nairobi', 'country': '🇰🇪'},
  {'city': 'Lagos', 'country': '🇳🇬'},
  {'city': 'Casablanca', 'country': '🇲🇦'},
  // Latin America
  {'city': 'São Paulo', 'country': '🇧🇷'},
  {'city': 'Rio de Janeiro', 'country': '🇧🇷'},
  {'city': 'Mexico City', 'country': '🇲🇽'},
  {'city': 'Guadalajara', 'country': '🇲🇽'},
  {'city': 'Bogotá', 'country': '🇨🇴'},
  {'city': 'Santiago', 'country': '🇨🇱'},
  {'city': 'Buenos Aires', 'country': '🇦🇷'},
  {'city': 'Lima', 'country': '🇵🇪'},
];

// Worldwide currencies — ISO 4217 code with display info
const List<Map<String, String>> _kCurrencies = [
  {'code': 'USD', 'symbol': '\$',   'name': 'US Dollar'},
  {'code': 'EUR', 'symbol': '€',    'name': 'Euro'},
  {'code': 'GBP', 'symbol': '£',    'name': 'British Pound'},
  {'code': 'PKR', 'symbol': 'Rs ',  'name': 'Pak Rupee'},
  {'code': 'INR', 'symbol': '₹',    'name': 'Indian Rupee'},
  {'code': 'AED', 'symbol': 'د.إ ', 'name': 'UAE Dirham'},
  {'code': 'SAR', 'symbol': '﷼ ',   'name': 'Saudi Riyal'},
  {'code': 'QAR', 'symbol': 'ر.ق ', 'name': 'Qatari Riyal'},
  {'code': 'CAD', 'symbol': 'C\$',  'name': 'Canadian Dollar'},
  {'code': 'AUD', 'symbol': 'A\$',  'name': 'Australian Dollar'},
  {'code': 'SGD', 'symbol': 'S\$',  'name': 'Singapore Dollar'},
  {'code': 'CHF', 'symbol': 'CHF ', 'name': 'Swiss Franc'},
  {'code': 'JPY', 'symbol': '¥',    'name': 'Japanese Yen'},
  {'code': 'CNY', 'symbol': '¥',    'name': 'Chinese Yuan'},
  {'code': 'TRY', 'symbol': '₺',    'name': 'Turkish Lira'},
  {'code': 'MYR', 'symbol': 'RM',   'name': 'Malaysian Ringgit'},
  {'code': 'EGP', 'symbol': 'E£',   'name': 'Egyptian Pound'},
  {'code': 'BDT', 'symbol': '৳',    'name': 'Bangla Taka'},
  {'code': 'NPR', 'symbol': 'रू ',   'name': 'Nepali Rupee'},
  {'code': 'LKR', 'symbol': 'රු ',   'name': 'Lankan Rupee'},
  {'code': 'ZAR', 'symbol': 'R',    'name': 'South African Rand'},
  {'code': 'BRL', 'symbol': 'R\$',  'name': 'Brazilian Real'},
  {'code': 'MXN', 'symbol': 'Mex\$','name': 'Mexican Peso'},
  {'code': 'SEK', 'symbol': 'kr ',  'name': 'Swedish Krona'},
  {'code': 'NOK', 'symbol': 'kr ',  'name': 'Norwegian Krone'},
  {'code': 'DKK', 'symbol': 'kr ',  'name': 'Danish Krone'},
  {'code': 'PLN', 'symbol': 'zł ',  'name': 'Polish Złoty'},
  {'code': 'HUF', 'symbol': 'Ft ',  'name': 'Hungarian Forint'},
  {'code': 'CZK', 'symbol': 'Kč ',  'name': 'Czech Koruna'},
  {'code': 'THB', 'symbol': '฿',    'name': 'Thai Baht'},
  {'code': 'IDR', 'symbol': 'Rp ',  'name': 'Indo Rupiah'},
  {'code': 'VND', 'symbol': '₫ ',   'name': 'Viet Đồng'},
  {'code': 'PHP', 'symbol': '₱',    'name': 'Philippine Peso'},
  {'code': 'KRW', 'symbol': '₩',    'name': 'Korean Won'},
  {'code': 'HKD', 'symbol': 'HK\$', 'name': 'HK Dollar'},
  {'code': 'NZD', 'symbol': 'NZ\$', 'name': 'New Zealand Dollar'},
];

const List<String> _kRoomTypes = [
  'Single Room',
  'Shared Room',
  'Studio',
  'Apartment',
  'Hostel',
  'Full House',
];

const List<String> _kGenderPrefs = [
  'Anyone',
  'Male Only',
  'Female Only',
  'Students Only',
];

const List<String> _kRentalPeriods = [
  '/month',
  '/week',
  '/day',
  '/year',
];

class PostListingScreen extends StatefulWidget {
  const PostListingScreen({super.key});

  @override
  State<PostListingScreen> createState() => _PostListingScreenState();
}

class _PostListingScreenState extends State<PostListingScreen> {
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _rentCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _contactNameCtrl = TextEditingController();
  final TextEditingController _contactPhoneCtrl = TextEditingController();
  final TextEditingController _areaCtrl = TextEditingController();
  final TextEditingController _citySearchCtrl = TextEditingController();

  String _selectedCity = 'Lahore';
  String _roomType = 'Single Room';
  String _genderPref = 'Anyone';
  String _selectedCurrency = 'USD';
  String _rentalPeriod = '/month';
  final Set<String> _selectedAmenities = {};
  XFile? _coverImage;
  Uint8List? _coverImageBytes;
  bool _showCityPicker = false;
  String _citySearch = '';

  // Amenities fetched from Supabase
  List<String> _amenities = [];
  bool _loadingAmenities = true;
  String? _amenitiesError;

  List<Map<String, String>> get _filteredCities {
    if (_citySearch.isEmpty) return _kCities;
    final q = _citySearch.toLowerCase();
    return _kCities.where((c) =>
        c['city']!.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadAmenities();
  }

  Future<void> _loadAmenities() async {
    setState(() {
      _loadingAmenities = true;
      _amenitiesError = null;
    });
    try {
      // Agar column ka naam 'name' nahi hai to yahan badal dein
      final data = await Supabase.instance.client
          .from('amenities')
          .select('name');

      final list = (data as List)
          .map((row) => (row['name'] ?? '').toString().trim())
          .where((n) => n.isNotEmpty)
          .toList();

      if (!mounted) return;
      setState(() {
        _amenities = list;
        _loadingAmenities = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _amenitiesError = 'Could not load amenities';
        _loadingAmenities = false;
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _rentCtrl.dispose();
    _descCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _areaCtrl.dispose();
    _citySearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    try {
      final XFile? img = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (img != null) {
        final bytes = await img.readAsBytes();
        setState(() {
          _coverImage = img;
          _coverImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not pick image')),
        );
      }
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    if (_titleCtrl.text.trim().length < 6) {
      _showToast('Title should be at least 6 characters');
      return;
    }
    if (_descCtrl.text.trim().length < 20) {
      _showToast('Description should be at least 20 characters');
      return;
    }
    if (_contactPhoneCtrl.text.trim().length < 7) {
      _showToast('Enter a valid contact number');
      return;
    }

    setState(() => _isSubmitting = true);

    final amenities = _selectedAmenities.toList()..sort();
    final desc = StringBuffer(_descCtrl.text.trim());
    if (amenities.isNotEmpty) {
      desc.write('\n\nAmenities: ${amenities.join(', ')}');
    }
    if (_roomType.isNotEmpty) {
      desc.write('\nRoom Type: $_roomType');
    }
    if (_genderPref.isNotEmpty && _genderPref != 'Anyone') {
      desc.write('\nPreference: $_genderPref');
    }
    if (_contactNameCtrl.text.trim().isNotEmpty) {
      desc.write('\nContact: ${_contactNameCtrl.text.trim()}');
    }
    if (_contactPhoneCtrl.text.trim().isNotEmpty) {
      desc.write('\nPhone: ${_contactPhoneCtrl.text.trim()}');
    }

    var tag = '';
    if (_genderPref == 'Male Only') tag = 'Male Only';
    if (_genderPref == 'Female Only') tag = 'Female Only';

    final UserLocation? loc = LocationService.setManualLocation(_selectedCity);
    final countryName = loc?.countryName;
    final lat = loc?.latitude;
    final lng = loc?.longitude;

    final rentInt = int.tryParse(_rentCtrl.text.trim());
    if (rentInt == null) {
      setState(() => _isSubmitting = false);
      _showToast('Rent should be a valid number');
      return;
    }

    final createdId = await ListingsService.createListing(
      title: _titleCtrl.text.trim(),
      city: _selectedCity,
      country: countryName,
      rent: rentInt,
      currency: _selectedCurrency,
      period: _rentalPeriod,
      tag: tag,
      description: desc.toString(),
      coverImageBytes: _coverImageBytes,
      latitude: lat,
      longitude: lng,
    );

    NotificationService.addNotification(
      title: 'New post published',
      subtitle: _titleCtrl.text.trim(),
      body: '${_rentCtrl.text.trim()}$_rentalPeriod · '
          '${_areaCtrl.text.isNotEmpty ? '${_areaCtrl.text}, ' : ''}$_selectedCity\n'
          '$desc',
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (createdId == null) {
        _showToast('Saved to your device. Will sync when online.');
      }
      _showSuccessDialog();
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _kMaroon,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _kGold, width: 1),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_kGold, _kGoldLight],
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: _kMaroonDark,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Listing Posted!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your room listing has been published. Users can now find and contact you!',
              style: TextStyle(color: _kMuted, fontSize: 13, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kMaroon,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Great!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                children: [
                  _buildCoverImage(),
                  const SizedBox(height: 20),
                  _buildSectionTitle(Icons.badge_outlined, 'Basic Info',
                      'Tell users about your room'),
                  const SizedBox(height: 12),
                  _buildTitleField(),
                  const SizedBox(height: 12),
                  _buildCityPicker(),
                  if (_showCityPicker) _buildCityList(),
                  const SizedBox(height: 12),
                  _buildAreaField(),
                  const SizedBox(height: 20),
                  _buildSectionTitle(Icons.category_outlined, 'Room Details',
                      'Specify type and preferences'),
                  const SizedBox(height: 12),
                  _buildOptionsGrid(
                    title: 'Room Type',
                    options: _kRoomTypes,
                    selected: _roomType,
                    onSelect: (v) => setState(() => _roomType = v),
                    icon: Icons.king_bed_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildOptionsGrid(
                    title: 'Preferred Roommate',
                    options: _kGenderPrefs,
                    selected: _genderPref,
                    onSelect: (v) => setState(() => _genderPref = v),
                    icon: Icons.people_alt_outlined,
                  ),
                  const SizedBox(height: 14),
                  _buildRentRow(),
                  const SizedBox(height: 20),
                  _buildSectionTitle(Icons.checklist_rtl_outlined, 'Amenities',
                      'What facilities do you offer?'),
                  const SizedBox(height: 12),
                  _buildAmenitiesGrid(),
                  const SizedBox(height: 20),
                  _buildSectionTitle(Icons.notes_outlined, 'Description',
                      'Write something about this place'),
                  const SizedBox(height: 12),
                  _buildDescriptionField(),
                  const SizedBox(height: 20),
                  _buildSectionTitle(Icons.contact_page_outlined, 'Contact Info',
                      'How should people reach you?'),
                  const SizedBox(height: 12),
                  _buildContactNameField(),
                  const SizedBox(height: 12),
                  _buildContactPhoneField(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: _kGold,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Publishing your listing...',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _kSurface,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kBorder),
          ),
          child: const Icon(Icons.arrow_back, color: _kGold, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Post a Room',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Get listed & find your roommate',
            style: TextStyle(color: _kMuted, fontSize: 11.5),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _kGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _kGold.withValues(alpha: 0.35)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, color: _kGold, size: 14),
              SizedBox(width: 5),
              Text(
                'Free',
                style: TextStyle(
                  color: _kGold,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kGold, _kGoldLight],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: _kGold, size: 18),
        const SizedBox(width: 8),
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
              Text(
                subtitle,
                style: const TextStyle(color: _kMuted, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoverImage() {
    final hasImage = _coverImageBytes != null;
    return GestureDetector(
      onTap: _pickCoverImage,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? _kGold.withValues(alpha: 0.4) : _kBorder,
            width: hasImage ? 1.5 : 1,
          ),
          image: hasImage
              ? DecorationImage(
            image: MemoryImage(_coverImageBytes!),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: hasImage
            ? Stack(
          children: [
            Positioned(
              right: 10,
              top: 10,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _coverImage = null;
                    _coverImageBytes = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: _kGold, size: 13),
                    SizedBox(width: 5),
                    Text(
                      'Change Cover',
                      style: TextStyle(
                        color: _kGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kGold.withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                color: _kGold,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add Cover Photo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Upload a nice photo to attract more matches',
              style: TextStyle(color: _kMuted, fontSize: 11.5),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _kMaroon.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _kMaroon.withValues(alpha: 0.5),
                ),
              ),
              child: const Text(
                '📸 Tap to choose image',
                style: TextStyle(
                  color: _kGoldLight,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleCtrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      textCapitalization: TextCapitalization.words,
      decoration: _inputDecoration(
        hint: 'e.g. Furnished Room in Johar Town',
        icon: Icons.title,
        label: 'Listing Title',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Enter a title';
        if (v.trim().length < 6) return 'Title is too short';
        return null;
      },
    );
  }

  Widget _buildCityPicker() {
    return GestureDetector(
      onTap: () => setState(() => _showCityPicker = !_showCityPicker),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_city_outlined,
                  color: _kGold, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'City',
                    style: TextStyle(color: _kMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _kCities.firstWhere(
                            (c) => c['city'] == _selectedCity,
                        orElse: () => _kCities.first)['country']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedCity,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedRotation(
              turns: _showCityPicker ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.keyboard_arrow_down,
                  color: _kGold, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityList() {
    final cities = _filteredCities;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          TextField(
            controller: _citySearchCtrl,
            onChanged: (v) => setState(() => _citySearch = v.trim()),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search city...',
              hintStyle: const TextStyle(color: _kMuted, fontSize: 12.5),
              prefixIcon: const Icon(Icons.search, color: _kGold, size: 18),
              filled: true,
              fillColor: _kCardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _kGold),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cities.length,
              itemBuilder: (ctx, idx) {
                final c = cities[idx];
                final selected = c['city'] == _selectedCity;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCity = c['city']!;
                      _showCityPicker = false;
                      _citySearch = '';
                      _citySearchCtrl.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 9),
                    decoration: BoxDecoration(
                      color: selected
                          ? _kGold.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(c['country']!, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            c['city']!,
                            style: TextStyle(
                              color: selected ? _kGoldLight : Colors.white70,
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle,
                              color: _kGold, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaField() {
    return TextFormField(
      controller: _areaCtrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      textCapitalization: TextCapitalization.words,
      decoration: _inputDecoration(
        hint: 'e.g. DHA Phase 5, Gulberg III',
        icon: Icons.location_on_outlined,
        label: 'Area / Sector (optional)',
      ),
    );
  }

  Widget _buildOptionsGrid({
    required String title,
    required List<String> options,
    required String selected,
    required Function(String) onSelect,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _kGold, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: options.map((opt) {
              final isSel = opt == selected;
              return GestureDetector(
                onTap: () => onSelect(opt),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? _kGold.withValues(alpha: 0.18) : _kSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSel ? _kGold : _kBorder,
                      width: isSel ? 1.3 : 1,
                    ),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      color: isSel ? _kGoldLight : Colors.white70,
                      fontSize: 12.5,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRentRow() {
    final symbol = _kCurrencies
        .firstWhere((c) => c['code'] == _selectedCurrency,
        orElse: () => _kCurrencies.first)['symbol'] ??
        '\$';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payments_outlined, color: _kGold, size: 16),
              SizedBox(width: 8),
              Text(
                'Rent Price',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Currency selector
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCurrency,
                    dropdownColor: _kSurface,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: _kGold, size: 16),
                    items: _kCurrencies
                        .map((c) => DropdownMenuItem(
                      value: c['code'],
                      child: Text(
                        '${c['symbol']} ${c['code']}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCurrency = v);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Amount field
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _rentCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _kSurface,
                    hintText: 'e.g. 25000',
                    hintStyle: const TextStyle(color: _kMuted, fontSize: 13),
                    prefixText: symbol,
                    prefixStyle: const TextStyle(
                      color: _kGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _kGold),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter rent amount';
                    }
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Enter valid amount';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              // Rental period
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _rentalPeriod,
                    dropdownColor: _kSurface,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: _kGold, size: 18),
                    items: _kRentalPeriods
                        .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        p,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _rentalPeriod = v);
                    },
                    isExpanded: false,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.spa_outlined, color: _kGold, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedAmenities.isEmpty
                      ? 'Select available amenities'
                      : '${_selectedAmenities.length} selected',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_selectedAmenities.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() => _selectedAmenities.clear()),
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      color: _kError,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (_loadingAmenities)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _kGold,
                  ),
                ),
              ),
            )
          else if (_amenitiesError != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    _amenitiesError!,
                    style: const TextStyle(color: _kError, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: _loadAmenities,
                  child: const Text('Retry', style: TextStyle(color: _kGold)),
                ),
              ],
            )
          else if (_amenities.isEmpty)
              const Text(
                'No amenities available',
                style: TextStyle(color: _kMuted, fontSize: 12),
              )
            else
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: _amenities.map((a) {
                  final sel = _selectedAmenities.contains(a);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (sel) {
                          _selectedAmenities.remove(a);
                        } else {
                          _selectedAmenities.add(a);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? _kGold.withValues(alpha: 0.18)
                            : _kSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel ? _kGold : _kBorder,
                          width: sel ? 1.3 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          sel
                              ? const Icon(Icons.check,
                              color: _kGold, size: 13)
                              : _amenityIcon(a),
                          SizedBox(width: sel ? 6 : 7),
                          Text(
                            a,
                            style: TextStyle(
                              color: sel ? _kGoldLight : Colors.white70,
                              fontSize: 12,
                              fontWeight:
                              sel ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
        ],
      ),
    );
  }

  Widget _amenityIcon(String name) {
    switch (name) {
      case 'WiFi':
        return const Icon(Icons.wifi, color: _kMuted, size: 13);
      case 'AC':
        return const Icon(Icons.ac_unit, color: _kMuted, size: 13);
      case 'Heater':
        return const Icon(Icons.fireplace, color: _kMuted, size: 13);
      case 'Kitchen':
        return const Icon(Icons.kitchen, color: _kMuted, size: 13);
      case 'Parking':
        return const Icon(Icons.local_parking, color: _kMuted, size: 13);
      case 'Laundry':
        return const Icon(Icons.local_laundry_service, color: _kMuted, size: 13);
      case 'Furnished':
        return const Icon(Icons.chair, color: _kMuted, size: 13);
      case 'CCTV':
        return const Icon(Icons.videocam, color: _kMuted, size: 13);
      case 'Elevator':
        return const Icon(Icons.elevator, color: _kMuted, size: 13);
      case 'Power Backup':
        return const Icon(Icons.battery_full, color: _kMuted, size: 13);
      case 'Gas':
        return const Icon(Icons.local_gas_station, color: _kMuted, size: 13);
      case 'Attached Bath':
        return const Icon(Icons.bathtub, color: _kMuted, size: 13);
      default:
        return const Icon(Icons.check_circle_outline,
            color: _kMuted, size: 13);
    }
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: TextFormField(
        controller: _descCtrl,
        maxLines: 6,
        minLines: 5,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText:
          'Describe your place: size, furniture, nearby market/university, rules, etc.',
          hintStyle: TextStyle(color: _kMuted, fontSize: 13, height: 1.5),
          prefixIcon:
          Icon(Icons.edit_note, color: _kGold, size: 22),
          border: InputBorder.none,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Enter a description';
          if (v.trim().length < 20) return 'Add more details (20+ chars)';
          return null;
        },
      ),
    );
  }

  Widget _buildContactNameField() {
    return TextFormField(
      controller: _contactNameCtrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      textCapitalization: TextCapitalization.words,
      decoration: _inputDecoration(
        hint: 'Your name or contact person',
        icon: Icons.person_outline,
        label: 'Contact Name',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Enter contact name';
        return null;
      },
    );
  }

  Widget _buildContactPhoneField() {
    return TextFormField(
      controller: _contactPhoneCtrl,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(
        hint: 'e.g. +92 300 1234567',
        icon: Icons.phone_in_talk_outlined,
        label: 'Phone Number',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Enter phone number';
        if (v.trim().length < 7) return 'Enter valid phone';
        return null;
      },
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required String label,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: _kCardBg,
      hintText: hint,
      hintStyle: const TextStyle(color: _kMuted, fontSize: 13),
      prefixIcon: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 4, 0),
        child: Icon(icon, color: _kGold, size: 20),
      ),
      labelText: label,
      labelStyle: const TextStyle(color: _kMuted, fontSize: 12),
      floatingLabelStyle: const TextStyle(
        color: _kGold,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kGold, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kError),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kError, width: 1.3),
      ),
      errorStyle: const TextStyle(color: _kError, fontSize: 11),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 14),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        border: const Border(top: BorderSide(color: _kBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitPost,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kMaroon,
              foregroundColor: Colors.white,
              disabledBackgroundColor: _kMaroon.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
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
                  'Publishing...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.upload_file_outlined, size: 18),
                SizedBox(width: 8),
                Text(
                  'Publish Listing',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}