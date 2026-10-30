import 'package:flutter/material.dart';
import 'search_roommate_screen.dart';
import 'send_request_screen.dart';

const Color _kBackground = Color(0xFF0D0D0D);
const Color _kSurface = Color(0xFF1A1717);
const Color _kCardBg = Color(0xFF1C1919);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMaroonEnd = Color(0xFF4E1220);
const Color _kBorder = Color(0xFF2A2626);
const Color _kMutedText = Color(0xFF9B9B9B);

class RequestsScreen extends StatefulWidget {
  final String? initialFilter;
  const RequestsScreen({super.key, this.initialFilter});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  late String _selectedFilter;
  bool _isAppBarSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? 'All';
  }

  final List<Map<String, dynamic>> _allRequests = [
    {
      'id': 'req_1',
      'name': 'Ayesha Khan',
      'status': 'Incoming request',
      'type': 'Incoming',
      'city': 'Islamabad',
      'area': 'DHA Phase 2',
      'date': '2 hours ago',
      'details': 'Looking for a female roommate near DHA Phase 2, Islamabad. Budget Rs. 25,000.',
      'avatar': 'A',
      'budget': 'PKR 25,000',
    },
    {
      'id': 'req_2',
      'name': 'Bilal Ahmed',
      'status': 'Sent request',
      'type': 'Sent',
      'city': 'Lahore',
      'area': 'Johar Town',
      'date': 'Yesterday',
      'details': 'Request sent for a 1-room shared flat in Johar Town, near Expo Center.',
      'avatar': 'B',
      'budget': 'PKR 18,000',
    },
    {
      'id': 'req_3',
      'name': 'Usman Tariq',
      'status': 'Incoming request',
      'type': 'Incoming',
      'city': 'Karachi',
      'area': 'Gulshan-e-Iqbal',
      'date': '2 days ago',
      'details': 'Inquiring about 2-bed apartment sharing in Gulshan-e-Iqbal. Working IT professional.',
      'avatar': 'U',
      'budget': 'PKR 22,000',
    },
    {
      'id': 'req_4',
      'name': 'Zainab Malik',
      'status': 'Sent request',
      'type': 'Sent',
      'city': 'Rawalpindi',
      'area': 'Bahria Town Phase 7',
      'date': '3 days ago',
      'details': 'Request sent for single room in Bahria Town Phase 7. Furnished with WiFi.',
      'avatar': 'Z',
      'budget': 'PKR 20,000',
    },
    {
      'id': 'req_5',
      'name': 'Hamza Farooq',
      'status': 'Incoming request',
      'type': 'Incoming',
      'city': 'Lahore',
      'area': 'Mall Road',
      'date': '5 days ago',
      'details': 'Medical student looking for a quiet roommate near King Edward / Mall Road.',
      'avatar': 'H',
      'budget': 'PKR 15,000',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredRequests {
    return _allRequests.where((req) {
      final nameMatches = req['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final detailsMatches = req['details'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final cityMatches = req['city'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final areaMatches = req['area'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final queryMatches = _searchQuery.isEmpty || nameMatches || detailsMatches || cityMatches || areaMatches;

      final filterMatches = _selectedFilter == 'All' || req['type'] == _selectedFilter;

      return queryMatches && filterMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRequests;
    final incomingCount = _allRequests.where((r) => r['type'] == 'Incoming').length;
    final sentCount = _allRequests.where((r) => r['type'] == 'Sent').length;

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: _buildTopAppBar(),
      body: Column(
        children: [
          // VERY TOP: Prominent "Search Requests" Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: const BoxDecoration(
              color: _kSurface,
              border: Border(
                bottom: BorderSide(color: _kBorder, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: _kCardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _searchQuery.isNotEmpty ? _kGold : _kBorder,
                      width: _searchQuery.isNotEmpty ? 1.4 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search requests by name, city, area...',
                      hintStyle: const TextStyle(color: _kMutedText, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: _kGold, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, color: _kMutedText, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Requests', 'All', _allRequests.length),
                      const SizedBox(width: 8),
                      _buildFilterChip('Incoming', 'Incoming', incomingCount),
                      const SizedBox(width: 8),
                      _buildFilterChip('Sent', 'Sent', sentCount),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Requests List
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final request = filtered[index];
                      final isSent = request['type'] == 'Sent';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _kCardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSent ? _kBorder : _kGold.withOpacity(0.35),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: _kSurface,
                                  child: Text(
                                    request['avatar'],
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
                                      Text(
                                        request['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, color: _kGold, size: 12),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${request['area']}, ${request['city']} • ${request['date']}',
                                            style: const TextStyle(color: _kMutedText, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSent
                                        ? _kGold.withOpacity(0.15)
                                        : const Color(0xFF81C784).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSent ? _kGold : const Color(0xFF81C784),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    request['status'],
                                    style: TextStyle(
                                      color: isSent ? _kGoldLight : const Color(0xFF81C784),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              request['details'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13.5,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _showRequestDetailsModal(context, request),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(color: _kBorder),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text('View Details', style: TextStyle(fontSize: 13)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const SendRequestScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _kGold,
                                      foregroundColor: _kBackground,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      isSent ? 'Send Another' : 'Reply / Accept',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
      ),
    );
  }

  PreferredSizeWidget _buildTopAppBar() {
    if (_isAppBarSearchOpen) {
      return AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _isAppBarSearchOpen = false;
              _searchQuery = '';
              _searchController.clear();
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: const InputDecoration(
            hintText: 'Search requests...',
            hintStyle: TextStyle(color: _kMutedText, fontSize: 14),
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val.trim();
            });
          },
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: _kMutedText),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      );
    }

    return AppBar(
      backgroundColor: _kBackground,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/icons/appicon.png',
              height: 26,
              width: 26,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Requests',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Search Roommates',
          icon: const Icon(Icons.person_search, color: _kGold, size: 24),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SearchRoommateScreen(),
              ),
            );
          },
        ),
        IconButton(
          tooltip: 'Send New Request',
          icon: const Icon(Icons.add_circle_outline, color: _kGoldLight, size: 24),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SendRequestScreen()),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildFilterChip(String label, String filterKey, int count) {
    final isSelected = _selectedFilter == filterKey;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _kGold : _kCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _kGold : _kBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _kBackground : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? _kBackground.withOpacity(0.25) : _kSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? _kBackground : _kGoldLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, color: _kMutedText.withOpacity(0.5), size: 54),
            const SizedBox(height: 14),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No requests found matching "$_searchQuery"'
                  : 'No requests in "$_selectedFilter"',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try searching with a different name, city, or area.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _kMutedText, fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (_searchQuery.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear, color: _kGold, size: 16),
                label: const Text('Clear Search', style: TextStyle(color: _kGold, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _kGold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showRequestDetailsModal(BuildContext context, Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _kCardBg,
                  child: Text(
                    request['avatar'],
                    style: const TextStyle(color: _kGold, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['name'],
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${request['area']}, ${request['city']} • ${request['date']}',
                        style: const TextStyle(color: _kMutedText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (request['budget'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _kGold, width: 0.8),
                    ),
                    child: Text(
                      request['budget'],
                      style: const TextStyle(color: _kGoldLight, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const Divider(color: _kBorder, height: 24),
            const Text(
              'Request Message',
              style: TextStyle(color: _kGoldLight, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              request['details'],
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SendRequestScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGold,
                  foregroundColor: _kBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Reply to Request', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
