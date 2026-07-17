import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/favorites_service.dart';
import '../../services/listings_service.dart';
import '../auth/login_screen.dart';
import '../chat/chat_screen.dart';
import '../listing/post_listing_screen.dart';
import '../profile/my_profile_screen.dart';
import 'favorites_screen.dart';
import 'filter_screen.dart';
import 'listing_detail_screen.dart';
import 'notifications_screen.dart';
import 'requests_screen.dart';
import 'see_all_listings_screen.dart';

// ---- Theme colors ----
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

// ---- Sample data fallback ----
const List<Map<String, String>> _kSampleListings = [
  {
    'id': 'sample_1',
    'title': '2 Bed Apartment',
    'city': 'DHA Phase 5, Lahore',
    'rent': 'PKR 25,000',
    'period': '/month',
    'tag': 'Female Only',
    'description': 'Spacious 2-bedroom apartment in DHA Phase 5, Lahore. Furnished with all basic amenities.',
  },
  {
    'id': 'sample_2',
    'title': '1 Room Available',
    'city': 'Johar Town, Lahore',
    'rent': 'PKR 15,000',
    'period': '/month',
    'tag': '',
    'description': 'A clean single room available in Johar Town. Near market and public transport.',
  },
  {
    'id': 'sample_3',
    'title': 'Room near FAST',
    'city': 'Islamabad',
    'rent': 'PKR 18,000',
    'period': '/month',
    'tag': 'Male Only',
    'description': 'Room available near FAST University campus. Ideal for students.',
  },
  {
    'id': 'sample_4',
    'title': 'Shared Room, DHA',
    'city': 'Karachi',
    'rent': 'PKR 22,000',
    'period': '/month',
    'tag': '',
    'description': 'Shared room in DHA Karachi with modern facilities.',
  },
  {
    'id': 'sample_5',
    'title': 'Furnished Studio',
    'city': 'Gulberg, Lahore',
    'rent': 'PKR 30,000',
    'period': '/month',
    'tag': 'Female Only',
    'description': 'Fully furnished studio apartment in Gulberg III. All utilities included.',
  },
  {
    'id': 'sample_6',
    'title': 'Hostel Room',
    'city': 'F-8, Islamabad',
    'rent': 'PKR 12,000',
    'period': '/month',
    'tag': 'Male Only',
    'description': 'Shared hostel room near F-8 Markaz. WiFi and meals included.',
  },
];

// ---- Banner data ----
const List<Map<String, String>> _kBanners = [
  {
    'title': 'Find Your Perfect Roommate',
    'subtitle': 'Browse hundreds of verified listings across Pakistan',
    'icon': 'search',
  },
  {
    'title': 'Safety First',
    'subtitle': 'All listings are verified. Chat securely before meeting.',
    'icon': 'shield',
  },
  {
    'title': 'Post Your Listing',
    'subtitle': 'Have a room? Post it free and reach thousands of seekers.',
    'icon': 'post',
  },
];

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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Data
  String _userName = 'Guest';
  List<Listing> _listings = [];
  List<Listing> _featuredListings = [];
  bool _isLoading = true;
  int _totalListings = 0;
  int _recentCount = 0;
  int _unreadChatCount = 2;

  // Banner carousel
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<String> _filters = const [
    'All',
    'Female',
    'Male',
    'Short Term',
    'Long Term',
  ];

  @override
  void initState() {
    super.initState();
    FavoritesService.init();
    _loadUserName();
    _loadListings();
    _startBannerTimer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _bannerController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentBannerIndex < _kBanners.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }
      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
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
      final listings = await ListingsService.fetchRecent(limit: 20);
      final featured = await ListingsService.fetchFeatured();
      final total = await ListingsService.fetchTotalCount();
      final recent = await ListingsService.fetchRecentCount(days: 7);

      if (mounted) {
        setState(() {
          _listings = listings.isEmpty ? _buildSampleListings() : listings;
          _featuredListings = featured.isEmpty ? _listings.where((l) => l.isFeatured || l.rent > 20000).toList() : featured;
          _totalListings = total == 0 ? _listings.length : total;
          _recentCount = recent == 0 ? 3 : recent;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _listings = _buildSampleListings();
          _featuredListings = _listings.take(3).toList();
          _totalListings = _listings.length;
          _recentCount = 3;
          _isLoading = false;
        });
      }
    }
  }

  List<Listing> _buildSampleListings() {
    return _kSampleListings.map((m) => Listing.fromMap({
      'id': m['id'],
      'title': m['title'],
      'city': m['city'],
      'rent': int.tryParse(m['rent']?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0') ?? 0,
      'period': m['period'],
      'tag': m['tag'],
      'description': m['description'],
      'created_at': DateTime.now().subtract(Duration(hours: _kSampleListings.indexOf(m) * 6)).toIso8601String(),
      'is_featured': m['id'] == 'sample_1' || m['id'] == 'sample_5',
    })).toList();
  }

  void _onItemTapped(int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        break;
      case 1:
        _searchFocusNode.requestFocus();
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RequestsScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyProfileScreen()),
        );
        break;
      case 4:
        setState(() => _unreadChatCount = 0);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
        break;
    }
    setState(() => currentIndex = index);
  }

  List<Listing> get _filteredListings {
    return _listings.where((listing) {
      final title = listing.title.toLowerCase();
      final city = listing.city.toLowerCase();
      final tag = listing.tag.toLowerCase();

      final matchesSearch = _searchQuery.isEmpty ||
          title.contains(_searchQuery) ||
          city.contains(_searchQuery) ||
          tag.contains(_searchQuery);

      final matchesLocation = _activeFilter.location.isEmpty ||
          city.contains(_activeFilter.location.toLowerCase());

      int? parseNumber(String s) {
        final clean = s.replaceAll(RegExp(r'[^0-9]'), '');
        return int.tryParse(clean);
      }

      final listingRent = listing.rent;
      final filterBudget = parseNumber(_activeFilter.budget);
      final matchesBudget = filterBudget == null || listingRent <= filterBudget;

      final matchesReligion = _activeFilter.religion.isEmpty ||
          tag.contains(_activeFilter.religion.toLowerCase());

      bool matchesChip = true;
      if (_selectedFilter != 'All') {
        if (_selectedFilter == 'Female') {
          matchesChip = tag.contains('female');
        } else if (_selectedFilter == 'Male') {
          matchesChip = tag.contains('male');
        } else {
          matchesChip = tag.contains(_selectedFilter.toLowerCase());
        }
      }

      return matchesSearch &&
          matchesLocation &&
          matchesBudget &&
          matchesReligion &&
          matchesChip;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          color: _kGold,
          backgroundColor: _kSurface,
          onRefresh: () async {
            await _loadListings();
            _loadUserName();
          },
          child: CustomScrollView(
            slivers: [
              // HEADER
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              // SEARCH BAR
              SliverToBoxAdapter(
                child: _buildSearchBar(),
              ),
              // FILTER CHIPS
              SliverToBoxAdapter(
                child: _buildFilterChips(),
              ),
              // QUICK STATS
              SliverToBoxAdapter(
                child: _buildQuickStats(),
              ),
              // LOCATION QUICK FILTERS
              SliverToBoxAdapter(
                child: _buildLocationFilters(),
              ),
              // BANNER CAROUSEL
              SliverToBoxAdapter(
                child: _buildBannerCarousel(),
              ),
              // FEATURED SECTION
              if (_featuredListings.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                    'Featured Listings',
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SeeAllListingsScreen(
                            title: 'Featured Listings',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildFeaturedCarousel(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
              ],
              // RECENTLY ADDED
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  'Recently Added',
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SeeAllListingsScreen(
                          title: 'Recently Added',
                        ),
                      ),
                    );
                  },
                ),
              ),
              // LISTINGS GRID
              _isLoading
                  ? SliverToBoxAdapter(child: _buildShimmerGrid())
                  : _filteredListings.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.68,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return ListingCard(
                                  data: _filteredListings[index]
                                      .toDisplayMap(),
                                  listingId: _filteredListings[index].id,
                                );
                              },
                              childCount: _filteredListings.length,
                            ),
                          ),
                        ),
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

  // ---- HEADER ----
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: const Icon(Icons.menu, color: _kGold, size: 26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $_userName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Find your perfect roommate',
                  style: TextStyle(fontSize: 12, color: _kMutedText),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: _kGold,
                  size: 26,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- SEARCH BAR ----
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

  // ---- FILTER CHIPS ----
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

  // ---- QUICK STATS ----
  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          _buildStatChip(Icons.home_outlined, '$_totalListings Listings'),
          const SizedBox(width: 10),
          _buildStatChip(Icons.access_time, '$_recentCount New This Week'),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: _kGold, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- LOCATION FILTERS ----
  Widget _buildLocationFilters() {
    final cities = [
      {'name': 'Lahore', 'icon': Icons.location_city},
      {'name': 'Karachi', 'icon': Icons.apartment},
      {'name': 'Islamabad', 'icon': Icons.domain},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: cities.map((city) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeeAllListingsScreen(
                      title: '${city['name']} Listings',
                      cityFilter: city['name'] as String,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kMaroonStart, _kMaroonEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Icon(
                      city['icon'] as IconData,
                      color: _kGold,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      city['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---- BANNER CAROUSEL ----
  Widget _buildBannerCarousel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: _kBanners.length,
              onPageChanged: (index) {
                setState(() => _currentBannerIndex = index);
              },
              itemBuilder: (context, index) {
                final banner = _kBanners[index];
                IconData icon;
                switch (banner['icon']) {
                  case 'shield':
                    icon = Icons.shield_outlined;
                    break;
                  case 'post':
                    icon = Icons.add_circle_outline;
                    break;
                  default:
                    icon = Icons.search;
                }
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _kGold.withValues(alpha: 0.15),
                          _kSurface,
                        ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kGold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: _kGold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                        child: Icon(icon, color: _kGold, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['subtitle']!,
                              style: const TextStyle(
                                color: _kMutedText,
                                fontSize: 11.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _kBanners.length,
              (index) => Container(
                width: _currentBannerIndex == index ? 20 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _currentBannerIndex == index ? _kGold : _kBorder,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- FEATURED CAROUSEL ----
  Widget _buildFeaturedCarousel() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        itemCount: _featuredListings.length,
        itemBuilder: (context, index) {
          final listing = _featuredListings[index];
          final data = listing.toDisplayMap();
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListingDetailScreen(
                    listingData: data,
                    listingId: listing.id,
                  ),
                ),
              );
            },
            child: Container(
              width: 240,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: _kCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kGold.withValues(alpha: 0.3)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
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
                              Icons.star_outline,
                              color: _kGold,
                              size: 36,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _kGold,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'FEATURED',
                              style: TextStyle(
                                color: _kBackground,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (listing.tag.isNotEmpty)
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
                                listing.tag,
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
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            listing.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 11,
                                color: _kGold,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  listing.city,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _kMutedText,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${listing.rentDisplay}${listing.period}',
                            style: const TextStyle(
                              color: _kGoldLight,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  // ---- SECTION HEADER ----
  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'See all',
              style: TextStyle(color: _kGold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ---- SHIMMER LOADING ----
  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.68,
        ),
        itemBuilder: (context, index) {
          return _buildShimmerCard();
        },
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.2,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_kSurface, _kCardBg],
                  begin: Alignment(-1.0, -1.0),
                  end: Alignment(1.0, 1.0),
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _kSurface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- EMPTY STATE ----
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: _kSurface,
                shape: BoxShape.circle,
                border: Border.all(color: _kBorder),
              ),
              child: const Icon(
                Icons.search_off,
                color: _kMutedText,
                size: 52,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No listings found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your filters or\nsearch for something else.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _kMutedText, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedFilter = 'All';
                  _activeFilter = const FilterCriteria();
                });
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGold,
                foregroundColor: _kBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
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
      notchMargin: 8,
      child: SizedBox(
        height: 62,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavIcon(
              icon: Icons.home,
              label: 'Home',
              isActive: currentIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            _NavIcon(
              icon: Icons.search,
              label: 'Search',
              isActive: currentIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            const SizedBox(width: 48),
            _NavIcon(
              icon: Icons.description_outlined,
              label: 'Requests',
              isActive: currentIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            _NavIcon(
              icon: Icons.person_outline,
              label: 'Profile',
              isActive: currentIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            _NavIcon(
              icon: Icons.chat_bubble_outline,
              label: 'Chat',
              isActive: currentIndex == 4,
              onTap: () => _onItemTapped(4),
              badgeCount: _unreadChatCount,
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
                          widget.data['city'] ?? '',
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
