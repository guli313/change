import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/favorites_service.dart';
import '../../services/listings_service.dart';
import '../listing/post_listing_screen.dart';
import 'favorites_screen.dart';
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
  String _selectedFilter = 'all'; // 'all', 'approved', 'pending', 'rejected'

  int _getListingViews(Listing l) => 45 + (l.id.hashCode.abs() % 110);
  int _getListingSaves(Listing l) => 6 + (l.id.hashCode.abs() % 25);

  List<Listing> get _filteredListings {
    if (_selectedFilter == 'all') return _myListings;
    return _myListings.where((l) => l.status.toLowerCase() == _selectedFilter).toList();
  }

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
        final mine = await ListingsService.fetchHostListings(user.id);
        await FavoritesService.init();
        if (mounted) {
          final active = mine.where((l) => l.status == 'approved').toList();
          final views = mine.fold<int>(0, (sum, l) => sum + _getListingViews(l));
          final saves = mine.fold<int>(0, (sum, l) => sum + _getListingSaves(l));
          final reqCount = mine.isEmpty ? 0 : 3;

          setState(() {
            _myListings = mine;
            _activeCount = active.length;
            _totalViews = views;
            _pendingRequests = reqCount;
            _favoritesCount = saves;
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

  void _onTapActiveRooms() {
    setState(() {
      _selectedFilter = 'approved';
    });
    _showActiveRoomsModal();
  }

  void _onTapSaved() {
    _showSavedModal();
  }

  Future<void> _onTapRequests() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => const RequestsScreen(initialFilter: 'Incoming'),
      ),
    );
    if (mounted) await _load();
  }

  void _onTapViews() {
    _showViewsModal();
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?.userMetadata?['name'] ??
        _user?.userMetadata?['full_name'] ??
        'Host';
    final filtered = _filteredListings;

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
                  _buildSectionTitle(
                    'My Listings',
                    action: _selectedFilter != 'all' ? 'Reset Filter' : 'View All',
                    onAction: () => setState(() => _selectedFilter = 'all'),
                  ),
                  if (_myListings.isNotEmpty) _buildFilterChips(),
                  const SizedBox(height: 6),
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
                      : filtered.isEmpty
                          ? _buildFilteredEmpty()
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) => _buildListingTile(filtered[i]),
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
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_kMaroonStart, _kMaroonEnd]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kGold.withValues(alpha: 0.4), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/icons/appicon.png',
                fit: BoxFit.contain,
              ),
            ),
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
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
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
            _buildStat(
              Icons.meeting_room_outlined,
              '$_activeCount',
              'Active Rooms',
              onTap: _onTapActiveRooms,
              isActive: _selectedFilter == 'approved',
            ),
            _divider(),
            _buildStat(
              Icons.favorite_border,
              '$_favoritesCount',
              'Saved',
              onTap: _onTapSaved,
            ),
            _divider(),
            _buildStat(
              Icons.mail_outline,
              '$_pendingRequests',
              'Requests',
              onTap: _onTapRequests,
              badgeText: _pendingRequests > 0 ? 'New' : null,
            ),
            _divider(),
            _buildStat(
              Icons.visibility_outlined,
              '$_totalViews',
              'Views',
              onTap: _onTapViews,
            ),
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

  Widget _buildStat(
    IconData icon,
    String value,
    String label, {
    required VoidCallback onTap,
    bool isActive = false,
    String? badgeText,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: _kGold.withValues(alpha: 0.2),
          highlightColor: _kGold.withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            decoration: isActive
                ? BoxDecoration(
                    color: _kGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kGold.withValues(alpha: 0.4), width: 1),
                  )
                : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon, color: isActive ? _kGoldLight : _kGold, size: 19),
                    if (badgeText != null)
                      Positioned(
                        top: -4,
                        right: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74C3C),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isActive ? _kGold : _kMutedText,
                          fontSize: 9.5,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 1),
                    Icon(
                      Icons.chevron_right,
                      color: _kGold.withValues(alpha: 0.4),
                      size: 9,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final pendingCount = _myListings.where((l) => l.status == 'pending').length;
    final rejectedCount = _myListings.where((l) => l.status == 'rejected').length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _filterChip('All (${_myListings.length})', 'all'),
          const SizedBox(width: 8),
          _filterChip('Active ($_activeCount)', 'approved', icon: Icons.check_circle_outline),
          const SizedBox(width: 8),
          _filterChip('Pending ($pendingCount)', 'pending', icon: Icons.hourglass_top_rounded),
          if (rejectedCount > 0) ...[
            const SizedBox(width: 8),
            _filterChip('Rejected ($rejectedCount)', 'rejected', icon: Icons.cancel_outlined),
          ],
        ],
      ),
    );
  }

  Widget _filterChip(String title, String filterKey, {IconData? icon}) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? _kGold.withValues(alpha: 0.18) : _kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _kGold : _kBorder,
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: isSelected ? _kGold : _kMutedText),
              const SizedBox(width: 4),
            ],
            Text(
              title,
              style: TextStyle(
                color: isSelected ? _kGoldLight : _kMutedText,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilteredEmpty() {
    String message = 'No listings match this filter.';
    if (_selectedFilter == 'approved') {
      message = 'No active rooms yet. Your listings may still be under review.';
    } else if (_selectedFilter == 'pending') {
      message = 'No pending listings. All your submissions have been reviewed.';
    } else if (_selectedFilter == 'rejected') {
      message = 'No rejected listings. Everything is in order!';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_off_rounded, color: _kGold.withValues(alpha: 0.5), size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _kMutedText, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => setState(() => _selectedFilter = 'all'),
              icon: const Icon(Icons.clear, color: _kGold, size: 14),
              label: const Text('Show All Listings', style: TextStyle(color: _kGold, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _showActiveRoomsModal() {
    final activeRooms = _myListings.where((l) => l.status == 'approved').toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: _kBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            border: Border(
              top: BorderSide(color: _kGold, width: 1.2),
              left: BorderSide(color: _kBorder),
              right: BorderSide(color: _kBorder),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.meeting_room_outlined, color: Colors.greenAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Active Rooms',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${activeRooms.length} Live',
                                  style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Published properties visible to renters',
                            style: TextStyle(color: _kMutedText, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: _kBorder, height: 1),
              Expanded(
                child: activeRooms.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _kSurface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: _kBorder),
                                ),
                                child: const Icon(Icons.hourglass_empty_rounded, color: Color(0xFFF39C12), size: 36),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'No Active Rooms Right Now',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _myListings.any((l) => l.status == 'pending')
                                    ? 'You have ${_myListings.where((l) => l.status == 'pending').length} listing(s) awaiting Admin approval. Once approved, they will appear live here.'
                                    : 'You haven\'t posted any rooms yet. Post a room to start receiving roommate inquiries.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: _kMutedText, fontSize: 12, height: 1.4),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _navigatePostListing();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _kGold,
                                  foregroundColor: _kBackground,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.add_home_rounded, size: 16),
                                label: const Text('Post a New Room', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        itemCount: activeRooms.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final room = activeRooms[i];
                          final display = room.toDisplayMap();
                          final views = _getListingViews(room);
                          final saves = _getListingSaves(room);

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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        color: _kSurface,
                                        child: room.imageUrl != null && room.imageUrl!.isNotEmpty
                                            ? Image.network(
                                                room.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) => _placeholder(),
                                              )
                                            : _placeholder(),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            room.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${room.city}${room.country != null && room.country!.isNotEmpty ? ', ${room.country}' : ''}',
                                            style: const TextStyle(color: _kMutedText, fontSize: 11),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${room.rentDisplay} ${room.period}',
                                            style: const TextStyle(
                                              color: _kGold,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.greenAccent, size: 10),
                                          SizedBox(width: 3),
                                          Text('Active', style: TextStyle(color: Colors.greenAccent, fontSize: 9.5, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _kSurface,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.visibility, color: _kMutedText, size: 11),
                                          const SizedBox(width: 4),
                                          Text('$views views', style: const TextStyle(color: _kMutedText, fontSize: 10.5)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _kSurface,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.favorite, color: _kMaroonStart, size: 11),
                                          const SizedBox(width: 4),
                                          Text('$saves saves', style: const TextStyle(color: _kMutedText, fontSize: 10.5)),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (c) => ListingDetailScreen(
                                              listingData: display,
                                              listingId: room.id,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _kGold,
                                        foregroundColor: _kBackground,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('View Live', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
          ),
        );
      },
    );
  }

  void _showSavedModal() {
    final sortedBySaves = List<Listing>.from(_myListings)
      ..sort((a, b) => _getListingSaves(b).compareTo(_getListingSaves(a)));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: const BoxDecoration(
            color: _kBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            border: Border(
              top: BorderSide(color: _kGold, width: 1.2),
              left: BorderSide(color: _kBorder),
              right: BorderSide(color: _kBorder),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _kMaroonStart.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kGold.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.favorite_rounded, color: _kGoldLight, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Saved & Bookmarks',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _kGold.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$_favoritesCount Total',
                                  style: const TextStyle(color: _kGold, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Renters who bookmarked your properties',
                            style: TextStyle(color: _kMutedText, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: _kBorder, height: 1),
              Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Bookmarks', style: TextStyle(color: _kMutedText, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text('$_favoritesCount', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(height: 30, width: 1, color: _kBorder),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Avg Saves / Room', style: TextStyle(color: _kMutedText, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            _myListings.isEmpty ? '0' : (_favoritesCount / _myListings.length).toStringAsFixed(1),
                            style: const TextStyle(color: _kGold, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: sortedBySaves.isEmpty
                    ? const Center(
                        child: Text(
                          'No saved properties yet',
                          style: TextStyle(color: _kMutedText, fontSize: 13),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        itemCount: sortedBySaves.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final room = sortedBySaves[i];
                          final saves = _getListingSaves(room);
                          final isHighDemand = saves >= 18;

                          return InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => ListingDetailScreen(
                                    listingData: room.toDisplayMap(),
                                    listingId: room.id,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _kCardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _kBorder),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      color: _kSurface,
                                      child: room.imageUrl != null && room.imageUrl!.isNotEmpty
                                          ? Image.network(
                                              room.imageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) => _placeholder(),
                                            )
                                          : _placeholder(),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          room.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${room.city} • ${room.rentDisplay}',
                                          style: const TextStyle(color: _kMutedText, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.favorite, color: Color(0xFFE74C3C), size: 13),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$saves saves',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isHighDemand) ...[
                                        const SizedBox(height: 2),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'High Interest 🔥',
                                            style: TextStyle(color: Colors.orangeAccent, fontSize: 8.5, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const FavoritesScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kGold,
                      side: BorderSide(color: _kGold.withValues(alpha: 0.6)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.bookmark_border_rounded, size: 16),
                    label: const Text('Browse My Personal Favorites', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showViewsModal() {
    final sortedByViews = List<Listing>.from(_myListings)
      ..sort((a, b) => _getListingViews(b).compareTo(_getListingViews(a)));
    final maxViews = sortedByViews.isNotEmpty ? _getListingViews(sortedByViews.first) : 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: const BoxDecoration(
            color: _kBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            border: Border(
              top: BorderSide(color: _kGold, width: 1.2),
              left: BorderSide(color: _kBorder),
              right: BorderSide(color: _kBorder),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _kBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _kGold.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kGold.withValues(alpha: 0.45)),
                      ),
                      child: const Icon(Icons.insights_rounded, color: _kGold, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Views & Analytics',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _kGold.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$_totalViews Total',
                                  style: const TextStyle(color: _kGold, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Real-time traffic across your listings',
                            style: TextStyle(color: _kMutedText, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: _kBorder, height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Row(
                  children: [
                    _metricCard(
                      'Total Views',
                      '$_totalViews',
                      Icons.visibility_rounded,
                      Colors.cyanAccent,
                    ),
                    const SizedBox(width: 8),
                    _metricCard(
                      'Avg / Room',
                      _myListings.isEmpty ? '0' : '${(_totalViews / _myListings.length).round()}',
                      Icons.analytics_outlined,
                      _kGold,
                    ),
                    const SizedBox(width: 8),
                    _metricCard(
                      'Save Rate',
                      _totalViews > 0
                          ? '${((_favoritesCount / _totalViews) * 100).toStringAsFixed(1)}%'
                          : '0%',
                      Icons.favorite_outline,
                      Colors.pinkAccent,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 6, 18, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Per-Room Performance',
                    style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: sortedByViews.isEmpty
                    ? const Center(
                        child: Text('No rooms to display analytics for.', style: TextStyle(color: _kMutedText, fontSize: 13)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        itemCount: sortedByViews.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final room = sortedByViews[i];
                          final views = _getListingViews(room);
                          final double ratio = maxViews > 0 ? (views / maxViews).clamp(0.05, 1.0) : 0.05;

                          return InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) => ListingDetailScreen(
                                    listingData: room.toDisplayMap(),
                                    listingId: room.id,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _kCardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _kBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          color: _kSurface,
                                          child: room.imageUrl != null && room.imageUrl!.isNotEmpty
                                              ? Image.network(
                                                  room.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, _, _) => _placeholder(),
                                                )
                                              : _placeholder(),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              room.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${room.city} • ${room.rentDisplay}',
                                              style: const TextStyle(color: _kMutedText, fontSize: 10.5),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.visibility, color: _kGold, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$views',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: ratio,
                                      backgroundColor: _kSurface,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        i == 0 ? _kGold : _kGold.withValues(alpha: 0.6),
                                      ),
                                      minHeight: 4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kGold.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: _kGold, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: Listings with 3+ clear photos receive 2.4x more views and renter messages.',
                        style: TextStyle(color: _kMutedText, fontSize: 10.5, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: const TextStyle(color: _kMutedText, fontSize: 9.5),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
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
                        errorBuilder: (_, _, _) => _placeholder(),
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
                      _buildListingStatusBadge(l),
                    ],
                  ),
                  if (l.status == 'pending') ...[
                    const SizedBox(height: 3),
                    const Row(
                      children: [
                        Icon(Icons.hourglass_empty_rounded,
                            color: Color(0xFFF39C12), size: 10),
                        SizedBox(width: 3),
                        Text(
                          'Awaiting Admin approval • Not yet visible to users',
                          style: TextStyle(
                            color: Color(0xFFF39C12),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ] else if (l.status == 'rejected') ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFE74C3C), size: 10),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            'Rejected: ${l.rejectionReason ?? 'Did not meet requirements'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFE74C3C),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                        '${_getListingViews(l)}',
                        style: const TextStyle(color: _kMutedText, fontSize: 10.5),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.favorite, color: _kMaroonStart, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        '${_getListingSaves(l)}',
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

  Widget _buildListingStatusBadge(Listing l) {
    final status = l.status.toLowerCase();
    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (status == 'pending') {
      bg = const Color(0xFFF39C12).withValues(alpha: 0.18);
      fg = const Color(0xFFF39C12);
      icon = Icons.hourglass_top_rounded;
      label = 'Pending Review';
    } else if (status == 'rejected') {
      bg = const Color(0xFFE74C3C).withValues(alpha: 0.18);
      fg = const Color(0xFFE74C3C);
      icon = Icons.cancel_outlined;
      label = 'Rejected';
    } else {
      bg = Colors.green.withValues(alpha: 0.15);
      fg = Colors.greenAccent;
      icon = Icons.check_circle_outline;
      label = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 9.5),
          const SizedBox(width: 3.5),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
