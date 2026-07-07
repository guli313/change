import 'package:flutter/material.dart';

import '../chat/chat_screen.dart';
import '../listing/post_listing_screen.dart';
import '../profile/my_profile_screen.dart';
import 'filter_screen.dart';
import 'notifications_screen.dart';
import 'requests_screen.dart';

// ---- Theme colors (same palette as Login/Signup/Chat screens) ----
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  String _searchQuery = '';
  FilterCriteria _activeFilter = const FilterCriteria();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = const [
    'All',
    'Female',
    'Male',
    'Short Term',
    'Long Term',
  ];

  // Sample data — replace with your Supabase query results.
  final List<Map<String, String>> _listings = const [
    {
      'title': '2 Bed Apartment',
      'city': 'DHA Phase 5, Lahore',
      'rent': 'PKR 25,000',
      'period': '/month',
      'tag': 'Female Only',
    },
    {
      'title': '1 Room Available',
      'city': 'Johar Town, Lahore',
      'rent': 'PKR 15,000',
      'period': '/month',
      'tag': '',
    },
    {
      'title': 'Room near FAST',
      'city': 'Islamabad',
      'rent': 'PKR 18,000',
      'period': '/month',
      'tag': 'Male Only',
    },
    {
      'title': 'Shared Room, DHA',
      'city': 'Karachi',
      'rent': 'PKR 22,000',
      'period': '/month',
      'tag': '',
    },
  ];

  void _onItemTapped(int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        // Home
        break;
      case 1:
        // TODO: hook up to a dedicated search screen if you add one
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
        break;
    }

    setState(() => currentIndex = index);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredListings {
    return _listings.where((listing) {
      final title = listing['title']?.toLowerCase() ?? '';
      final city = listing['city']?.toLowerCase() ?? '';
      final tag = listing['tag']?.toLowerCase() ?? '';
      final matchesSearch =
          _searchQuery.isEmpty ||
          title.contains(_searchQuery) ||
          city.contains(_searchQuery) ||
          tag.contains(_searchQuery);
      final matchesLocation =
          _activeFilter.location.isEmpty ||
          city.contains(_activeFilter.location.toLowerCase());
      final matchesBudget =
          _activeFilter.budget.isEmpty ||
          listing['rent']?.toLowerCase().contains(
                _activeFilter.budget.toLowerCase(),
              ) ==
              true;
      final matchesReligion =
          _activeFilter.religion.isEmpty ||
          tag.contains(_activeFilter.religion.toLowerCase());

      return matchesSearch &&
          matchesLocation &&
          matchesBudget &&
          matchesReligion;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Icon(Icons.menu, color: _kGold, size: 26),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hello, GULSHAN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Find your perfect roommate',
                          style: TextStyle(fontSize: 12, color: _kMutedText),
                        ),
                      ],
                    ),
                  ),
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
            ),
            const SizedBox(height: 12),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Search city, area or keyword...',
                          hintStyle: TextStyle(
                            color: _kMutedText,
                            fontSize: 13.5,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.trim().toLowerCase();
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.favorite_border,
                        color: _kGold,
                        size: 20,
                      ),
                      onPressed: () {},
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
                          setState(() {
                            _activeFilter = result;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // SECTION HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recommended for you',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
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
            ),
            const SizedBox(height: 12),

            // LISTINGS GRID
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: _filteredListings.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  return ListingCard(data: _filteredListings[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
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
              const SizedBox(width: 48), // space for the notch/FAB
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
              ),
            ],
          ),
        ),
      ),
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
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
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
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class ListingCard extends StatefulWidget {
  final Map<String, String> data;

  const ListingCard({super.key, required this.data});

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final tag = widget.data['tag'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE PLACEHOLDER — swap for Image.network(imageUrl, fit: BoxFit.cover)
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
                    onTap: () => setState(() => _isFavorite = !_isFavorite),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.black45,
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 15,
                        color: _isFavorite ? _kMaroon : Colors.white,
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
                    const Icon(Icons.location_on, size: 12, color: _kGold),
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
                      style: const TextStyle(color: _kMutedText, fontSize: 10),
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
}
