import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/favorites_service.dart';

const Color _kBackground = Color(0xFF0D0D0D);
const Color _kSurface = Color(0xFF1A1717);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMutedText = Color(0xFF9B9B9B);
const Color _kBorder = Color(0xFF2A2626);

class ListingDetailScreen extends StatefulWidget {
  final Map<String, String> listingData;
  final String? listingId;

  const ListingDetailScreen({
    super.key,
    required this.listingData,
    this.listingId,
  });

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _isFavorite = false;
  String _ownerName = '';
  String _ownerPhone = '';

  @override
  void initState() {
    super.initState();
    _loadFavorite();
    _loadOwner();
  }

  void _loadFavorite() {
    final id = widget.listingId ?? widget.listingData['id'] ?? '';
    if (id.isNotEmpty) {
      setState(() {
        _isFavorite = FavoritesService.isFavorite(id);
      });
    }
  }

  Future<void> _loadOwner() async {
    final userId = widget.listingData['userId'];
    if (userId == null || userId.isEmpty) return;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('name, phone')
          .eq('id', userId)
          .maybeSingle();
      if (data != null && mounted) {
        setState(() {
          _ownerName = data['name']?.toString() ?? '';
          _ownerPhone = data['phone']?.toString() ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    final id = widget.listingId ?? widget.listingData['id'] ?? '';
    if (id.isEmpty) return;
    await FavoritesService.toggleFavorite(id);
    setState(() {
      _isFavorite = FavoritesService.isFavorite(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.listingData;
    final tag = data['tag'] ?? '';
    final rent = data['rent'] ?? '';
    final period = data['period'] ?? '/month';
    final title = data['title'] ?? '';
    final city = data['city'] ?? '';
    final description = data['description'] ?? 'No description available.';

    return Scaffold(
      backgroundColor: _kBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: _kBackground,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
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
                        size: 60,
                      ),
                    ),
                  ),
                  if (tag.isNotEmpty)
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: const BoxDecoration(
                          color: _kMaroonStart,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: _kGold),
                      const SizedBox(width: 4),
                      Text(
                        city,
                        style: const TextStyle(
                          color: _kMutedText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                    color: _kGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kGold.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          rent,
                          style: const TextStyle(
                            color: _kGoldLight,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          period,
                          style: const TextStyle(
                            color: _kMutedText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_ownerName.isNotEmpty || _ownerPhone.isNotEmpty) ...[
                    const Text(
                      'Contact',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: _kGold.withValues(alpha: 0.15),
                            child: const Icon(Icons.person, color: _kGold),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _ownerName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_ownerPhone.isNotEmpty)
                                  Text(
                                    _ownerPhone,
                                    style: const TextStyle(
                                      color: _kMutedText,
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contact request sent!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text(
                        'Send Contact Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGold,
                        foregroundColor: _kBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
