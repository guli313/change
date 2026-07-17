import 'package:flutter/material.dart';
import '../../services/listings_service.dart';
import 'listing_detail_screen.dart';

const Color _kBackground = Color(0xFF0D0D0D);
const Color _kSurface = Color(0xFF1A1717);
const Color _kCardBg = Color(0xFF1C1919);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMutedText = Color(0xFF9B9B9B);
const Color _kBorder = Color(0xFF2A2626);

class SeeAllListingsScreen extends StatefulWidget {
  final String? title;
  final String? cityFilter;

  const SeeAllListingsScreen({
    super.key,
    this.title,
    this.cityFilter,
  });

  @override
  State<SeeAllListingsScreen> createState() => _SeeAllListingsScreenState();
}

class _SeeAllListingsScreenState extends State<SeeAllListingsScreen> {
  List<Listing> _listings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    try {
      final listings = await ListingsService.fetchListings(
        city: widget.cityFilter,
        limit: 50,
      );
      if (mounted) {
        setState(() {
          _listings = listings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kBackground,
        elevation: 0,
        title: Text(
          widget.title ?? 'All Listings',
          style: const TextStyle(
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
          : _listings.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _listings.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    return _buildListingCard(_listings[index]);
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
              Icons.home_work_outlined,
              color: _kMutedText,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
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
            'Check back later for new listings.',
            style: TextStyle(color: _kMutedText, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(Listing listing) {
    final data = listing.toDisplayMap();
    final tag = listing.tag;

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
                          color: _kMaroonStart,
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
                    listing.title,
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
                          listing.city,
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
                        listing.rentDisplay,
                        style: const TextStyle(
                          color: _kGoldLight,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        listing.period,
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
