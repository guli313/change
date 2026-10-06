import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/favorites_service.dart';
import '../../services/listings_service.dart';
import '../../services/location_service.dart';
import '../auth/login_screen.dart';
import '../chat/chat_screen.dart';
import '../listing/post_listing_screen.dart';
import '../profile/my_profile_screen.dart';
import 'favorites_screen.dart';
import 'filter_screen.dart';
import 'listing_detail_screen.dart';
import 'map_screen.dart';
import 'notifications_screen.dart';
import 'requests_screen.dart';
import 'see_all_listings_screen.dart';

const Color _kBackground = Color(0xFF0D0D0D);
const Color _kSurface = Color(0xFF1A1717);
const Color _kCardBg = Color(0xFF1C1919);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMaroon = Color(0xFF7A1F35);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMaroonEnd = Color(0xFF4E1220);
const Color _kMutedText = Color(0xFF9B9B9B);
const Color _kBorder = Color(0xFF2A2626);

const List<Map<String, String>> _kSampleListings = [
  {
    'id': 'sample_1',
    'title': '2 Bed Apartment',
    'city': 'Lahore',
    'country': 'Pakistan',
    'rent': 'PKR 25,000',
    'currency': 'PKR',
    'period': '/month',
    'tag': 'Female Only',
    'description': 'Spacious 2-bedroom apartment in DHA Phase 5, Lahore. Furnished with all basic amenities.',
    'roomType': 'Apartment',
  },
  {
    'id': 'sample_2',
    'title': '1 Room Available',
    'city': 'Lahore',
    'country': 'Pakistan',
    'rent': 'PKR 15,000',
    'currency': 'PKR',
    'period': '/month',
    'tag': '',
    'description': 'A clean single room available in Johar Town. Near market and public transport.',
    'roomType': 'Single Room',
  },
  {
    'id': 'sample_3',
    'title': 'Room near FAST',
    'city': 'Islamabad',
    'country': 'Pakistan',
    'rent': 'PKR 18,000',
    'currency': 'PKR',
    'period': '/month',
    'tag': 'Male Only',
    'description': 'Room available near FAST University campus. Ideal for students.',
    'roomType': 'Single Room',
  },
  {
    'id': 'sample_4',
    'title': 'Shared Room, DHA',
    'city': 'Karachi',
    'country': 'Pakistan',
    'rent': 'PKR 22,000',
    'currency': 'PKR',
    'period': '/month',
    'tag': '',
    'description': 'Shared room in DHA Karachi with modern facilities.',
    'roomType': 'Shared Room',
  },
  {
    'id': 'sample_5',
    'title': 'Furnished Studio',
    'city': 'Lahore',
    'country': 'Pakistan',
    'rent': 'PKR 30,000',
    'currency': 'PKR',
    'period': '/month',
    'tag': 'Female Only',
    'description': 'Fully furnished studio apartment in Gulberg III. All utilities included.',
    'roomType': 'Studio',
  },
  {
    'id': 'sample_6',
    'title': 'Hostel Room',
    'city': 'Islamabad',
    'country': 'Pakistan',
    'rent': 'PKR 12,000',
    'currency': 'PKR',
    'period': '/month',
    'tag': 'Male Only',
    'description': 'Shared hostel room near F-8 Markaz. WiFi and meals included.',
    'roomType': 'Hostel',
  },
  {
    'id': 'sample_7',
    'title': 'Room near UET',
    'city': 'Sheikhupura',
    'country': 'Pakistan',
    'rent': 'PKR 11,000',
    'currency': 'PKR',
    'period': '/month',
    'tag': 'Male Only',
    'description': 'Affordable room for students. Near Sheikhupura main highway to Lahore.',
    'roomType': 'Single Room',
  },
  {
    'id': 'sample_8',
    'title': 'Furnished Room',
    'city': 'Gujranwala',
    'country': 'Pakistan',
    'rent': 'PKR 16,000',
    'currency': 'PKR',
    'period': '/month',
    'tag': 'Female Only',
    'description': 'Furnished room in Gujranwala Satellite Town. Safe family area.',
    'roomType': 'Single Room',
  },
  {
    'id': 'sample_9',
    'title': 'Shared Flat',
    'city': 'Kasur',
    'country': 'Pakistan',
    'rent': 'PKR 9,500',
    'currency': 'PKR',
    'period': '/month',
    'tag': '',
    'description': 'Shared flat on Kasur-Lahore road. Easy commute to Lahore.',
    'roomType': 'Shared Room',
  },
  {
    'id': 'sample_10',
    'title': 'Studio near Airport',
    'city': 'Sialkot',
    'country': 'Pakistan',
    'rent': 'PKR 19,000',
    'currency': 'PKR',
    'period': '/month',
    'tag': '',
    'description': 'Cozy studio near Sialkot International Airport.',
    'roomType': 'Studio',
  },
  {
    'id': 'sample_11',
    'title': 'Central London Flat',
    'city': 'London',
    'country': 'United Kingdom',
    'rent': '£1,400',
    'currency': 'GBP',
    'period': '/month',
    'tag': 'Female Only',
    'description': 'Modern 2-bed flat in Zone 2 Central London. 10 min walk to tube station.',
    'roomType': 'Apartment',
  },
  {
    'id': 'sample_12',
    'title': 'Brooklyn Shared Room',
    'city': 'New York',
    'country': 'United States',
    'rent': '\$950',
    'currency': 'USD',
    'period': '/month',
    'tag': '',
    'description': 'Shared room in Brooklyn. 15 min subway to Manhattan. Utilities included.',
    'roomType': 'Shared Room',
  },
];

enum SortOption { newest, priceLow, priceHigh, distance }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  FilterCriteria _activeFilter = const FilterCriteria();
  SortOption _sortOption = SortOption.newest;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String _userName = 'Guest';
  List<Listing> _listings = [];
  bool _isLoading = true;
  int _unreadChatCount = 2;

  UserLocation? _userLocation;
  bool _isLoadingLocation = false;
  bool _locationDenied = false;
  bool _sortByDistance = false;
  List<Listing> _nearbyListings = [];
  bool _isLoadingNearby = false;
  int _radiusKm = 25;

  static const List<int> _kRadiusOptions = [5, 10, 25, 50, 100, 0];

  final List<String> _filters = const [
    'All',
    'Female',
    'Male',
  ];

  List<String> get _activeFilterTags {
    final tags = <String>[];
    if (_selectedFilter != 'All') tags.add(_selectedFilter);
    if (_activeFilter.location.isNotEmpty) tags.add('📍 ${_activeFilter.location}');
    if (_activeFilter.budget.isNotEmpty) tags.add('💰 ≤ ${_activeFilter.budget}');
    if (_activeFilter.religion.isNotEmpty) tags.add('✨ ${_activeFilter.religion}');
    if (_activeFilter.radiusKm > 0) tags.add('📏 ${_activeFilter.radiusKm.toInt()} km');
    return tags;
  }

  @override
  void initState() {
    super.initState();
    FavoritesService.init();
    _loadUserName();
    _loadListings();
    _loadLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadUserName() {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final metadata = user.userMetadata ?? {};
        final name = metadata['name']?.toString() ??
            metadata['full_name']?.toString() ??
            (user.email != null ? user.email!.split('@')[0] : 'User');
        setState(() => _userName = name);
      }
    } catch (e) {
      debugPrint('Error loading user name: $e');
    }
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    try {
      final listings = await ListingsService.fetchRecent(limit: 30);
      if (mounted) {
        setState(() {
          _listings = listings.isEmpty ? _buildSampleListings() : listings;
          _isLoading = false;
        });
        if (_userLocation != null) {
          _computeDistances();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _listings = _buildSampleListings();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadLocation() async {
    setState(() => _isLoadingLocation = true);
    final loc = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _userLocation = loc;
        _isLoadingLocation = false;
        _locationDenied = loc == null;
      });
      if (loc != null && !_isLoading) {
        _computeDistances();
      }
    }
  }

  Future<void> _computeDistances() async {
    if (_userLocation == null || _listings.isEmpty) return;
    setState(() => _isLoadingNearby = true);

    final userLat = _userLocation!.latitude;
    final userLng = _userLocation!.longitude;

    final List<Listing> withDist = [];
    for (final listing in _listings) {
      if (listing.city.isEmpty) {
        withDist.add(listing);
        continue;
      }
      try {
        final geo = await LocationService.getCoordinatesForCity(listing.city);
        if (geo != null) {
          final km = LocationService.distanceKm(
            userLat, userLng, geo.latitude, geo.longitude,
          );
          withDist.add(listing.withDistance(km));
        } else {
          withDist.add(listing);
        }
      } catch (_) {
        withDist.add(listing);
      }
    }

    final withinRadius = withDist
        .where((l) => l.distanceKm != null && l.distanceKm! <= _radiusKm)
        .toList()
      ..sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));

    final allSorted = withDist
      ..sort((a, b) {
        final da = a.distanceKm;
        final db = b.distanceKm;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });

    if (mounted) {
      setState(() {
        _listings = allSorted;
        _nearbyListings = withinRadius;
        _isLoadingNearby = false;
      });
    }
  }

  List<Listing> _buildSampleListings() {
    return _kSampleListings.map((m) {
      final rawRent = m['rent']?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0';
      final rentNum = int.tryParse(rawRent) ?? 0;
      final isFeatured = m['id'] == 'sample_1' || m['id'] == 'sample_5';
      final hoursAgo = _kSampleListings.indexOf(m) * 6;
      return Listing.fromMap({
        'id': m['id'],
        'title': m['title'],
        'city': m['city'],
        'country': m['country'],
        'rent': rentNum,
        'currency': m['currency'] ?? 'USD',
        'period': m['period'],
        'tag': m['tag'],
        'description': m['description'],
        'created_at': DateTime.now().subtract(Duration(hours: hoursAgo)).toIso8601String(),
        'is_featured': isFeatured,
      });
    }).toList();
  }

  List<Listing> get _filteredListings {
    var result = List<Listing>.from(_listings);

    if (_searchQuery.isNotEmpty) {
      result = result.where((l) {
        final q = _searchQuery.toLowerCase();
        return l.title.toLowerCase().contains(q) ||
            l.city.toLowerCase().contains(q) ||
            (l.country ?? '').toLowerCase().contains(q) ||
            (l.description ?? '').toLowerCase().contains(q) ||
            l.tag.toLowerCase().contains(q);
      }).toList();
    }

    if (_selectedFilter == 'Female') {
      result = result.where((l) => l.tag.toLowerCase().contains('female')).toList();
    } else if (_selectedFilter == 'Male') {
      result = result.where((l) => l.tag.toLowerCase().contains('male')).toList();
    }

    if (_activeFilter.location.isNotEmpty) {
      final loc = _activeFilter.location.toLowerCase();
      result = result.where((l) => l.city.toLowerCase().contains(loc)).toList();
    }

    if (_activeFilter.budget.isNotEmpty) {
      final budget = int.tryParse(_activeFilter.budget.replaceAll(RegExp(r'[^0-9]'), ''));
      if (budget != null) {
        result = result.where((l) => l.rent <= budget).toList();
      }
    }

    if (_activeFilter.religion.isNotEmpty) {
      final rel = _activeFilter.religion.toLowerCase();
      result = result.where((l) =>
        (l.description ?? '').toLowerCase().contains(rel) ||
        l.tag.toLowerCase().contains(rel)).toList();
    }

    if (_activeFilter.radiusKm > 0) {
      result = result.where((l) {
        if (l.distanceKm == null) return false;
        return l.distanceKm! <= _activeFilter.radiusKm;
      }).toList();
    } else if (_userLocation != null && _sortByDistance) {
      if (_radiusKm > 0) {
        result = result.where((l) {
          if (l.distanceKm == null) return false;
          return l.distanceKm! <= _radiusKm;
        }).toList();
      }
    }

    switch (_sortOption) {
      case SortOption.newest:
        result.sort((a, b) {
          final da = a.createdAt ?? DateTime(2000);
          final db = b.createdAt ?? DateTime(2000);
          return db.compareTo(da);
        });
        break;
      case SortOption.priceLow:
        result.sort((a, b) => a.rent.compareTo(b.rent));
        break;
      case SortOption.priceHigh:
        result.sort((a, b) => b.rent.compareTo(a.rent));
        break;
      case SortOption.distance:
        result.sort((a, b) {
          final da = a.distanceKm ?? 999999;
          final db = b.distanceKm ?? 999999;
          return da.compareTo(db);
        });
        break;
    }

    return result;
  }

  List<Listing> get _featuredListings {
    return _listings.where((l) => l.isFeatured).toList();
  }

  String get _sortLabel {
    switch (_sortOption) {
      case SortOption.newest:
        return 'Newest';
      case SortOption.priceLow:
        return 'Price: Low → High';
      case SortOption.priceHigh:
        return 'Price: High → Low';
      case SortOption.distance:
        return 'Nearest First';
    }
  }

  void _onItemTapped(int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RequestsScreen()),
        );
        break;
      case 2:
        setState(() => _unreadChatCount = 0);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
        break;
    }
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredListings;
    return Scaffold(
      backgroundColor: _kBackground,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          color: _kGold,
          backgroundColor: _kSurface,
          onRefresh: () async {
            LocationService.clearCache();
            _loadUserName();
            await Future.wait([
              _loadListings(),
              _loadLocation(),
            ]);
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: _buildHeroCTA()),
              SliverToBoxAdapter(child: _buildQuickActions()),
              SliverToBoxAdapter(child: _buildLocationBanner()),
              if (_userLocation != null)
                SliverToBoxAdapter(child: _buildRadiusChips()),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildFilterChips()),
              if (_activeFilterTags.isNotEmpty)
                SliverToBoxAdapter(child: _buildActiveFilterTags()),
              if (_featuredListings.isNotEmpty)
                SliverToBoxAdapter(child: _buildFeaturedSection()),
              if (_nearbyListings.isNotEmpty)
                SliverToBoxAdapter(child: _buildNearMeSection()),
              SliverToBoxAdapter(child: _buildAllListingsHeader(filtered.length)),
              if (_isLoading)
                SliverToBoxAdapter(child: _buildLoadingGrid())
              else if (filtered.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                _buildListingsGrid(filtered),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [_kMaroonStart, _kMaroonEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PostListingScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: _kBorder),
                ),
                child: const Icon(Icons.menu, color: _kGold, size: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $_userName 👋',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Find your roommate today',
                style: TextStyle(fontSize: 12, color: _kMutedText),
              ),
            ],
          ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kSurface,
                shape: BoxShape.circle,
                border: Border.all(color: _kBorder),
              ),
              child: const Icon(
                Icons.notifications_none,
                color: _kGold,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyProfileScreen(),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_kGold, _kGoldLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: _kGold.withValues(alpha: 0.4), width: 2),
              ),
              child: Center(
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _kBackground,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCTA() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [_kMaroonStart, _kMaroonEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: _kGold.withValues(alpha: 0.3), width: 1),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.home_work_outlined, color: _kGoldLight, size: 22),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Welcome to Roommate Finder',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose what you want to do today:',
              style: TextStyle(color: Colors.white70, fontSize: 12.5),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _onFindRoomTapped,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _kGold,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.radar, color: _kMaroon, size: 22),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isLoadingLocation)
                                const Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: SizedBox(
                                    width: 11,
                                    height: 11,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: _kMaroon,
                                    ),
                                  ),
                                )
                              else if (_userLocation == null)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(Icons.location_searching,
                                      color: _kMaroon, size: 12),
                                ),
                              const Text(
                                'Find a Room',
                                style: TextStyle(
                                  color: _kMaroon,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _userLocation != null
                                ? 'Near ${_userLocation!.cityName ?? 'You'} (${_radiusKm > 0 ? '$_radiusKm km' : 'All'})'
                                : 'Near Your Diameter',
                            style: TextStyle(
                              color: _kMaroon.withValues(alpha: 0.75),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PostListingScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _kGold, width: 1.5),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.add_home_work_outlined,
                              color: _kGold, size: 22),
                          SizedBox(height: 4),
                          Text(
                            'Post a Room',
                            style: TextStyle(
                              color: _kGold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostListingScreen(),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF1C0A12), Color(0xFF2E0F1C)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: Border.all(
              color: _kGold.withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _kMaroonStart.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kGold.withValues(alpha: 0.35)),
                ),
                child: const Icon(
                  Icons.add_home_work_outlined,
                  color: _kGoldLight,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'List Your Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Post your room free & find a roommate',
                      style: TextStyle(
                        color: _kMutedText,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kGold, _kGoldLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Post Now',
                      style: TextStyle(
                        color: _kMaroonEnd,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: _kMaroonEnd,
                      size: 13,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, color: _kMutedText, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search city, area or keyword...',
                  hintStyle: TextStyle(color: _kMutedText, fontSize: 13.5),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.trim().toLowerCase());
                },
                onSubmitted: (_) => _searchFocusNode.unfocus(),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, color: _kGold, size: 20),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              ),
            IconButton(
              icon: const Icon(Icons.favorite_border, color: _kGold, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.tune, color: _kGold, size: 20),
              onPressed: () async {
                final result = await Navigator.push<FilterCriteria>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FilterScreen(),
                  ),
                );
                if (result != null) {
                  setState(() => _activeFilter = result);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? _kBackground : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12.5,
                ),
              ),
              selected: isSelected,
              selectedColor: _kGold,
              backgroundColor: _kSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: isSelected ? _kGold : _kBorder),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = filter);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveFilterTags() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ..._activeFilterTags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kGold.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: const TextStyle(
                        color: _kGold,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _activeFilter = const FilterCriteria();
                _selectedFilter = 'All';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close, size: 12, color: Colors.redAccent),
                  SizedBox(width: 4),
                  Text(
                    'Clear all',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBanner() {
    if (_isLoadingLocation) {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: _kGold),
            ),
            SizedBox(width: 10),
            Text(
              'Detecting location...',
              style: TextStyle(color: _kMutedText, fontSize: 12.5),
            ),
          ],
        ),
      );
    }

    if (_locationDenied || _userLocation == null) {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kGold.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _kMaroon.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off_outlined,
                  color: _kGold, size: 16),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Turn on Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'To find rooms near you',
                    style: TextStyle(color: _kMutedText, fontSize: 11),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                LocationService.clearCache();
                _loadLocation();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _kGold,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _kGold.withValues(alpha: 0.25),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Text(
                  'Allow',
                  style: TextStyle(
                    color: _kMaroon,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final city = _userLocation!.cityName ?? 'Your Location';
    final country = _userLocation!.countryName;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_kGold.withValues(alpha: 0.12), _kSurface],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _kGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.my_location, color: _kGold, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📍 $city${country != null ? ', $country' : ''}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _sortByDistance
                      ? 'Showing rooms within $_radiusKm km'
                      : 'Showing all listings',
                  style: TextStyle(color: _kMutedText, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MiniActionBtn(
                icon: Icons.map_outlined,
                label: 'Map',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MapScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              _MiniActionBtn(
                icon: Icons.near_me,
                label: 'Nearby',
                active: _sortByDistance,
                onTap: () {
                  setState(() {
                    _sortByDistance = !_sortByDistance;
                    _sortOption = _sortByDistance
                        ? SortOption.distance
                        : SortOption.newest;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusChips() {
    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _kRadiusOptions.length,
        itemBuilder: (context, index) {
          final km = _kRadiusOptions[index];
          final selected = _radiusKm == km;
          final count = _listings.where((l) {
            if (l.distanceKm == null) return false;
            if (km == 0) return true;
            return l.distanceKm! <= km;
          }).length;
          final label = km == 0 ? 'All' : '$km km';
          return GestureDetector(
            onTap: () {
              setState(() {
                _radiusKm = km;
                _sortByDistance = true;
                _sortOption = SortOption.distance;
              });
              _computeDistances();
            },
            child: Container(
              margin: EdgeInsets.only(
                  right: index < _kRadiusOptions.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _kGold : _kSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? _kGoldLight : _kBorder,
                  width: selected ? 1.2 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _kGold.withValues(alpha: 0.25),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.track_changes,
                    size: 14,
                    color: selected ? _kMaroon : _kGold,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? _kMaroon : Colors.white,
                      fontSize: 12.5,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: selected
                          ? _kMaroon.withValues(alpha: 0.15)
                          : _kGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: selected ? _kMaroon : _kGold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSection() {
    final featured = _featuredListings;
    if (featured.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kGold, _kGoldLight],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.auto_awesome, color: _kGold, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Featured',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _kGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'TOP',
                  style: TextStyle(
                    color: _kMaroon,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SeeAllListingsScreen(
                        title: 'Featured Listings',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'See all →',
                  style: TextStyle(
                    color: _kGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            itemCount: featured.length,
            itemBuilder: (context, index) {
              final listing = featured[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListingDetailScreen(
                      listingData: listing.toDisplayMap(),
                      listingId: listing.id,
                    ),
                  ),
                ),
                child: Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                    colors: [
                      _kCardBg,
                      _kMaroonEnd.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: _kGold.withValues(alpha: 0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: _kGold.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _kGold.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.workspace_premium,
                                color: _kGold, size: 14),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              listing.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 12, color: _kGold),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              listing.city,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: _kMutedText, fontSize: 11.5),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (listing.tag.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _kMaroon.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            listing.tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listing.rentDisplay,
                                style: const TextStyle(
                                  color: _kGoldLight,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                listing.period,
                                style: const TextStyle(
                                  color: _kMutedText,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _kGold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'View',
                              style: TextStyle(
                                color: _kMaroon,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildNearMeSection() {
    final count = _nearbyListings.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kGold, _kGoldLight],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Rooms Near You',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kGold.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _userLocation != null
                      ? 'Within $_radiusKm km · $count'
                      : '$count',
                  style: const TextStyle(
                    color: _kGold,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (_isLoadingNearby)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                      strokeWidth: 1.5, color: _kGold),
                ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MapScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View Map →',
                  style: TextStyle(
                    color: _kGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            itemCount: _nearbyListings.length,
            itemBuilder: (context, index) {
              final listing = _nearbyListings[index];
              final km = listing.distanceKm;
              final dist =
                  km != null ? LocationService.formatDistance(km) : '';
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListingDetailScreen(
                      listingData: listing.toDisplayMap(),
                      listingId: listing.id,
                    ),
                  ),
                ),
                child: Container(
                  width: 190,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: _kCardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _kGold.withValues(alpha: 0.2)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.home_outlined,
                              color: _kGold, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              listing.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 11, color: _kGold),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              listing.city,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: _kMutedText, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            listing.rentDisplay,
                            style: const TextStyle(
                              color: _kGoldLight,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (dist.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _kGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                dist,
                                style: const TextStyle(
                                  color: _kGold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
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

  Widget _buildAllListingsHeader(int count) {
    final title = _sortByDistance
        ? (_radiusKm > 0 ? 'Rooms Near You ($_radiusKm km)' : 'Nearest Rooms First')
        : 'All Listings';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kGold, _kGoldLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: _kGold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_sortByDistance) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showDiameterSelectorBottomSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kGold.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.track_changes, color: _kGold, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      _radiusKm > 0 ? '$_radiusKm km' : 'All',
                      style: const TextStyle(
                        color: _kGold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: () => _showSortBottomSheet(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_vert, color: _kGold, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    _sortLabel,
                    style: const TextStyle(
                      color: _kGold,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SeeAllListingsScreen(),
                ),
              );
            },
            child: const Text(
              'Grid →',
              style: TextStyle(
                color: _kGold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onFindRoomTapped() async {
    if (_userLocation == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _kGold),
                ),
                SizedBox(width: 10),
                Text('Detecting your location...'),
              ],
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }
      await _loadLocation();
    }

    if (!mounted) return;

    if (_userLocation == null) {
      _showCityAndDiameterSelectorSheet();
      return;
    }

    await _computeDistances();
    if (!mounted) return;

    _showDiameterSelectorBottomSheet();
  }

  void _scrollToResults() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        380,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showDiameterSelectorBottomSheet() {
    int selectedKm = _radiusKm;
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final locCity = _userLocation?.cityName ?? 'Your Location';
            final locCountry = _userLocation?.countryName ?? '';
            final count = _listings.where((l) {
              if (l.distanceKm == null) return false;
              if (selectedKm == 0) return true;
              return l.distanceKm! <= selectedKm;
            }).length;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _kBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _kGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.radar, color: _kGold, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find Rooms Near You',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Filter rooms by distance diameter (radius)',
                              style: TextStyle(color: _kMutedText, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: _kMutedText, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _kCardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kGold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: _kGold, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Location',
                                style: TextStyle(color: _kMutedText, fontSize: 10),
                              ),
                              Text(
                                '$locCity${locCountry.isNotEmpty ? ', $locCountry' : ''}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showCityAndDiameterSelectorSheet();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: _kGold,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Change City', style: TextStyle(fontSize: 11.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Search Diameter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count rooms found',
                          style: const TextStyle(
                            color: _kGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final km in [5, 10, 25, 50, 100, 0]) ...[
                        Builder(builder: (c) {
                          final isSelected = selectedKm == km;
                          final chipCount = _listings.where((l) {
                            if (l.distanceKm == null) return false;
                            if (km == 0) return true;
                            return l.distanceKm! <= km;
                          }).length;
                          final label = km == 0 ? 'All' : '$km km';

                          return GestureDetector(
                            onTap: () {
                              setSheetState(() => selectedKm = km);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: isSelected ? _kGold : _kSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? _kGoldLight : _kBorder,
                                  width: isSelected ? 1.4 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: _kGold.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.track_changes,
                                    size: 13,
                                    color: isSelected ? _kBackground : _kGold,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      color: isSelected ? _kBackground : Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _kBackground.withValues(alpha: 0.2)
                                          : _kGold.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$chipCount',
                                      style: TextStyle(
                                        color: isSelected ? _kBackground : _kGold,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: count > 0
                          ? _kGold.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: count > 0
                            ? _kGold.withValues(alpha: 0.25)
                            : Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          count > 0 ? Icons.check_circle_outline : Icons.info_outline,
                          color: count > 0 ? _kGold : Colors.orangeAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            count > 0
                                ? 'Showing $count rooms within ${selectedKm == 0 ? 'all distances' : '$selectedKm km'}'
                                : 'No rooms within $selectedKm km. Try expanding to 50 km or 100 km.',
                            style: TextStyle(
                              color: count > 0 ? _kGoldLight : Colors.orangeAccent,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (c) => const MapScreen()),
                            );
                          },
                          icon: const Icon(Icons.map_outlined, size: 16),
                          label: const Text('View on Map'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _kGold,
                            side: const BorderSide(color: _kGold),
                            padding: const EdgeInsets.symmetric(vertical: 13),
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
                            Navigator.pop(ctx);
                            setState(() {
                              _radiusKm = selectedKm;
                              _sortByDistance = true;
                              _sortOption = SortOption.distance;
                            });
                            _scrollToResults();
                          },
                          icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                          label: Text(
                            count > 0 ? 'Show $count Rooms' : 'Show Results',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kGold,
                            foregroundColor: _kBackground,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCityAndDiameterSelectorSheet() {
    String selectedCity = _userLocation?.cityName ?? 'Lahore';
    int selectedRadius = _radiusKm;

    const topCities = [
      'Lahore',
      'Karachi',
      'Islamabad',
      'Rawalpindi',
      'Faisalabad',
      'Multan',
      'Peshawar',
      'Sialkot',
      'Gujranwala',
      'London',
      'New York',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _kBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.location_city, color: _kGold, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Select Your City & Diameter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pick your city to see rooms within your preferred diameter:',
                    style: TextStyle(color: _kMutedText, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Popular Cities:',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final c in topCities) ...[
                        ChoiceChip(
                          label: Text(c),
                          selected: selectedCity.toLowerCase() == c.toLowerCase(),
                          selectedColor: _kGold,
                          backgroundColor: _kCardBg,
                          labelStyle: TextStyle(
                            color: selectedCity.toLowerCase() == c.toLowerCase()
                                ? _kBackground
                                : Colors.white70,
                            fontWeight: selectedCity.toLowerCase() == c.toLowerCase()
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setSheetState(() => selectedCity = c);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Search Diameter (Radius):',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final km in [5, 10, 25, 50, 100, 0]) ...[
                        ChoiceChip(
                          label: Text(km == 0 ? 'All' : '$km km'),
                          selected: selectedRadius == km,
                          selectedColor: _kGold,
                          backgroundColor: _kCardBg,
                          labelStyle: TextStyle(
                            color: selectedRadius == km ? _kBackground : Colors.white70,
                            fontWeight: selectedRadius == km ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setSheetState(() => selectedRadius = km);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final loc = LocationService.setManualLocation(selectedCity);
                        setState(() {
                          _userLocation = loc;
                          _locationDenied = false;
                          _radiusKm = selectedRadius;
                          _sortByDistance = true;
                          _sortOption = SortOption.distance;
                        });
                        await _computeDistances();
                        _scrollToResults();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGold,
                        foregroundColor: _kBackground,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Show Rooms Near $selectedCity',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Sort By',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ...SortOption.values.map((opt) {
              String label;
              IconData icon;
              switch (opt) {
                case SortOption.newest:
                  label = 'Newest First';
                  icon = Icons.schedule;
                  break;
                case SortOption.priceLow:
                  label = 'Price: Low to High';
                  icon = Icons.trending_up;
                  break;
                case SortOption.priceHigh:
                  label = 'Price: High to Low';
                  icon = Icons.trending_down;
                  break;
                case SortOption.distance:
                  label = 'Nearest First';
                  icon = Icons.near_me;
                  break;
              }
              final selected = _sortOption == opt;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _sortOption = opt);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? _kGold.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? _kGold : _kBorder,
                        width: selected ? 1.2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: selected ? _kGold : _kMutedText,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              color:
                                  selected ? _kGoldLight : Colors.white70,
                              fontSize: 13.5,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle,
                              color: _kGold, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _kGold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDistanceFiltered = _sortByDistance && _userLocation != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kGold.withValues(alpha: 0.12),
              ),
              child: Icon(
                isDistanceFiltered ? Icons.radar_outlined : Icons.search_off_rounded,
                color: _kGold,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isDistanceFiltered
                  ? 'No rooms within ${_radiusKm > 0 ? '$_radiusKm km' : 'this area'}'
                  : 'No listings found',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isDistanceFiltered
                  ? 'Try expanding search diameter or selecting another city near ${_userLocation?.cityName ?? 'you'}.'
                  : 'Try adjusting your search or filters',
              style: const TextStyle(color: _kMutedText, fontSize: 12.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isDistanceFiltered) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _radiusKm = 50;
                      });
                      _computeDistances();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kGold,
                      side: const BorderSide(color: _kGold),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Try 50 km'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _radiusKm = 100;
                      });
                      _computeDistances();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kGold,
                      side: const BorderSide(color: _kGold),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Try 100 km'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _radiusKm = 0; // Show all distances
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGold,
                      foregroundColor: _kBackground,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Show All Distances'),
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                        _activeFilter = const FilterCriteria();
                        _selectedFilter = 'All';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kMaroon,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Clear Filters'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PostListingScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kGold,
                      side: const BorderSide(color: _kGold),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Post Room'),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
  }

  SliverList _buildListingsGrid(List<Listing> listings) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: _ListingRow(listings: listings),
            );
          }
          return const SizedBox.shrink();
        },
        childCount: 1,
      ),
    );
  }

  // ---- DRAWER ----
  Widget _buildDrawer() {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? {};
    final name = metadata['name']?.toString() ??
        metadata['full_name']?.toString() ??
        _userName;
    final email = user?.email ?? '';

    return Drawer(
      backgroundColor: _kSurface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kMaroonStart, _kMaroonEnd],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: _kGold,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _kBackground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildDrawerItem(
                      Icons.home_outlined,
                      'Home',
                      () => Navigator.pop(context),
                    ),
                    _buildDrawerItem(
                      Icons.person_outline,
                      'My Profile',
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      Icons.favorite_border,
                      'Favorites',
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoritesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      Icons.add_home_work_outlined,
                      'Post a Listing',
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PostListingScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      Icons.description_outlined,
                      'My Requests',
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RequestsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      Icons.chat_bubble_outline,
                      'Chats',
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(color: _kBorder, indent: 20, endIndent: 20),
                    _buildDrawerItem(
                      Icons.help_outline,
                      'Help & Support',
                      () {
                        Navigator.pop(context);
                        _showHelpDialog();
                      },
                    ),
                    _buildDrawerItem(
                      Icons.info_outline,
                      'About',
                      () {
                        Navigator.pop(context);
                        _showAboutDialog();
                      },
                    ),
                    _buildDrawerItem(
                      Icons.description_outlined,
                      'Terms & Conditions',
                      () {
                        Navigator.pop(context);
                        _showTermsDialog();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: _kBorder, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await Supabase.instance.client.auth.signOut();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
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
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Roommate Finder v1.0.0',
                style: TextStyle(color: _kMutedText, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: _kGold, size: 22),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kSurface,
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'For any issues or questions:\n\nEmail: support@roommatefinder.com\nPhone: +92 300 1234567\n\nWe typically respond within 24 hours.',
          style: TextStyle(color: _kMutedText, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: _kGold)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kSurface,
        title: const Text(
          'About',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Roommate Finder helps you find the perfect roommate in Pakistan.\n\n'
          'Browse listings, connect with potential roommates, and find your ideal living arrangement.\n\n'
          'Version 1.0.0',
          style: TextStyle(color: _kMutedText, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: _kGold)),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _kSurface,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'By using Roommate Finder, you agree to:\n\n'
            '1. Provide accurate information in your listings and profile.\n'
            '2. Treat all users with respect and courtesy.\n'
            '3. Not share personal contact information without consent.\n'
            '4. Report any suspicious or harmful behavior.\n'
            '5. Roommate Finder is not responsible for any agreements made between users.\n\n'
            'Your data is stored securely and is only used to provide the service.',
            style: TextStyle(color: _kMutedText, height: 1.5, fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: _kGold)),
          ),
        ],
      ),
    );
  }

  // ---- BOTTOM NAV ----
  Widget _buildBottomNav() {
    return BottomAppBar(
      color: _kSurface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavIcon(
                      icon: Icons.home,
                      label: 'Home',
                      isActive: currentIndex == 0,
                      onTap: () => _onItemTapped(0),
                    ),
                    _NavIcon(
                      icon: Icons.description_outlined,
                      label: 'Requests',
                      isActive: currentIndex == 1,
                      onTap: () => _onItemTapped(1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 56),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavIcon(
                      icon: Icons.chat_bubble_outline,
                      label: 'Chat',
                      isActive: currentIndex == 2,
                      onTap: () => _onItemTapped(2),
                      badgeCount: _unreadChatCount,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListingRow extends StatelessWidget {
  final List<Listing> listings;
  const _ListingRow({required this.listings});

  @override
  Widget build(BuildContext context) {
    final rows = (listings.length / 2).ceil();
    return Column(
      children: List.generate(rows, (rowIdx) {
        final start = rowIdx * 2;
        final end = (start + 2).clamp(0, listings.length);
        final pair = listings.sublist(start, end);
        return Padding(
          padding: EdgeInsets.only(bottom: rowIdx == rows - 1 ? 0 : 12),
          child: Row(
            children: [
              Expanded(child: ListingCard(
                data: pair[0].toDisplayMap(),
                listingId: pair[0].id,
              )),
              if (pair.length == 2) ...[
                const SizedBox(width: 12),
                Expanded(child: ListingCard(
                  data: pair[1].toDisplayMap(),
                  listingId: pair[1].id,
                )),
              ] else
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
        );
      }),
    );
  }
}

class _MiniActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _MiniActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _kGold : _kGold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: active ? _kBackground : _kGold, size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? _kBackground : _kGold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- NAV ICON ----
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _kGold : _kMutedText;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 22),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ---- LISTING CARD ----
class ListingCard extends StatefulWidget {
  final Map<String, String> data;
  final String? listingId;

  const ListingCard({super.key, required this.data, this.listingId});

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  void _loadFavorite() {
    final id = widget.listingId ?? widget.data['id'] ?? '';
    if (id.isNotEmpty) {
      setState(() => _isFavorite = FavoritesService.isFavorite(id));
    }
  }

  Future<void> _toggleFavorite() async {
    final id = widget.listingId ?? widget.data['id'] ?? '';
    if (id.isEmpty) return;
    await FavoritesService.toggleFavorite(id);
    setState(() => _isFavorite = FavoritesService.isFavorite(id));
  }

  @override
  Widget build(BuildContext context) {
    final tag = widget.data['tag'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailScreen(
              listingData: widget.data,
              listingId: widget.listingId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.2,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2A2424), Color(0xFF1A1616)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chair_alt_outlined,
                        color: _kMutedText,
                        size: 34,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.black45,
                        child: Icon(
                          _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 15,
                          color: _isFavorite ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (tag.isNotEmpty)
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: _kMaroon,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: _kGold,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          () {
                            final city = widget.data['city'] ?? '';
                            final distStr = widget.data['distanceKm'] ?? '';
                            if (distStr.isNotEmpty) {
                              final km = double.tryParse(distStr);
                              if (km != null) {
                                return '$city • ${LocationService.formatDistance(km)}';
                              }
                            }
                            return city;
                          }(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _kMutedText,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.data['rent'] ?? '',
                        style: const TextStyle(
                          color: _kGoldLight,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        widget.data['period'] ?? '',
                        style: const TextStyle(
                          color: _kMutedText,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
