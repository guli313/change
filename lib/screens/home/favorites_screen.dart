import 'package:flutter/material.dart';
import '../../services/favorites_service.dart';
import '../../services/listings_service.dart';
import 'listing_detail_screen.dart';

const Color _kBackground = Color(0xFF0D0D0D);
const Color _kSurface = Color(0xFF1A1717);
const Color _kCardBg = Color(0xFF1C1919);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMutedText = Color(0xFF9B9B9B);
const Color _kBorder = Color(0xFF2A2626);

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Listing> _favoriteListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await FavoritesService.init();
    final ids = FavoritesService.favoriteIds;
    if (ids.isEmpty) {
      setState(() {
        _favoriteListings = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final allListings = await ListingsService.fetchRecent(limit: 100);
      setState(() {
        _favoriteListings =
            allListings.where((l) => ids.contains(l.id)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kBackground,
        elevation: 0,
        title: const Text(
          'Favorites',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_kGold),
              ),
            )
          : _favoriteListings.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favoriteListings.length,
                  itemBuilder: (context, index) {
                    final listing = _favoriteListings[index];
                    return _buildFavoriteCard(listing);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _kSurface,
              shape: BoxShape.circle,
              border: Border.all(color: _kBorder),
            ),
            child: const Icon(
              Icons.favorite_border,
              color: _kMutedText,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the heart icon on any listing\nto save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _kMutedText, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(Listing listing) {
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
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A2424), Color(0xFF1A1616)],
                ),
              ),
              child: const Icon(
                Icons.chair_alt_outlined,
                color: _kMutedText,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
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
                          listing.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _kMutedText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${listing.rentDisplay}${listing.period}',
                    style: const TextStyle(
                      color: _kGoldLight,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red, size: 22),
              onPressed: () async {
                await FavoritesService.removeFavorite(listing.id);
                _loadFavorites();
              },
            ),
          ],
        ),
      ),
    );
  }
}
