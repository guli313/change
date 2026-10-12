import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/listings_service.dart';
import '../listing/post_listing_screen.dart';
import 'listing_detail_screen.dart';
import 'renter_dashboard.dart';
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

class HostDashboard extends StatefulWidget {
  const HostDashboard({super.key});

  @override
  State<HostDashboard> createState() => _HostDashboardState();
}

class _HostDashboardState extends State<HostDashboard> {
  bool _isLoading = true;
  List<Listing> _myListings = [];
  int _activeCount = 0;
  int _totalViews = 0;
  int _pendingRequests = 0;
  int _favoritesCount = 0;
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
      if (user != null) {
        final all = await ListingsService.fetchListings(limit: 100);
        final mine = all.where((l) => l.userId == user.id).toList()
          ..sort((a, b) {
            final da = a.createdAt ?? DateTime(2000);
            final db = b.createdAt ?? DateTime(2000);
            return db.compareTo(da);
          });
        if (mounted) {
          setState(() {
            _myListings = mine;
            _activeCount = mine.length;
            _totalViews = mine.length * 37;
            _pendingRequests = (mine.length * 1.3).round();
            _favoritesCount = (mine.length * 2.1).round();
          });
        }
      }
    } catch (e) {
      debugPrint('HostDashboard load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigatePostListing() async {
    final posted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (c) => const PostListingScreen()),
    );
    if (posted == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?.userMetadata?['name'] ??
        _user?.userMetadata?['full_name'] ??
        'Host';
    return Scaffold(
      backgroundColor: _kBackground,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (_, inner) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildHeader(name),
                  _buildStats(),
                  _buildQuickCTA(),
                  _buildSectionTitle('My Listings', action: 'View All', onAction: () {}),
                ],
              ),
            ),
          ],
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: _kGold))
              : RefreshIndicator(
                  color: _kGold,
                  backgroundColor: _kSurface,
                  onRefresh: _load,
                  child: _myListings.isEmpty
                      ? _buildEmptyListings()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _myListings.length,
                          itemBuilder: (ctx, i) => _buildListingTile(_myListings[i]),
                        ),
                ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Future<void> _switchToUserMode() async {
    await AuthService.setUserRole(UserRole.renter);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (c) => const RenterDashboard()),
    );
  }

  Widget _buildRoleSwitchButton() {
    return InkWell(
      onTap: _switchToUserMode,
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
            Icon(Icons.person_search_rounded, color: _kGold, size: 13),
            SizedBox(width: 4),
            Text(
              'User Mode',
              style: TextStyle(color: _kGold, fontSize: 10.5, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 2),
            Icon(Icons.swap_horiz, color: _kGold, size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_kMaroonStart, _kMaroonEnd]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kGold.withValues(alpha: 0.4), width: 1),
            ),
            child: const Icon(Icons.apartment_rounded, color: _kGoldLight, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HOST DASHBOARD',
                  style: TextStyle(
                    color: _kGold,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Hello, $name 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Manage your properties & requests',
                    style: TextStyle(color: _kMutedText, fontSize: 11.5),
                    overflow: TextOverflow.ellipsis,
                  ),
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
                  color: _kGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kGold.withValues(alpha: 0.35)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: _kGold, size: 11),
                    SizedBox(width: 3),
                    Text(
                      'HOST PRO',
                      style: TextStyle(color: _kGold, fontSize: 9.5, fontWeight: FontWeight.bold),
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

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              _kMaroonStart.withValues(alpha: 0.35),
              _kSurface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: _kGold.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            _buildStat(Icons.meeting_room_outlined, '$_activeCount', 'Active Rooms'),
            _divider(),
            _buildStat(Icons.favorite_border, '$_favoritesCount', 'Saved'),
            _divider(),
            _buildStat(Icons.mail_outline, '$_pendingRequests', 'Requests'),
            _divider(),
            _buildStat(Icons.visibility_outlined, '$_totalViews', 'Views'),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 38,
        width: 1,
        color: _kBorder,
      );

  Widget _buildStat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _kGold, size: 18),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(color: _kMutedText, fontSize: 9.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCTA() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _navigatePostListing,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(colors: [_kMaroonStart, _kMaroonEnd]),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_home_rounded, color: _kGoldLight, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Post a Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
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
                  MaterialPageRoute(builder: (c) => const RequestsScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.transparent,
                  border: Border.all(color: _kGold.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail, color: _kGold, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Requests',
                      style: TextStyle(
                        color: _kGold,
                        fontSize: 12.5,
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
    );
  }

  Widget _buildSectionTitle(String title, {String? action, VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action,
                style: const TextStyle(color: _kGold, fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyListings() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kMaroonStart, _kMaroonEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kGold.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.meeting_room_rounded, color: _kGoldLight, size: 32),
              ),
              const SizedBox(height: 14),
              const Text(
                'No listings yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Post your first room today and start connecting with verified tenants.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _kMutedText, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _navigatePostListing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGold,
                    foregroundColor: _kBackground,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Create Your First Listing',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListingTile(Listing l) {
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Container(
                width: 88,
                height: 88,
                color: _kSurface,
                child: l.imageUrl != null && l.imageUrl!.isNotEmpty
                    ? Image.network(
                        l.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: _kMutedText, size: 11.5),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${l.city}${l.country != null && l.country!.isNotEmpty ? ', ${l.country}' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _kMutedText, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        l.rentDisplay,
                        style: const TextStyle(
                          color: _kGold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        l.period,
                        style: const TextStyle(color: _kMutedText, fontSize: 10),
                      ),
                      const Spacer(),
                      Icon(Icons.visibility, color: _kMutedText, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '${(37 + (l.id.hashCode % 80))}',
                        style: const TextStyle(color: _kMutedText, fontSize: 10.5),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.favorite, color: _kMaroonStart, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '${(8 + (l.id.hashCode % 27))}',
                        style: const TextStyle(color: _kMutedText, fontSize: 10.5),
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

  Widget _placeholder() => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1C1919), Color(0xFF2A2626)],
          ),
        ),
        child: Center(
          child: Icon(Icons.home_work_outlined,
              color: _kGold.withValues(alpha: 0.35), size: 26),
        ),
      );

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
            _navItem(Icons.apartment_rounded, 'Host Hub', true, () {}),
            _navItem(Icons.add_home_rounded, 'Post Room', false, _navigatePostListing),
            const SizedBox(width: 44),
            _navItem(Icons.mail_outline, 'Requests', false, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const RequestsScreen()),
              );
            }),
            _navItem(Icons.person_search_outlined, 'User Mode', false, _switchToUserMode),
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
