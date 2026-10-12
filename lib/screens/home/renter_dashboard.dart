import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/favorites_service.dart';
import '../../services/listings_service.dart';
import '../../services/location_service.dart';
import '../chat/chat_screen.dart';
import 'favorites_screen.dart';
import 'find_room_screen.dart';
import 'home_screen.dart';
import 'host_dashboard.dart';
import 'listing_detail_screen.dart';
import 'map_screen.dart';
import 'requests_screen.dart';

const Color _kBackground = Color(0xFF0D0D0D);
const Color _kSurface = Color(0xFF1A1717);
const Color _kCardBg = Color(0xFF1C1919);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMaroonEnd = Color(0xFF4E1220);
const Color _kMutedText = Color(0xFF9B9B9B);
const Color _kBorder = Color(0xFF2A2626);

class RenterDashboard extends StatefulWidget {
  const RenterDashboard({super.key});

  @override
  State<RenterDashboard> createState() => _RenterDashboardState();
}

class _RenterDashboardState extends State<RenterDashboard> {
  bool _isLoading = true;
  UserLocation? _loc;
  List<Listing> _nearby = [];
  List<Listing> _favs = [];
  User? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final user = AuthService.currentUser;
      _user = user;
      final loc = await LocationService.getCurrentLocation();
      final favIds =
          user != null ? await FavoritesService.getFavorites(user.id) : <String>{};
      final listings = await ListingsService.fetchListings(
        city: loc?.cityName,
        country: loc?.countryName,
        limit: 30,
      );
      listings.sort((a, b) {
        final da = a.createdAt ?? DateTime(2000);
        final db = b.createdAt ?? DateTime(2000);
        return db.compareTo(da);
      });
      if (mounted) {
        setState(() {
          _loc = loc;
          _favs = listings.where((l) => favIds.contains(l.id)).toList();
          _nearby = listings.take(8).toList();
        });
      }
    } catch (e) {
      debugPrint('RenterDashboard load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?.userMetadata?['name'] ??
        _user?.userMetadata?['full_name'] ??
        'Friend';
    final locCity = _loc?.cityName ?? 'Your City';
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _kGold))
            : RefreshIndicator(
                color: _kGold,
                backgroundColor: _kSurface,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  children: [
                    _buildHeader(name, locCity),
                    _buildFindCTA(),
                    _buildSavedCard(),
                    _buildSectionTitle('Rooms Near You', count: _nearby.length, onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const FindRoomScreen()),
                      );
                    }),
                    _buildHorizontalRooms(_nearby),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Future<void> _switchToHostMode() async {
    await AuthService.setUserRole(UserRole.host);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (c) => const HostDashboard()),
    );
  }

  Widget _buildRoleSwitchButton() {
    return InkWell(
      onTap: _switchToHostMode,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: _kGold.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kGold.withValues(alpha: 0.45)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apartment_rounded, color: _kGold, size: 13),
            SizedBox(width: 4),
            Text(
              'Host Mode',
              style: TextStyle(color: _kGold, fontSize: 10.5, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 2),
            Icon(Icons.swap_horiz, color: _kGold, size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String city) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'USER DASHBOARD',
                  style: TextStyle(
                    color: _kGold,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hello, $name 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: _kGold, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      city,
                      style: const TextStyle(color: _kMutedText, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kMaroonStart.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kMaroonStart.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_search_rounded, color: _kGoldLight, size: 11),
                    SizedBox(width: 3),
                    Text(
                      'USER / SEEKER',
                      style: TextStyle(
                        color: _kGoldLight,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              _buildRoleSwitchButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFindCTA() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const FindRoomScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [_kMaroonStart, _kMaroonEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: _kGold.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.search_rounded, color: _kGoldLight, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find your perfect room',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Browse verified listings near ${_loc?.cityName ?? 'you'}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    color: _kMaroonEnd, size: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedCard() {
    final count = _favs.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const FavoritesScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.favorite_rounded, color: _kGold, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count Saved ${count == 1 ? 'Room' : 'Rooms'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      count == 0
                          ? 'Tap to browse listings and save favorites'
                          : 'Quickly access your shortlisted options',
                      style: const TextStyle(color: _kMutedText, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: _kGold, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {int? count, VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: _kGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: _kGold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text(
                'See All',
                style: TextStyle(color: _kGold, fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalRooms(List<Listing> items) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.hotel_class_outlined, color: _kGold, size: 22),
              SizedBox(height: 8),
              Text(
                'Finding rooms for you...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Check back shortly or tap Find Room to manually search near your city.',
                style: TextStyle(color: _kMutedText, fontSize: 11.5, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox(
      height: 230,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (c, i) => _buildRoomCard(items[i]),
      ),
    );
  }

  Widget _buildRoomCard(Listing l) {
    final display = l.toDisplayMap();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => ListingDetailScreen(
              listingData: display,
              listingId: l.id,
            ),
          ),
        );
      },
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: _kSurface,
                    child: l.imageUrl != null && l.imageUrl!.isNotEmpty
                        ? Image.network(
                            l.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _ph(),
                          )
                        : _ph(),
                  ),
                  if (l.isFeatured)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kGold,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: _kMaroonEnd, size: 9),
                            const SizedBox(width: 2),
                            const Text(
                              'TOP',
                              style: TextStyle(
                                color: Color(0xFF1A1717),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (l.distanceKm != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.pin_drop, color: _kGold, size: 9),
                            const SizedBox(width: 2),
                            Text(
                              l.distanceKm! < 1
                                  ? '${(l.distanceKm! * 1000).toStringAsFixed(0)}m'
                                  : '${l.distanceKm!.toStringAsFixed(0)}km',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                    l.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: _kMutedText, size: 10),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          l.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _kMutedText, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l.rentDisplay,
                        style: const TextStyle(
                          color: _kGold,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          l.period,
                          style: const TextStyle(color: _kMutedText, fontSize: 9),
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

  Widget _ph() => Center(
        child: Icon(Icons.home_work_outlined,
            color: _kGold.withValues(alpha: 0.35), size: 26),
      );

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            child: Text(
              'Quick Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              _action(
                Icons.chat_bubble_outline_rounded,
                'Messages',
                _kGold,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const ChatScreen()),
                  );
                },
              ),
              const SizedBox(width: 10),
              _action(
                Icons.assignment_outlined,
                'My Requests',
                _kMaroonStart,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const RequestsScreen()),
                  );
                },
              ),
              const SizedBox(width: 10),
              _action(
                Icons.map_outlined,
                'Map View',
                Colors.teal,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const MapScreen()),
                  );
                },
              ),
              const SizedBox(width: 10),
              _action(
                Icons.apartment_rounded,
                'Host Hub',
                _kGoldLight,
                _switchToHostMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: _kSurface,
      elevation: 0,
      notchMargin: 6,
      shape: const CircularNotchedRectangle(),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(Icons.home_outlined, 'Home', true, () {}),
            _navItem(Icons.explore_outlined, 'Explore', false, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const FindRoomScreen()),
              );
            }),
            const SizedBox(width: 54),
            _navItem(Icons.favorite_border, 'Saved', false, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const FavoritesScreen()),
              );
            }),
            _navItem(Icons.person_outline, 'Profile', false, () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (c) => const HomeScreen(initialIndex: 0, openProfile: true)),
                (r) => false,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? _kGold : _kMutedText, size: 21),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: active ? _kGold : _kMutedText,
                fontSize: 10.5,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
