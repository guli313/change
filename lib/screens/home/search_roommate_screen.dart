import 'package:flutter/material.dart';
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

/// Sample roommate profiles — replace with real Supabase fetch later
const List<Map<String, dynamic>> _kProfiles = [
  {
    'id': 'u1',
    'name': 'Ayesha Khan',
    'city': 'Islamabad',
    'area': 'DHA Phase 2',
    'gender': 'Female',
    'budget': 'PKR 25,000',
    'occupation': 'Software Engineer',
    'about': 'Clean, non-smoker. Looking for a female roommate near DHA.',
    'avatar': 'A',
  },
  {
    'id': 'u2',
    'name': 'Bilal Ahmed',
    'city': 'Lahore',
    'area': 'Johar Town',
    'gender': 'Male',
    'budget': 'PKR 18,000',
    'occupation': 'University Student',
    'about': 'Looking for a shared flat near Expo Center, Johar Town.',
    'avatar': 'B',
  },
  {
    'id': 'u3',
    'name': 'Usman Tariq',
    'city': 'Karachi',
    'area': 'Gulshan-e-Iqbal',
    'gender': 'Male',
    'budget': 'PKR 22,000',
    'occupation': 'IT Professional',
    'about': 'Working professional, quiet lifestyle, prefer non-smoker roommate.',
    'avatar': 'U',
  },
  {
    'id': 'u4',
    'name': 'Zainab Malik',
    'city': 'Rawalpindi',
    'area': 'Bahria Town Phase 7',
    'gender': 'Female',
    'budget': 'PKR 20,000',
    'occupation': 'Teacher',
    'about': 'Looking for a furnished room in Bahria Town. Prefers females only.',
    'avatar': 'Z',
  },
  {
    'id': 'u5',
    'name': 'Hamza Farooq',
    'city': 'Lahore',
    'area': 'Mall Road',
    'gender': 'Male',
    'budget': 'PKR 15,000',
    'occupation': 'Medical Student',
    'about': 'Med student seeking quiet room near King Edward / Mall Road.',
    'avatar': 'H',
  },
  {
    'id': 'u6',
    'name': 'Sara Hussain',
    'city': 'Islamabad',
    'area': 'F-7 Markaz',
    'gender': 'Female',
    'budget': 'PKR 30,000',
    'occupation': 'Graphic Designer',
    'about': 'Creative professional, neat and organized. Looking for female roommate.',
    'avatar': 'S',
  },
  {
    'id': 'u7',
    'name': 'Ali Raza',
    'city': 'Faisalabad',
    'area': 'Peoples Colony',
    'gender': 'Male',
    'budget': 'PKR 12,000',
    'occupation': 'Factory Worker',
    'about': 'Need an affordable shared room near Peoples Colony industrial area.',
    'avatar': 'A',
  },
  {
    'id': 'u8',
    'name': 'Fatima Noor',
    'city': 'Lahore',
    'area': 'Gulberg III',
    'gender': 'Female',
    'budget': 'PKR 28,000',
    'occupation': 'Marketing Manager',
    'about': 'Looking for a furnished room in Gulberg. Prefer female flatmates.',
    'avatar': 'F',
  },
];

class SearchRoommateScreen extends StatefulWidget {
  const SearchRoommateScreen({super.key});

  @override
  State<SearchRoommateScreen> createState() => _SearchRoommateScreenState();
}

class _SearchRoommateScreenState extends State<SearchRoommateScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _genderFilter = 'All'; // 'All', 'Male', 'Female'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    return _kProfiles.where((p) {
      final q = _searchQuery.toLowerCase();
      final matchesQuery = q.isEmpty ||
          p['name'].toString().toLowerCase().contains(q) ||
          p['city'].toString().toLowerCase().contains(q) ||
          p['area'].toString().toLowerCase().contains(q) ||
          p['occupation'].toString().toLowerCase().contains(q);

      final matchesGender =
          _genderFilter == 'All' || p['gender'] == _genderFilter;

      return matchesQuery && matchesGender;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
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
                height: 24,
                width: 24,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Find Roommates',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Search + Filter Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: const BoxDecoration(
              color: _kSurface,
              border: Border(bottom: BorderSide(color: _kBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Field
                Container(
                  decoration: BoxDecoration(
                    color: _kCardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _searchQuery.isNotEmpty ? _kGold : _kBorder,
                      width: _searchQuery.isNotEmpty ? 1.4 : 1.0,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    onChanged: (v) => setState(() => _searchQuery = v.trim()),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search by name, city, area...',
                      hintStyle:
                          const TextStyle(color: _kMutedText, fontSize: 13),
                      prefixIcon:
                          const Icon(Icons.search, color: _kGold, size: 22),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: _kMutedText, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 13, horizontal: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Gender Filter Chips
                Row(
                  children: [
                    _chip('All'),
                    const SizedBox(width: 8),
                    _chip('Male'),
                    const SizedBox(width: 8),
                    _chip('Female'),
                    const Spacer(),
                    Text(
                      '${results.length} found',
                      style: const TextStyle(
                          color: _kMutedText, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Results List ──
          Expanded(
            child: results.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildCard(results[index]),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Gender Filter Chip ──
  Widget _chip(String label) {
    final isSelected = _genderFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _genderFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _kGold : _kCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _kGold : _kBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? _kBackground : Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ── Profile Card ──
  Widget _buildCard(Map<String, dynamic> p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 26,
            backgroundColor: _kSurface,
            child: Text(
              p['avatar'],
              style: const TextStyle(
                color: _kGold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Gender badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: p['gender'] == 'Female'
                            ? const Color(0xFFE91E63).withOpacity(0.15)
                            : const Color(0xFF2196F3).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: p['gender'] == 'Female'
                              ? const Color(0xFFE91E63)
                              : const Color(0xFF2196F3),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        p['gender'],
                        style: TextStyle(
                          color: p['gender'] == 'Female'
                              ? const Color(0xFFE91E63)
                              : const Color(0xFF64B5F6),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: _kGold, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      '${p['area']}, ${p['city']}',
                      style: const TextStyle(
                          color: _kMutedText, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Occupation + Budget
                Row(
                  children: [
                    const Icon(Icons.work_outline,
                        color: _kMutedText, size: 12),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        p['occupation'],
                        style: const TextStyle(
                            color: _kMutedText, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.payments_outlined,
                        color: _kGold, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      p['budget'],
                      style: const TextStyle(
                          color: _kGoldLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // About
                Text(
                  p['about'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12.5, height: 1.4),
                ),
                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showProfile(context, p),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: _kBorder),
                          padding:
                              const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('View Profile',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SendRequestScreen(toUser: p),
                            ),
                          );
                        },
                        icon: const Icon(Icons.send_rounded, size: 14),
                        label: const Text('Send Request',
                            style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kGold,
                          foregroundColor: _kBackground,
                          padding:
                              const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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

  // ── Empty State ──
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search,
                color: _kMutedText.withOpacity(0.5), size: 60),
            const SizedBox(height: 14),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No roommate found matching "$_searchQuery"'
                  : 'No roommates available',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try a different name, city, or area.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _kMutedText, fontSize: 12),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: const Icon(Icons.clear, color: _kGold, size: 16),
                label: const Text('Clear Search',
                    style: TextStyle(color: _kGold, fontSize: 13)),
                style:
                    OutlinedButton.styleFrom(side: const BorderSide(color: _kGold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Full Profile Bottom Sheet ──
  void _showProfile(BuildContext context, Map<String, dynamic> p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                  color: _kBorder, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 18),

            // Avatar + Name
            CircleAvatar(
              radius: 34,
              backgroundColor: _kCardBg,
              child: Text(p['avatar'],
                  style: const TextStyle(
                      color: _kGold,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Text(p['name'],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${p['area']}, ${p['city']}',
                style:
                    const TextStyle(color: _kMutedText, fontSize: 13)),

            const Divider(color: _kBorder, height: 28),

            // Details Grid
            _detailRow(Icons.work_outline, 'Occupation', p['occupation']),
            const SizedBox(height: 10),
            _detailRow(Icons.payments_outlined, 'Budget', p['budget']),
            const SizedBox(height: 10),
            _detailRow(Icons.person_outline, 'Gender', p['gender']),
            const SizedBox(height: 14),

            // About
            Align(
              alignment: Alignment.centerLeft,
              child: Text('About',
                  style: TextStyle(
                      color: _kGoldLight,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            Text(p['about'],
                style: const TextStyle(
                    color: Colors.white, fontSize: 13.5, height: 1.5)),

            const SizedBox(height: 22),

            // Send Request Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SendRequestScreen(toUser: p)),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Send Request',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGold,
                  foregroundColor: _kBackground,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _kGold, size: 16),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(color: _kMutedText, fontSize: 13)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
