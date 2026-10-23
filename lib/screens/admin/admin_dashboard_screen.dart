import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/listings_service.dart';
import '../home/home_screen.dart';
import '../home/host_dashboard.dart';
import '../home/renter_dashboard.dart';
import '../home/listing_detail_screen.dart';

// ---- Luxury Dark & Gold/Maroon Theme (matching Roommate Finder design) ----
const Color _kBackground = Color(0xFF0D0D0D);
const Color _kSurface = Color(0xFF1A1717);
const Color _kCardBg = Color(0xFF1F1B1B);
const Color _kCardBgLight = Color(0xFF262121);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kGoldDark = Color(0xFF99732E);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMaroonEnd = Color(0xFF4E1220);
const Color _kMutedText = Color(0xFF9E9E9E);
const Color _kBorder = Color(0xFF2E2929);
const Color _kSuccess = Color(0xFF2ECC71);
const Color _kWarning = Color(0xFFF39C12);
const Color _kDanger = Color(0xFFE74C3C);
const Color _kInfo = Color(0xFF3498DB);

enum AdminSection {
  dashboard,
  manageUsers,
  manageHosts,
  manageListings,
  pendingListings,
  reports,
  analytics,
  notifications,
  amenities,
  cities,
  settings,
  profile,
}

class AdminDashboardScreen extends StatefulWidget {
  final AdminSection initialSection;

  const AdminDashboardScreen({
    super.key,
    this.initialSection = AdminSection.dashboard,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late AdminSection _currentSection;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // In-memory state for Admin interactive features
  bool _isLoading = false;
  String _userSearchQuery = '';
  String _listingSearchQuery = '';
  String _userFilter = 'All'; // All, Active, Verified, Blocked
  String _listingCityFilter = 'All';

  // Sample data & synced listings
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _hosts = [];
  List<Map<String, dynamic>> _pendingListings = [];
  List<Map<String, dynamic>> _activeListings = [];
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _broadcasts = [];
  List<Map<String, dynamic>> _amenitiesList = [];
  List<Map<String, dynamic>> _citiesList = [];

  // Platform Settings State
  bool _settingRequireApproval = true;
  bool _settingEnableChat = true;
  bool _settingMaintenanceMode = false;
  bool _settingGuestBrowsing = true;
  double _settingCommissionRate = 5.0;
  int _settingListingDurationDays = 60;

  @override
  void initState() {
    super.initState();
    _currentSection = widget.initialSection;
    _initializeData();
  }

  void _initializeData() {
    _users = [
      {
        'id': 'usr_1',
        'name': 'Hamza Ali',
        'email': 'hamza.ali@example.com',
        'phone': '+92 301 2345678',
        'role': 'Renter',
        'status': 'Active',
        'isVerified': true,
        'joined': '12 Jan 2026',
        'budget': 'PKR 25,000',
        'city': 'Lahore',
      },
      {
        'id': 'usr_2',
        'name': 'Ayesha Khan',
        'email': 'ayesha.k@example.com',
        'phone': '+92 322 8765432',
        'role': 'Renter',
        'status': 'Active',
        'isVerified': true,
        'joined': '18 Feb 2026',
        'budget': 'PKR 30,000',
        'city': 'Islamabad',
      },
      {
        'id': 'usr_3',
        'name': 'Bilal Tariq',
        'email': 'bilal.tariq@example.com',
        'phone': '+92 333 4567890',
        'role': 'Renter',
        'status': 'Blocked',
        'isVerified': false,
        'joined': '02 Mar 2026',
        'budget': 'PKR 18,000',
        'city': 'Karachi',
      },
      {
        'id': 'usr_4',
        'name': 'Zainab Fatima',
        'email': 'zainab.f@example.com',
        'phone': '+92 345 6789012',
        'role': 'Renter',
        'status': 'Active',
        'isVerified': false,
        'joined': '25 Mar 2026',
        'budget': 'PKR 20,000',
        'city': 'Rawalpindi',
      },
      {
        'id': 'usr_5',
        'name': 'Usman Sheikh',
        'email': 'usman.s@example.com',
        'phone': '+92 312 9012345',
        'role': 'Renter',
        'status': 'Active',
        'isVerified': true,
        'joined': '04 Apr 2026',
        'budget': 'PKR 22,000',
        'city': 'Faisalabad',
      },
    ];

    _hosts = [
      {
        'id': 'host_1',
        'name': 'Malik Property Group',
        'email': 'malik.properties@example.com',
        'phone': '+92 300 9876543',
        'listingsCount': 6,
        'isSuperhost': true,
        'rating': 4.9,
        'joined': 'Nov 2025',
        'city': 'Lahore',
        'status': 'Active',
      },
      {
        'id': 'host_2',
        'name': 'Dr. Tariq Mahmood',
        'email': 'tariq.m@example.com',
        'phone': '+92 321 5432109',
        'listingsCount': 2,
        'isSuperhost': true,
        'rating': 4.8,
        'joined': 'Dec 2025',
        'city': 'Islamabad',
        'status': 'Active',
      },
      {
        'id': 'host_3',
        'name': 'Sara Hostels Management',
        'email': 'sara.hostels@example.com',
        'phone': '+92 334 1122334',
        'listingsCount': 11,
        'isSuperhost': false,
        'rating': 4.2,
        'joined': 'Jan 2026',
        'city': 'Karachi',
        'status': 'Active',
      },
      {
        'id': 'host_4',
        'name': 'Ahmed Real Estate',
        'email': 'ahmed.estate@example.com',
        'phone': '+92 313 7788990',
        'listingsCount': 1,
        'isSuperhost': false,
        'rating': 3.5,
        'joined': 'Mar 2026',
        'city': 'Rawalpindi',
        'status': 'Under Review',
      },
    ];

    _pendingListings = [
      {
        'id': 'pending_1',
        'title': 'Luxury Master Bed in DHA Phase 6',
        'city': 'Lahore',
        'hostName': 'Malik Property Group',
        'hostPhone': '+92 300 9876543',
        'rent': 'PKR 35,000',
        'roomType': 'Single Room',
        'tag': 'Male Only',
        'submittedAt': '2 hours ago',
        'description':
            'Spacious master bedroom with attached bath, AC, and high-speed fiber internet in DHA Lahore.',
        'imageUrl':
            'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
      },
      {
        'id': 'pending_2',
        'title': 'Furnished Room near F-10 Markaz',
        'city': 'Islamabad',
        'hostName': 'Dr. Tariq Mahmood',
        'hostPhone': '+92 321 5432109',
        'rent': 'PKR 28,000',
        'roomType': 'Single Room',
        'tag': 'Female Only',
        'submittedAt': '5 hours ago',
        'description':
            'Safe, quiet furnished room for working women/students. Walking distance to market and metro.',
        'imageUrl':
            'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=600&q=80',
      },
      {
        'id': 'pending_3',
        'title': 'Shared Apartment Bedspace in Clifton',
        'city': 'Karachi',
        'hostName': 'Sara Hostels Management',
        'hostPhone': '+92 334 1122334',
        'rent': 'PKR 16,000',
        'roomType': 'Shared Room',
        'tag': 'Female Only',
        'submittedAt': '1 day ago',
        'description':
            'Clean bedspace in 3-bed apartment in Clifton Block 2 with 24/7 security and backup generator.',
        'imageUrl':
            'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=600&q=80',
      },
    ];

    _activeListings = [
      {
        'id': 'active_1',
        'title': '2 Bed Luxury Flat in Johar Town',
        'city': 'Lahore',
        'rent': 'PKR 45,000',
        'roomType': 'Apartment',
        'hostName': 'Malik Property Group',
        'isFeatured': true,
        'status': 'Active',
        'views': 412,
        'inquiries': 19,
        'imageUrl':
            'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=600&q=80',
      },
      {
        'id': 'active_2',
        'title': 'Quiet Student Room near NUST',
        'city': 'Islamabad',
        'rent': 'PKR 18,000',
        'roomType': 'Single Room',
        'hostName': 'Dr. Tariq Mahmood',
        'isFeatured': false,
        'status': 'Active',
        'views': 298,
        'inquiries': 14,
        'imageUrl':
            'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
      },
      {
        'id': 'active_3',
        'title': 'DHA Phase 5 Room with Balcony',
        'city': 'Karachi',
        'rent': 'PKR 32,000',
        'roomType': 'Single Room',
        'hostName': 'Sara Hostels Management',
        'isFeatured': true,
        'status': 'Active',
        'views': 580,
        'inquiries': 27,
        'imageUrl':
            'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?auto=format&fit=crop&w=600&q=80',
      },
    ];

    _reports = [
      {
        'id': 'rep_1',
        'type': 'Scam / False Pricing',
        'severity': 'High',
        'status': 'Open',
        'reportedItem': 'Listing: Room near Gulberg',
        'reportedBy': 'Hamza Ali (Seeker)',
        'targetUser': 'Ahmed Real Estate',
        'details':
            'Host demanded 3 months advance cash before showing room and refused video call verification.',
        'date': 'Yesterday',
      },
      {
        'id': 'rep_2',
        'type': 'Misleading Photos',
        'severity': 'Medium',
        'status': 'Open',
        'reportedItem': 'Listing: Flat in DHA Phase 2',
        'reportedBy': 'Ayesha Khan',
        'targetUser': 'Sara Hostels Management',
        'details':
            'Photos showed fully furnished bedroom, but visit revealed an unfurnished empty room.',
        'date': '3 days ago',
      },
      {
        'id': 'rep_3',
        'type': 'Inappropriate Behavior',
        'severity': 'Critical',
        'status': 'In Review',
        'reportedItem': 'User Profile: Bilal Tariq',
        'reportedBy': 'Zainab Fatima',
        'targetUser': 'Bilal Tariq',
        'details':
            'Sent uninvited aggressive messages in chat after rental request was declined.',
        'date': '4 days ago',
      },
    ];

    _broadcasts = [
      {
        'id': 'bc_1',
        'title': 'Safety Guidelines for Roommate Meetups',
        'target': 'All Users',
        'date': '10 Apr 2026',
        'views': 1240,
      },
      {
        'id': 'bc_2',
        'title': 'Host Verification Policy Update',
        'target': 'Hosts Only',
        'date': '02 Apr 2026',
        'views': 195,
      },
    ];

    _amenitiesList = [
      {'name': 'High-Speed WiFi', 'icon': Icons.wifi, 'enabled': true},
      {'name': 'Air Conditioning (AC)', 'icon': Icons.ac_unit, 'enabled': true},
      {'name': 'Attached Washroom', 'icon': Icons.bathtub_outlined, 'enabled': true},
      {'name': 'UPS / Generator Backup', 'icon': Icons.power, 'enabled': true},
      {'name': 'Dedicated Parking', 'icon': Icons.local_parking, 'enabled': true},
      {'name': 'Equipped Kitchen', 'icon': Icons.kitchen, 'enabled': true},
      {'name': 'Instant Geyser / Hot Water', 'icon': Icons.water_damage_outlined, 'enabled': true},
      {'name': '24/7 Security Guard / CCTV', 'icon': Icons.security, 'enabled': true},
      {'name': 'Fully Furnished', 'icon': Icons.chair_outlined, 'enabled': true},
      {'name': 'Laundry / Washing Machine', 'icon': Icons.local_laundry_service, 'enabled': true},
      {'name': 'Balcony / Terrace', 'icon': Icons.balcony, 'enabled': true},
      {'name': 'Gym Facility', 'icon': Icons.fitness_center, 'enabled': false},
    ];

    _citiesList = [
      {'name': 'Lahore', 'province': 'Punjab', 'listings': 148, 'enabled': true},
      {'name': 'Islamabad', 'province': 'Federal', 'listings': 112, 'enabled': true},
      {'name': 'Karachi', 'province': 'Sindh', 'listings': 96, 'enabled': true},
      {'name': 'Rawalpindi', 'province': 'Punjab', 'listings': 42, 'enabled': true},
      {'name': 'Faisalabad', 'province': 'Punjab', 'listings': 18, 'enabled': true},
      {'name': 'Peshawar', 'province': 'KPK', 'listings': 14, 'enabled': true},
      {'name': 'Multan', 'province': 'Punjab', 'listings': 9, 'enabled': true},
      {'name': 'Sialkot', 'province': 'Punjab', 'listings': 6, 'enabled': false},
    ];

    _fetchRealListingsIfAvailable();
  }

  Future<void> _fetchRealListingsIfAvailable() async {
    try {
      final reqApproval = await ListingsService.isApprovalRequired();
      if (mounted) {
        setState(() => _settingRequireApproval = reqApproval);
      }

      // 1. Fetch real pending listings from users/hosts awaiting Admin review
      final pendingRooms = await ListingsService.fetchPendingListings();
      if (mounted && pendingRooms.isNotEmpty) {
        setState(() {
          for (final p in pendingRooms) {
            final Map<String, dynamic> item = {
              'id': p.id,
              'title': p.title,
              'city': p.city,
              'hostName': p.hostName ?? 'User / Host',
              'hostPhone': p.hostPhone ?? '+92 300 0000000',
              'hostEmail': p.hostEmail ?? '',
              'rent': p.rentDisplay,
              'roomType': p.roomType ?? (p.tag.isNotEmpty ? p.tag : 'Single Room'),
              'tag': p.tag,
              'submittedAt': p.submittedAt ?? 'Recent',
              'description': p.description ?? 'Room awaiting administrative review.',
              'imageUrl': p.imageUrl ??
                  'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
            };
            if (!_pendingListings.any((x) => x['id'] == p.id)) {
              _pendingListings.insert(0, item);
            }
          }
        });
      }

      // 2. Fetch approved active listings
      final real = await ListingsService.fetchListings(approvedOnly: true, limit: 30);
      if (real.isNotEmpty && mounted) {
        setState(() {
          for (final item in real) {
            if (!_activeListings.any((l) => l['id'] == item.id)) {
              _activeListings.insert(0, {
                'id': item.id,
                'title': item.title,
                'city': item.city,
                'rent': item.rentDisplay,
                'roomType': item.tag.isNotEmpty ? item.tag : 'Room',
                'hostName': item.hostName ?? 'Verified Host',
                'isFeatured': item.isFeatured,
                'status': 'Active',
                'views': 120,
                'inquiries': 5,
                'imageUrl': item.imageUrl ??
                    'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=600&q=80',
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint('_fetchRealListingsIfAvailable error: $e');
    }
  }

  void _showSnackBar(String text, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info_outline,
              color: isSuccess ? _kSuccess : _kWarning,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: _kSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: isSuccess ? _kSuccess : _kWarning, width: 0.8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ---------------- UI BUILD METHODS ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _kBackground,
      appBar: _buildAppBar(),
      drawer: _buildAdminDrawer(),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildCurrentSection(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _kSurface,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: _kGold, size: 28),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Row(
        children: [
          Image.asset(
            'assets/icons/appicon.png',
            height: 26,
            width: 26,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kMaroonStart, _kMaroonEnd],
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _kGold.withOpacity(0.5)),
            ),
            child: const Text(
              'ADMIN',
              style: TextStyle(
                color: _kGoldLight,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _getSectionTitle(_currentSection),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Quick Refresh',
          icon: const Icon(Icons.refresh_rounded, color: _kMutedText, size: 22),
          onPressed: () {
            _initializeData();
            _showSnackBar('Admin data refreshed');
          },
        ),
        IconButton(
          tooltip: 'Switch to App',
          icon: const Icon(Icons.home_outlined, color: _kGold, size: 24),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen(forceBrowse: true)),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: _kBorder, height: 1),
      ),
    );
  }

  String _getSectionTitle(AdminSection s) {
    switch (s) {
      case AdminSection.dashboard:
        return 'Admin Dashboard';
      case AdminSection.manageUsers:
        return 'Manage Users';
      case AdminSection.manageHosts:
        return 'Manage Hosts';
      case AdminSection.manageListings:
        return 'Manage Listings';
      case AdminSection.pendingListings:
        return 'Pending Approvals';
      case AdminSection.reports:
        return 'Reports & Moderation';
      case AdminSection.analytics:
        return 'Platform Analytics';
      case AdminSection.notifications:
        return 'Broadcast Notifications';
      case AdminSection.amenities:
        return 'Amenities Management';
      case AdminSection.cities:
        return 'Cities Coverage';
      case AdminSection.settings:
        return 'Platform Settings';
      case AdminSection.profile:
        return 'Super Admin Profile';
    }
  }

  Widget _buildCurrentSection() {
    switch (_currentSection) {
      case AdminSection.dashboard:
        return _buildDashboardOverview();
      case AdminSection.manageUsers:
        return _buildManageUsersView();
      case AdminSection.manageHosts:
        return _buildManageHostsView();
      case AdminSection.manageListings:
        return _buildManageListingsView();
      case AdminSection.pendingListings:
        return _buildPendingListingsView();
      case AdminSection.reports:
        return _buildReportsView();
      case AdminSection.analytics:
        return _buildAnalyticsView();
      case AdminSection.notifications:
        return _buildNotificationsView();
      case AdminSection.amenities:
        return _buildAmenitiesView();
      case AdminSection.cities:
        return _buildCitiesView();
      case AdminSection.settings:
        return _buildSettingsView();
      case AdminSection.profile:
        return _buildProfileView();
    }
  }

  // ---------------- DRAWER NAVIGATION ----------------

  Widget _buildAdminDrawer() {
    return Drawer(
      backgroundColor: _kSurface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_kMaroonStart, _kMaroonEnd, _kSurface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _kGold, width: 2),
                    gradient: const LinearGradient(
                      colors: [_kGold, _kGoldDark],
                    ),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: _kBackground,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Roommate Finder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Super Admin Hub',
                        style: TextStyle(
                          color: _kGoldLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Admin Dashboard',
                  section: AdminSection.dashboard,
                ),
                const Divider(color: _kBorder, height: 16, indent: 16, endIndent: 16),
                _buildDrawerSectionHeader('USERS & HOSTS'),
                _buildDrawerItem(
                  icon: Icons.people_alt_outlined,
                  title: 'Manage Users',
                  section: AdminSection.manageUsers,
                  badge: '${_users.length}',
                ),
                _buildDrawerItem(
                  icon: Icons.home_work_outlined,
                  title: 'Manage Hosts',
                  section: AdminSection.manageHosts,
                  badge: '${_hosts.length}',
                ),
                const Divider(color: _kBorder, height: 16, indent: 16, endIndent: 16),
                _buildDrawerSectionHeader('LISTINGS & MODERATION'),
                _buildDrawerItem(
                  icon: Icons.apartment_rounded,
                  title: 'Manage Listings',
                  section: AdminSection.manageListings,
                  badge: '${_activeListings.length}',
                ),
                _buildDrawerItem(
                  icon: Icons.hourglass_top_rounded,
                  title: 'Pending Listings',
                  section: AdminSection.pendingListings,
                  badge: '${_pendingListings.length}',
                  badgeColor: _kWarning,
                ),
                _buildDrawerItem(
                  icon: Icons.flag_outlined,
                  title: 'Reports & Flagged',
                  section: AdminSection.reports,
                  badge: '${_reports.length}',
                  badgeColor: _kDanger,
                ),
                const Divider(color: _kBorder, height: 16, indent: 16, endIndent: 16),
                _buildDrawerSectionHeader('MANAGEMENT & SYSTEM'),
                _buildDrawerItem(
                  icon: Icons.insights_rounded,
                  title: 'Analytics',
                  section: AdminSection.analytics,
                ),
                _buildDrawerItem(
                  icon: Icons.campaign_outlined,
                  title: 'Notifications',
                  section: AdminSection.notifications,
                ),
                _buildDrawerItem(
                  icon: Icons.checklist_rounded,
                  title: 'Amenities',
                  section: AdminSection.amenities,
                  badge: '${_amenitiesList.length}',
                ),
                _buildDrawerItem(
                  icon: Icons.location_city_rounded,
                  title: 'Cities Coverage',
                  section: AdminSection.cities,
                  badge: '${_citiesList.length}',
                ),
                _buildDrawerItem(
                  icon: Icons.settings_suggest_outlined,
                  title: 'Platform Settings',
                  section: AdminSection.settings,
                ),
                _buildDrawerItem(
                  icon: Icons.person_pin_circle_outlined,
                  title: 'Super Admin Profile',
                  section: AdminSection.profile,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _kBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(forceBrowse: true),
                        ),
                      );
                    },
                    icon: const Icon(Icons.exit_to_app, color: _kGold, size: 18),
                    label: const Text(
                      'Exit to App',
                      style: TextStyle(color: _kGold, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _kGold),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      child: Text(
        title,
        style: const TextStyle(
          color: _kMutedText,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required AdminSection section,
    String? badge,
    Color? badgeColor,
  }) {
    final bool isSelected = _currentSection == section;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? _kMaroonStart.withOpacity(0.35) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: _kGold.withOpacity(0.6), width: 1)
            : null,
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: isSelected ? _kGold : _kMutedText,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[300],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? _kGold).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (badgeColor ?? _kGold), width: 0.8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeColor ?? _kGoldLight,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () {
          setState(() => _currentSection = section);
          Navigator.pop(context);
        },
      ),
    );
  }

  // =====================================================================
  // 1. DASHBOARD OVERVIEW HUB
  // =====================================================================

  Widget _buildDashboardOverview() {
    return RefreshIndicator(
      color: _kGold,
      backgroundColor: _kSurface,
      onRefresh: () async => _initializeData(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kMaroonStart, _kMaroonEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kGold.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_rounded, color: _kGoldLight, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'System Command Center',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kSuccess.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _kSuccess, width: 0.8),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(radius: 3, backgroundColor: _kSuccess),
                          SizedBox(width: 5),
                          Text(
                            'Live',
                            style: TextStyle(
                              color: _kSuccess,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage all users, hosts, moderation requests, and platform configurations in real time.',
                  style: TextStyle(color: Colors.grey[300], fontSize: 13),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPillButton(
                      '${_pendingListings.length} Pending Approval',
                      Icons.hourglass_bottom,
                      _kWarning,
                      () => setState(() => _currentSection = AdminSection.pendingListings),
                    ),
                    _buildPillButton(
                      '${_reports.length} Flagged Reports',
                      Icons.flag,
                      _kDanger,
                      () => setState(() => _currentSection = AdminSection.reports),
                    ),
                    _buildPillButton(
                      'Send Broadcast',
                      Icons.campaign,
                      _kGold,
                      () => setState(() => _currentSection = AdminSection.notifications),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // KPI Stats Grid
          const Text(
            'KEY METRICS',
            style: TextStyle(
              color: _kGoldLight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.35,
            children: [
              _buildMetricCard(
                title: 'Total Users',
                value: '1,842',
                delta: '+14% this month',
                icon: Icons.people_outline,
                color: _kInfo,
                onTap: () => setState(() => _currentSection = AdminSection.manageUsers),
              ),
              _buildMetricCard(
                title: 'Verified Hosts',
                value: '${_hosts.length * 48}',
                delta: '+8 this week',
                icon: Icons.home_work_outlined,
                color: _kGold,
                onTap: () => setState(() => _currentSection = AdminSection.manageHosts),
              ),
              _buildMetricCard(
                title: 'Live Listings',
                value: '${_activeListings.length + 320}',
                delta: 'Across 8 cities',
                icon: Icons.apartment_rounded,
                color: _kSuccess,
                onTap: () => setState(() => _currentSection = AdminSection.manageListings),
              ),
              _buildMetricCard(
                title: 'Pending Reviews',
                value: '${_pendingListings.length}',
                delta: 'Requires action',
                icon: Icons.pending_actions_rounded,
                color: _kWarning,
                onTap: () => setState(() => _currentSection = AdminSection.pendingListings),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Action Navigation Grid
          const Text(
            'QUICK SHORTCUTS',
            style: TextStyle(
              color: _kGoldLight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          _buildShortcutGrid(),
          const SizedBox(height: 24),

          // Recent Activity Log
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LIVE SYSTEM ACTIVITY',
                style: TextStyle(
                  color: _kGoldLight,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Auto-updated',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildActivityTimeline(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPillButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _kBackground.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String delta,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _kMutedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              delta,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutGrid() {
    final items = [
      {'title': 'Manage Users', 'icon': Icons.people, 'section': AdminSection.manageUsers},
      {'title': 'Manage Hosts', 'icon': Icons.home_work, 'section': AdminSection.manageHosts},
      {'title': 'Listings', 'icon': Icons.apartment, 'section': AdminSection.manageListings},
      {'title': 'Pending', 'icon': Icons.pending, 'section': AdminSection.pendingListings},
      {'title': 'Reports', 'icon': Icons.report_problem, 'section': AdminSection.reports},
      {'title': 'Analytics', 'icon': Icons.insights, 'section': AdminSection.analytics},
      {'title': 'Broadcast', 'icon': Icons.send, 'section': AdminSection.notifications},
      {'title': 'Amenities', 'icon': Icons.check_circle_outline, 'section': AdminSection.amenities},
      {'title': 'Cities', 'icon': Icons.location_city, 'section': AdminSection.cities},
      {'title': 'Settings', 'icon': Icons.settings, 'section': AdminSection.settings},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 44) / 2,
          child: InkWell(
            onTap: () => setState(() => _currentSection = item['section'] as AdminSection),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kBorder),
              ),
              child: Row(
                children: [
                  Icon(item['icon'] as IconData, color: _kGold, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: _kMutedText, size: 16),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityTimeline() {
    final activities = [
      {
        'title': 'New Listing Submitted',
        'subtitle': 'Malik Property Group in DHA Phase 6',
        'time': '12 mins ago',
        'icon': Icons.add_home_work,
        'color': _kInfo,
      },
      {
        'title': 'Report Flagged by User',
        'subtitle': 'Scam / False pricing alert on Gulberg flat',
        'time': '45 mins ago',
        'icon': Icons.flag,
        'color': _kDanger,
      },
      {
        'title': 'Host Account Verified',
        'subtitle': 'Dr. Tariq Mahmood verified with CNIC',
        'time': '2 hours ago',
        'icon': Icons.verified,
        'color': _kSuccess,
      },
      {
        'title': 'System Broadcast Sent',
        'subtitle': '"Safety Guidelines for Roommate Meetups"',
        'time': 'Yesterday',
        'icon': Icons.campaign,
        'color': _kGold,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (_, __) => const Divider(color: _kBorder, height: 1),
        itemBuilder: (context, idx) {
          final act = activities[idx];
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: (act['color'] as Color).withOpacity(0.2),
              child: Icon(act['icon'] as IconData, color: act['color'] as Color, size: 16),
            ),
            title: Text(
              act['title'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            subtitle: Text(
              act['subtitle'] as String,
              style: const TextStyle(color: _kMutedText, fontSize: 11),
            ),
            trailing: Text(
              act['time'] as String,
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          );
        },
      ),
    );
  }

  // =====================================================================
  // 2. MANAGE USERS
  // =====================================================================

  Widget _buildManageUsersView() {
    final filtered = _users.where((u) {
      final matchesSearch = u['name'].toString().toLowerCase().contains(_userSearchQuery.toLowerCase()) ||
          u['email'].toString().toLowerCase().contains(_userSearchQuery.toLowerCase()) ||
          u['city'].toString().toLowerCase().contains(_userSearchQuery.toLowerCase());
      if (!matchesSearch) return false;
      if (_userFilter == 'Active') return u['status'] == 'Active';
      if (_userFilter == 'Verified') return u['isVerified'] == true;
      if (_userFilter == 'Blocked') return u['status'] == 'Blocked';
      return true;
    }).toList();

    return Column(
      children: [
        // Search & Filter header
        Container(
          padding: const EdgeInsets.all(16),
          color: _kSurface,
          child: Column(
            children: [
              TextField(
                onChanged: (val) => setState(() => _userSearchQuery = val),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search renters by name, email, city...',
                  hintStyle: const TextStyle(color: _kMutedText, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: _kGold, size: 20),
                  filled: true,
                  fillColor: _kCardBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Active', 'Verified', 'Blocked'].map((filter) {
                    final selected = _userFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: selected,
                        onSelected: (_) => setState(() => _userFilter = filter),
                        selectedColor: _kGold,
                        backgroundColor: _kCardBg,
                        labelStyle: TextStyle(
                          color: selected ? _kBackground : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // User Cards List
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyPlaceholder('No users found', Icons.person_off_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    final isBlocked = user['status'] == 'Blocked';
                    final isVerified = user['isVerified'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _kCardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isBlocked ? _kDanger.withOpacity(0.5) : _kBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: _kSurface,
                                child: Text(
                                  user['name'][0].toUpperCase(),
                                  style: const TextStyle(
                                    color: _kGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          user['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        if (isVerified)
                                          const Icon(
                                            Icons.verified,
                                            color: _kSuccess,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${user['email']} • ${user['city']}',
                                      style: const TextStyle(
                                        color: _kMutedText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isBlocked
                                      ? _kDanger.withOpacity(0.2)
                                      : _kSuccess.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isBlocked ? _kDanger : _kSuccess,
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  user['status'],
                                  style: TextStyle(
                                    color: isBlocked ? _kDanger : _kSuccess,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildUserMetaTag(Icons.phone, user['phone']),
                              const SizedBox(width: 8),
                              _buildUserMetaTag(Icons.monetization_on, user['budget']),
                              const Spacer(),
                              Text(
                                'Joined: ${user['joined']}',
                                style: TextStyle(color: Colors.grey[500], fontSize: 10),
                              ),
                            ],
                          ),
                          const Divider(color: _kBorder, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    user['isVerified'] = !isVerified;
                                  });
                                  _showSnackBar(
                                    isVerified
                                        ? 'Verification removed for ${user['name']}'
                                        : '${user['name']} marked as Verified!',
                                  );
                                },
                                icon: Icon(
                                  isVerified ? Icons.cancel_outlined : Icons.verified_outlined,
                                  color: isVerified ? _kMutedText : _kSuccess,
                                  size: 16,
                                ),
                                label: Text(
                                  isVerified ? 'Unverify' : 'Verify Badge',
                                  style: TextStyle(
                                    color: isVerified ? _kMutedText : _kSuccess,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    user['status'] = isBlocked ? 'Active' : 'Blocked';
                                  });
                                  _showSnackBar(
                                    isBlocked
                                        ? '${user['name']} has been Unblocked'
                                        : '${user['name']} has been Blocked from platform',
                                    isSuccess: isBlocked,
                                  );
                                },
                                icon: Icon(
                                  isBlocked ? Icons.lock_open : Icons.block,
                                  color: isBlocked ? _kSuccess : _kDanger,
                                  size: 16,
                                ),
                                label: Text(
                                  isBlocked ? 'Unblock' : 'Suspend',
                                  style: TextStyle(
                                    color: isBlocked ? _kSuccess : _kDanger,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUserMetaTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _kGold, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // 3. MANAGE HOSTS
  // =====================================================================

  Widget _buildManageHostsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _hosts.length,
      itemBuilder: (context, index) {
        final host = _hosts[index];
        final isSuperhost = host['isSuperhost'] == true;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSuperhost ? _kGold.withOpacity(0.6) : _kBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _kSurface,
                      shape: BoxShape.circle,
                      border: Border.all(color: _kGold, width: 1.5),
                    ),
                    child: const Icon(Icons.home_work, color: _kGold, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                host['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isSuperhost) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _kGold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: _kGold, width: 0.8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, color: _kGold, size: 10),
                                    SizedBox(width: 2),
                                    Text(
                                      'SUPERHOST',
                                      style: TextStyle(
                                        color: _kGoldLight,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${host['email']} • ${host['city']}',
                          style: const TextStyle(color: _kMutedText, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          host['phone'],
                          style: const TextStyle(color: _kGoldLight, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHostStatCol('Listings', '${host['listingsCount']} Units'),
                    _buildHostStatCol('Rating', '${host['rating']} ★'),
                    _buildHostStatCol('Member Since', host['joined']),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        host['isSuperhost'] = !isSuperhost;
                      });
                      _showSnackBar(
                        isSuperhost
                            ? '${host['name']} Superhost badge removed'
                            : '${host['name']} awarded Superhost status!',
                      );
                    },
                    icon: Icon(
                      isSuperhost ? Icons.star_border : Icons.star,
                      color: _kGold,
                      size: 16,
                    ),
                    label: Text(
                      isSuperhost ? 'Revoke Superhost' : 'Make Superhost',
                      style: const TextStyle(color: _kGold, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _kGold),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _currentSection = AdminSection.manageListings);
                    },
                    icon: const Icon(Icons.list_alt, size: 16),
                    label: const Text('View Properties', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kMaroonStart,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHostStatCol(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: _kMutedText, fontSize: 11),
        ),
      ],
    );
  }

  // =====================================================================
  // 4. MANAGE LISTINGS
  // =====================================================================

  Widget _buildManageListingsView() {
    final filtered = _activeListings.where((l) {
      final matchesSearch = l['title'].toString().toLowerCase().contains(_listingSearchQuery.toLowerCase()) ||
          l['city'].toString().toLowerCase().contains(_listingSearchQuery.toLowerCase());
      if (!matchesSearch) return false;
      if (_listingCityFilter != 'All' && l['city'] != _listingCityFilter) return false;
      return true;
    }).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: _kSurface,
          child: Column(
            children: [
              TextField(
                onChanged: (val) => setState(() => _listingSearchQuery = val),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search listings by title or city...',
                  hintStyle: const TextStyle(color: _kMutedText, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: _kGold, size: 20),
                  filled: true,
                  fillColor: _kCardBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kBorder),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Lahore', 'Islamabad', 'Karachi'].map((city) {
                    final selected = _listingCityFilter == city;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(city),
                        selected: selected,
                        onSelected: (_) => setState(() => _listingCityFilter = city),
                        selectedColor: _kGold,
                        backgroundColor: _kCardBg,
                        labelStyle: TextStyle(
                          color: selected ? _kBackground : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyPlaceholder('No listings found', Icons.apartment_outlined)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isFeatured = item['isFeatured'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: _kCardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                child: Image.network(
                                  item['imageUrl'],
                                  height: 140,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 140,
                                    color: _kSurface,
                                    child: const Center(
                                      child: Icon(Icons.apartment, color: _kMutedText, size: 40),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _kBackground.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item['city'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              if (isFeatured)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _kGold,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'FEATURED',
                                      style: TextStyle(
                                        color: _kBackground,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      item['rent'],
                                      style: const TextStyle(
                                        color: _kGoldLight,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Host: ${item['hostName']} • Views: ${item['views']} • Inquiries: ${item['inquiries']}',
                                  style: const TextStyle(color: _kMutedText, fontSize: 12),
                                ),
                                const Divider(color: _kBorder, height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          item['isFeatured'] = !isFeatured;
                                        });
                                        _showSnackBar(
                                          isFeatured
                                              ? 'Listing removed from featured'
                                              : 'Listing marked as Featured!',
                                        );
                                      },
                                      icon: Icon(
                                        isFeatured ? Icons.star : Icons.star_border,
                                        color: _kGold,
                                        size: 16,
                                      ),
                                      label: Text(
                                        isFeatured ? 'Featured' : 'Make Featured',
                                        style: const TextStyle(color: _kGold, fontSize: 12),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: 'Delete Listing',
                                          icon: const Icon(Icons.delete_outline, color: _kDanger, size: 20),
                                          onPressed: () {
                                            _confirmDeleteListing(item['id'], item['title']);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _confirmDeleteListing(String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Listing?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to permanently delete "$title"? This action cannot be undone.',
          style: const TextStyle(color: _kMutedText, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _kMutedText)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _activeListings.removeWhere((l) => l['id'] == id);
              });
              _showSnackBar('Listing deleted successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: _kDanger),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // 5. PENDING LISTINGS (APPROVAL QUEUE)
  // =====================================================================

  Widget _buildPendingListingsView() {
    return RefreshIndicator(
      color: _kGold,
      backgroundColor: _kSurface,
      onRefresh: _fetchRealListingsIfAvailable,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Moderation Overview Banner
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kMaroonStart, _kMaroonEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kGold.withValues(alpha: 0.4), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _kGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.security_update_good_rounded,
                      color: _kGold, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Room Moderation Queue',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Admin approval is required for all new user & host rooms. ${_pendingListings.length} pending review.',
                        style:
                            const TextStyle(color: _kGoldLight, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh Queue',
                  onPressed: _fetchRealListingsIfAvailable,
                  icon: const Icon(Icons.refresh, color: _kGold),
                ),
              ],
            ),
          ),
          if (_pendingListings.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: _buildEmptyPlaceholder(
                'All caught up! No pending listings awaiting moderation.',
                Icons.verified_outlined,
              ),
            )
          else
            ..._pendingListings.map((pending) => _buildPendingListingCard(pending)),
        ],
      ),
    );
  }

  Widget _buildPendingListingCard(Map<String, dynamic> pending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kWarning.withOpacity(0.6), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pending Alert Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _kWarning.withOpacity(0.15),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pending_actions,
                        color: _kWarning, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'Awaiting Admin Review',
                      style: TextStyle(
                        color: _kWarning,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  pending['submittedAt'] ?? 'Recently',
                  style: const TextStyle(color: _kMutedText, fontSize: 11),
                ),
              ],
            ),
          ),
          ClipRRect(
            child: Image.network(
              pending['imageUrl'] ?? '',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 150,
                color: _kSurface,
                child: const Center(
                  child: Icon(Icons.home, color: _kMutedText, size: 40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        pending['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      pending['rent'] ?? '',
                      style: const TextStyle(
                        color: _kGoldLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${pending['city']} • ${pending['roomType']} • ${pending['tag']}',
                  style: const TextStyle(color: _kGold, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  pending['description'] ?? '',
                  style: const TextStyle(color: _kMutedText, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: _kGold, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Submitted by: ${pending['hostName']} (${pending['hostPhone']})${pending['hostEmail'] != null && pending['hostEmail'].toString().isNotEmpty ? ' • ${pending['hostEmail']}' : ''}',
                          style:
                              const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: _kBorder, height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rejectPendingDialog(pending),
                        icon:
                            const Icon(Icons.close, color: _kDanger, size: 16),
                        label: const Text(
                          'Reject',
                          style: TextStyle(color: _kDanger, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _kDanger),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approvePendingListing(pending),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text(
                          'Approve & Publish',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kSuccess,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approvePendingListing(Map<String, dynamic> pending) async {
    final id = pending['id']?.toString() ?? '';
    await ListingsService.approveListing(id);

    setState(() {
      _pendingListings.removeWhere((p) => p['id'] == pending['id']);
      _activeListings.insert(0, {
        'id': pending['id'],
        'title': pending['title'],
        'city': pending['city'],
        'rent': pending['rent'],
        'roomType': pending['roomType'],
        'hostName': pending['hostName'],
        'isFeatured': false,
        'status': 'Active',
        'views': 1,
        'inquiries': 0,
        'imageUrl': pending['imageUrl'],
      });
    });
    _showSnackBar('Listing "${pending['title']}" approved and published live!');
  }

  void _rejectPendingDialog(Map<String, dynamic> pending) {
    String reason = 'Misleading pricing or details';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: _kSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Reject Listing', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select rejection reason to notify the host:',
                style: TextStyle(color: _kMutedText, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ...[
                'Misleading pricing or details',
                'Blurry or low-quality photos',
                'Incomplete address or phone number',
                'Violates community safety guidelines',
              ].map((r) => RadioListTile<String>(
                    dense: true,
                    title: Text(r, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    value: r,
                    groupValue: reason,
                    activeColor: _kGold,
                    onChanged: (val) {
                      setDialogState(() => reason = val!);
                    },
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: _kMutedText)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final id = pending['id']?.toString() ?? '';
                await ListingsService.rejectListing(id, reason: reason);
                setState(() {
                  _pendingListings.removeWhere((p) => p['id'] == pending['id']);
                });
                _showSnackBar('Listing rejected. Reason sent to host: $reason', isSuccess: false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: _kDanger),
              child: const Text('Reject Listing', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // 6. REPORTS & MODERATION
  // =====================================================================

  Widget _buildReportsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        final isCritical = report['severity'] == 'Critical';
        final isHigh = report['severity'] == 'High';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCritical
                  ? _kDanger
                  : (isHigh ? _kWarning : _kBorder),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isCritical ? _kDanger : _kWarning).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isCritical ? _kDanger : _kWarning,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '${report['severity']} Severity',
                      style: TextStyle(
                        color: isCritical ? _kDanger : _kWarning,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    report['date'],
                    style: const TextStyle(color: _kMutedText, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                report['type'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Target: ${report['reportedItem']}',
                style: const TextStyle(color: _kGoldLight, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                'Reported by: ${report['reportedBy']}',
                style: const TextStyle(color: _kMutedText, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${report['details']}"',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const Divider(color: _kBorder, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _reports.removeAt(index);
                      });
                      _showSnackBar('Report dismissed as resolved');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _kMutedText),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Dismiss', style: TextStyle(color: _kMutedText, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _reports.removeAt(index);
                      });
                      _showSnackBar('Enforcement action taken against ${report['targetUser']}');
                    },
                    icon: const Icon(Icons.gavel, size: 14),
                    label: const Text('Take Action', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kDanger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // =====================================================================
  // 7. ANALYTICS
  // =====================================================================

  Widget _buildAnalyticsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'PLATFORM GROWTH & DEMOGRAPHICS',
          style: TextStyle(
            color: _kGoldLight,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),

        // Conversion Cards
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsStatCard(
                'Avg. Response Time',
                '14.2 mins',
                '+32% faster',
                Icons.speed,
                _kSuccess,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildAnalyticsStatCard(
                'Match Rate',
                '78.4%',
                'Renters to hosts',
                Icons.handshake_outlined,
                _kGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsStatCard(
                'Avg. Monthly Rent',
                'PKR 24,500',
                'Across Pakistan',
                Icons.payments_outlined,
                _kInfo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildAnalyticsStatCard(
                'Safety Score',
                '96.8%',
                'Verified users',
                Icons.verified_user_outlined,
                _kSuccess,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // City Distribution Progress Bars
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'City Distribution (Active Listings)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 14),
              _buildProgressBar('Lahore', 0.42, '42% (148 units)'),
              _buildProgressBar('Islamabad', 0.31, '31% (112 units)'),
              _buildProgressBar('Karachi', 0.18, '18% (96 units)'),
              _buildProgressBar('Rawalpindi & Others', 0.09, '9% (62 units)'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Room Type Breakdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Room Preference Demand',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 14),
              _buildProgressBar('Single Furnished Room', 0.52, '52% demand'),
              _buildProgressBar('Shared Room / Bedspace', 0.28, '28% demand'),
              _buildProgressBar('Independent Flat / Studio', 0.20, '20% demand'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsStatCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: _kMutedText, fontSize: 11),
          ),
          Text(
            sub,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, String percentageText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                percentageText,
                style: const TextStyle(color: _kGoldLight, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: _kSurface,
              valueColor: const AlwaysStoppedAnimation<Color>(_kGold),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // 8. NOTIFICATIONS & BROADCASTS
  // =====================================================================

  Widget _buildNotificationsView() {
    final titleCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    String targetAudience = 'All Users';

    return StatefulBuilder(
      builder: (context, setNotificationState) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Broadcast Composer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kCardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kGold.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.campaign, color: _kGold, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Compose Push Broadcast',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Target Audience', style: TextStyle(color: _kMutedText, fontSize: 12)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _kBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: targetAudience,
                      isExpanded: true,
                      dropdownColor: _kSurface,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      items: ['All Users', 'Hosts Only', 'Renters Only']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setNotificationState(() => targetAudience = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Notification Title', style: TextStyle(color: _kMutedText, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'e.g. Ramazan Rental Discounts Announced!',
                    hintStyle: const TextStyle(color: _kMutedText, fontSize: 12),
                    filled: true,
                    fillColor: _kSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Message Body', style: TextStyle(color: _kMutedText, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: messageCtrl,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Type your message to be sent to all selected app devices...',
                    hintStyle: const TextStyle(color: _kMutedText, fontSize: 12),
                    filled: true,
                    fillColor: _kSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty) {
                        _showSnackBar('Please enter a notification title', isSuccess: false);
                        return;
                      }
                      setState(() {
                        _broadcasts.insert(0, {
                          'id': 'bc_${DateTime.now().millisecondsSinceEpoch}',
                          'title': titleCtrl.text.trim(),
                          'target': targetAudience,
                          'date': 'Just now',
                          'views': 1,
                        });
                      });
                      titleCtrl.clear();
                      messageCtrl.clear();
                      _showSnackBar('Broadcast queued & sent to $targetAudience!');
                    },
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Send Broadcast to All', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGold,
                      foregroundColor: _kBackground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Broadcast History
          const Text(
            'RECENT BROADCAST HISTORY',
            style: TextStyle(
              color: _kGoldLight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          ..._broadcasts.map((b) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _kCardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined, color: _kGold, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Target: ${b['target']} • Sent: ${b['date']}',
                            style: const TextStyle(color: _kMutedText, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kSuccess.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${b['views']} Delivered',
                        style: const TextStyle(color: _kSuccess, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // =====================================================================
  // 9. AMENITIES MANAGEMENT
  // =====================================================================

  Widget _buildAmenitiesView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LISTING AMENITIES MASTER',
                style: TextStyle(
                  color: _kGoldLight,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addNewAmenityDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Amenity', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kMaroonStart,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _amenitiesList.length,
            itemBuilder: (context, index) {
              final a = _amenitiesList[index];
              final bool isEnabled = a['enabled'] == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _kCardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kBorder),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _kSurface,
                    child: Icon(a['icon'] as IconData, color: _kGold, size: 20),
                  ),
                  title: Text(
                    a['name'],
                    style: TextStyle(
                      color: isEnabled ? Colors.white : _kMutedText,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: isEnabled,
                        activeColor: _kGold,
                        onChanged: (val) {
                          setState(() {
                            a['enabled'] = val;
                          });
                          _showSnackBar(
                            val
                                ? '${a['name']} enabled for listings'
                                : '${a['name']} disabled',
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: _kMutedText, size: 18),
                        onPressed: () {
                          setState(() {
                            _amenitiesList.removeAt(index);
                          });
                          _showSnackBar('${a['name']} removed from master list');
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _addNewAmenityDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Add New Amenity', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g. Solar Backup, Swimming Pool',
            hintStyle: TextStyle(color: _kMutedText),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kGold)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _kMutedText)),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() {
                  _amenitiesList.add({
                    'name': ctrl.text.trim(),
                    'icon': Icons.star_border,
                    'enabled': true,
                  });
                });
                Navigator.pop(ctx);
                _showSnackBar('Amenity "${ctrl.text.trim()}" added!');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _kGold, foregroundColor: _kBackground),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // 10. CITIES COVERAGE
  // =====================================================================

  Widget _buildCitiesView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'COVERED CITIES & REGIONS',
                style: TextStyle(
                  color: _kGoldLight,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addNewCityDialog,
                icon: const Icon(Icons.add_location_alt_outlined, size: 16),
                label: const Text('Add City', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kMaroonStart,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _citiesList.length,
            itemBuilder: (context, index) {
              final c = _citiesList[index];
              final bool isEnabled = c['enabled'] == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _kCardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kBorder),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _kSurface,
                    child: const Icon(Icons.location_city, color: _kGold, size: 20),
                  ),
                  title: Text(
                    c['name'],
                    style: TextStyle(
                      color: isEnabled ? Colors.white : _kMutedText,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '${c['province']} • ${c['listings']} live listings',
                    style: const TextStyle(color: _kMutedText, fontSize: 11),
                  ),
                  trailing: Switch(
                    value: isEnabled,
                    activeColor: _kGold,
                    onChanged: (val) {
                      setState(() {
                        c['enabled'] = val;
                      });
                      _showSnackBar(
                        val
                            ? '${c['name']} active for listings and filters'
                            : '${c['name']} paused',
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _addNewCityDialog() {
    final nameCtrl = TextEditingController();
    final provinceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Add Supported City', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'City Name (e.g. Hyderabad, Quetta)',
                hintStyle: TextStyle(color: _kMutedText),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kGold)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: provinceCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Province (e.g. Sindh, Balochistan)',
                hintStyle: TextStyle(color: _kMutedText),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kGold)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _kMutedText)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _citiesList.add({
                    'name': nameCtrl.text.trim(),
                    'province': provinceCtrl.text.trim().isNotEmpty ? provinceCtrl.text.trim() : 'Pakistan',
                    'listings': 0,
                    'enabled': true,
                  });
                });
                Navigator.pop(ctx);
                _showSnackBar('City "${nameCtrl.text.trim()}" added to platform!');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _kGold, foregroundColor: _kBackground),
            child: const Text('Add City'),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // 11. PLATFORM SETTINGS
  // =====================================================================

  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'PLATFORM POLICIES & SECURITY',
          style: TextStyle(
            color: _kGoldLight,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Require Admin Approval for Listings', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('When enabled, new host listings go to Pending queue before appearing publicly.', style: TextStyle(color: _kMutedText, fontSize: 11)),
                value: _settingRequireApproval,
                activeColor: _kGold,
                onChanged: (val) async {
                  setState(() => _settingRequireApproval = val);
                  await ListingsService.setApprovalRequired(val);
                  _showSnackBar(val
                      ? 'Listing approval policy updated: Admin approval required for all new rooms'
                      : 'Listing approval policy updated: Direct publishing enabled');
                },
              ),
              const Divider(color: _kBorder, height: 1),
              SwitchListTile(
                title: const Text('Enable Direct In-App Chat', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Allow renters and hosts to message each other directly.', style: TextStyle(color: _kMutedText, fontSize: 11)),
                value: _settingEnableChat,
                activeColor: _kGold,
                onChanged: (val) {
                  setState(() => _settingEnableChat = val);
                  _showSnackBar('Chat system updated');
                },
              ),
              const Divider(color: _kBorder, height: 1),
              SwitchListTile(
                title: const Text('Allow Guest Browsing', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Unregistered users can browse listings without logging in.', style: TextStyle(color: _kMutedText, fontSize: 11)),
                value: _settingGuestBrowsing,
                activeColor: _kGold,
                onChanged: (val) {
                  setState(() => _settingGuestBrowsing = val);
                  _showSnackBar('Guest browsing updated');
                },
              ),
              const Divider(color: _kBorder, height: 1),
              SwitchListTile(
                title: const Text('Platform Maintenance Mode', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Lock non-admin app access during system upgrades.', style: TextStyle(color: _kDanger, fontSize: 11)),
                value: _settingMaintenanceMode,
                activeColor: _kDanger,
                onChanged: (val) {
                  setState(() => _settingMaintenanceMode = val);
                  _showSnackBar(
                    val
                        ? 'MAINTENANCE MODE ACTIVATED'
                        : 'Maintenance mode deactivated. App live.',
                    isSuccess: !val,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'PLATFORM LIMITS & BUSINESS',
          style: TextStyle(
            color: _kGoldLight,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Platform Service Commission', style: TextStyle(color: Colors.white, fontSize: 14)),
                  Text('${_settingCommissionRate.toInt()}%', style: const TextStyle(color: _kGoldLight, fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: _settingCommissionRate,
                min: 0,
                max: 20,
                divisions: 20,
                activeColor: _kGold,
                inactiveColor: _kSurface,
                onChanged: (val) {
                  setState(() => _settingCommissionRate = val);
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Default Listing Active Duration', style: TextStyle(color: Colors.white, fontSize: 14)),
                  Text('$_settingListingDurationDays Days', style: const TextStyle(color: _kGoldLight, fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: _settingListingDurationDays.toDouble(),
                min: 30,
                max: 180,
                divisions: 5,
                activeColor: _kGold,
                inactiveColor: _kSurface,
                onChanged: (val) {
                  setState(() => _settingListingDurationDays = val.toInt());
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // System Maintenance Actions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('System Cache & Logs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              const Text('Purge temporary cached images and reset location distance cache.', style: TextStyle(color: _kMutedText, fontSize: 12)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  _showSnackBar('Platform cache cleared successfully');
                },
                icon: const Icon(Icons.cleaning_services, size: 16),
                label: const Text('Clear All Platform Cache'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kMaroonStart,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // =====================================================================
  // 12. ADMIN PROFILE & ROLE SWITCHER
  // =====================================================================

  Widget _buildProfileView() {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'admin@roommatefinder.com';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Admin Badge Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kMaroonStart, _kMaroonEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kGold, width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _kGoldLight, width: 3),
                  color: _kSurface,
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: _kGold,
                  size: 42,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Super Administrator',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(color: _kGoldLight, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kGold.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kGold),
                ),
                child: const Text(
                  'Full Root Privileges',
                  style: TextStyle(
                    color: _kGoldLight,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Test User Experience: Quick Role Switcher
        const Text(
          'EXPERIENCE APP AS USER (PREVIEWS)',
          style: TextStyle(
            color: _kGoldLight,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            children: [
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: _kSurface,
                  child: Icon(Icons.search, color: _kInfo),
                ),
                title: const Text('Open Renter Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Browse rooms, submit requests, and search as a seeker', style: TextStyle(color: _kMutedText, fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios, color: _kMutedText, size: 14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RenterDashboard()),
                  );
                },
              ),
              const Divider(color: _kBorder),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: _kSurface,
                  child: Icon(Icons.home_work, color: _kGold),
                ),
                title: const Text('Open Host Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Post rooms, manage property inquiries and approvals', style: TextStyle(color: _kMutedText, fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios, color: _kMutedText, size: 14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HostDashboard()),
                  );
                },
              ),
              const Divider(color: _kBorder),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: _kSurface,
                  child: Icon(Icons.travel_explore, color: _kSuccess),
                ),
                title: const Text('Browse All Listings as Public', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('View Home feed with filters and GPS map view', style: TextStyle(color: _kMutedText, fontSize: 11)),
                trailing: const Icon(Icons.arrow_forward_ios, color: _kMutedText, size: 14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen(forceBrowse: true)),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Security Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Admin Session & Security', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Text('Security Protocol: AES-256 JWT Authentication', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              Text('Database: Supabase PostgreSQL (Production)', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              Text('Active Session ID: ${DateTime.now().millisecondsSinceEpoch}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  // Common Empty Placeholder
  Widget _buildEmptyPlaceholder(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _kMutedText.withOpacity(0.5), size: 54),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _kMutedText, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
