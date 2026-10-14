import 'package:flutter/material.dart';
import '../../services/listings_service.dart';
import '../../services/location_service.dart';
import 'listing_detail_screen.dart';
import 'map_screen.dart';

const Color _kBackground = Color(0xFF0D0D0D);
const Color _kSurface = Color(0xFF1A1717);
const Color _kCardBg = Color(0xFF1C1919);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMutedText = Color(0xFF9B9B9B);
const Color _kBorder = Color(0xFF2A2626);

const List<String> _kTopCities = [
  'Lahore',
  'Karachi',
  'Islamabad',
  'Rawalpindi',
  'Faisalabad',
  'Multan',
  'Peshawar',
  'Sialkot',
  'Gujranwala',
  'London',
  'New York',
];

const List<int> _kRadiusOptions = [5, 10, 25, 50, 100, 0];

class FindRoomScreen extends StatefulWidget {
  const FindRoomScreen({super.key});

  @override
  State<FindRoomScreen> createState() => _FindRoomScreenState();
}

class _FindRoomScreenState extends State<FindRoomScreen> {
  UserLocation? _userLocation;
  List<Listing> _listings = [];
  bool _isLoadingLocation = true;
  bool _isLoadingListings = true;
  int _selectedRadius = 0;

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  Future<void> _initScreen() async {
    await _loadLocation();
    await _loadListings();
  }

  Future<void> _loadLocation() async {
    setState(() => _isLoadingLocation = true);
    final loc = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _userLocation = loc;
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _loadListings() async {
    setState(() => _isLoadingListings = true);
    try {
      final listings = await ListingsService.fetchListings(
        city: _userLocation?.cityName,
        country: _userLocation?.countryName,
        limit: 50,
      );
      final computed = _computeDistances(listings);
      if (mounted) {
        setState(() {
          _listings = computed;
          _isLoadingListings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingListings = false);
      }
    }
  }

  List<Listing> _computeDistances(List<Listing> input) {
    final loc = _userLocation;
    if (loc == null) return input;
    return input.map((l) {
      if (l.latitude == null || l.longitude == null) {
        return l;
      }
      final d = LocationService.distanceKm(
        loc.latitude,
        loc.longitude,
        l.latitude!,
        l.longitude!,
      );
      return Listing(
        id: l.id,
        title: l.title,
        city: l.city,
        country: l.country,
        rent: l.rent,
        currency: l.currency,
        period: l.period,
        tag: l.tag,
        description: l.description,
        imageUrl: l.imageUrl,
        userId: l.userId,
        createdAt: l.createdAt,
        isFeatured: l.isFeatured,
        latitude: l.latitude,
        longitude: l.longitude,
        distanceKm: d,
      );
    }).toList();
  }

  List<Listing> get _filteredListings {
    if (_userLocation == null) return _listings;
    return _listings.where((l) {
      if (l.distanceKm == null) return false;
      if (_selectedRadius == 0) return true;
      return l.distanceKm! <= _selectedRadius;
    }).toList()
      ..sort((a, b) {
        final da = a.distanceKm ?? 999999;
        final db = b.distanceKm ?? 999999;
        return da.compareTo(db);
      });
  }

  void _openCitySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        String tempCity = _userLocation?.cityName ?? 'Lahore';
        int tempRadius = _selectedRadius;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _kBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.location_city, color: _kGold, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Select Your City & Diameter',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pick your city to see rooms within your preferred diameter:',
                    style: TextStyle(color: _kMutedText, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Popular Cities:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final c in _kTopCities) ...[
                        ChoiceChip(
                          label: Text(c),
                          selected: tempCity.toLowerCase() == c.toLowerCase(),
                          selectedColor: _kGold,
                          backgroundColor: _kCardBg,
                          labelStyle: TextStyle(
                            color: tempCity.toLowerCase() == c.toLowerCase()
                                ? _kBackground
                                : Colors.white70,
                            fontWeight:
                                tempCity.toLowerCase() == c.toLowerCase()
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setSheetState(() => tempCity = c);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Search Diameter (Radius):',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final km in _kRadiusOptions) ...[
                        ChoiceChip(
                          label: Text(km == 0 ? 'All' : '$km km'),
                          selected: tempRadius == km,
                          selectedColor: _kGold,
                          backgroundColor: _kCardBg,
                          labelStyle: TextStyle(
                            color: tempRadius == km ? _kBackground : Colors.white70,
                            fontWeight: tempRadius == km ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setSheetState(() => tempRadius = km);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final loc = LocationService.setManualLocation(tempCity);
                        setState(() {
                          _userLocation = loc;
                          _selectedRadius = tempRadius;
                        });
                        _loadListings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGold,
                        foregroundColor: _kBackground,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Show Rooms Near $tempCity',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredListings;
    final count = filtered.length;
    final locCity = _userLocation?.cityName ?? 'Your City';
    final locCountry = _userLocation?.countryName ?? '';

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
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
              'Find a Room',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined, color: _kGold),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const MapScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildLocationCard(locCity, locCountry),
            _buildRadiusChips(count),
            _buildStatusBanner(count),
            Expanded(
              child: _isLoadingListings
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(_kGold),
                      ),
                    )
                  : filtered.isEmpty
                      ? _buildEmptyState()
                      : _buildListingsGrid(filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(String city, String country) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kGold.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _kGold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: _isLoadingLocation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _kGold,
                      ),
                    )
                  : const Icon(Icons.location_on, color: _kGold, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Location',
                    style: TextStyle(color: _kMutedText, fontSize: 10.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    country.isNotEmpty ? '$city, $country' : city,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _openCitySelector,
              style: TextButton.styleFrom(
                foregroundColor: _kGold,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: _kGold.withValues(alpha: 0.4)),
                ),
              ),
              child: const Text(
                'Change City',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusChips(int totalCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Search Diameter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$totalCount rooms found',
                  style: const TextStyle(
                    color: _kGold,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final km in _kRadiusOptions) ...[
                Builder(builder: (c) {
                  final isSelected = _selectedRadius == km;
                  final chipCount = _listings.where((l) {
                    if (l.distanceKm == null) return false;
                    if (km == 0) return true;
                    return l.distanceKm! <= km;
                  }).length;
                  final label = km == 0 ? 'All' : '$km km';

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedRadius = km);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? _kGold : _kSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? _kGoldLight : _kBorder,
                          width: isSelected ? 1.4 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _kGold.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.track_changes,
                            size: 12,
                            color: isSelected ? _kBackground : _kGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? _kBackground : Colors.white,
                              fontSize: 12,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _kBackground.withValues(alpha: 0.2)
                                  : _kGold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$chipCount',
                              style: TextStyle(
                                color: isSelected ? _kBackground : _kGold,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(int count) {
    final hasResults = count > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasResults
              ? _kGold.withValues(alpha: 0.08)
              : Colors.orange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasResults
                ? _kGold.withValues(alpha: 0.22)
                : Colors.orange.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasResults ? Icons.check_circle_outline : Icons.info_outline,
              color: hasResults ? _kGold : Colors.orangeAccent,
              size: 15,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasResults
                    ? 'Showing $count rooms within ${_selectedRadius == 0 ? 'all distances' : '$_selectedRadius km'}'
                    : 'No rooms within $_selectedRadius km. Try expanding to 50 km or 100 km.',
                style: TextStyle(
                  color: hasResults ? _kGoldLight : Colors.orangeAccent,
                  fontSize: 11,
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
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _kMaroonStart.withValues(alpha: 0.4),
                    _kSurface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: _kGold.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: _kGoldLight,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Rooms Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try expanding your search radius or pick a different city. New listings are added every day.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _kMutedText,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _openCitySelector,
              icon: const Icon(Icons.location_searching, color: _kGold, size: 16),
              label: const Text(
                'Change City or Radius',
                style: TextStyle(
                  color: _kGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingsGrid(List<Listing> items) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        return _buildListingCard(items[index]);
      },
    );
  }

  Widget _buildListingCard(Listing l) {
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
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: _kSurface,
                    child: l.imageUrl != null && l.imageUrl!.isNotEmpty
                        ? Image.network(
                            l.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  if (l.tag.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _kMaroonStart.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: _kGold.withValues(alpha: 0.4), width: 0.8),
                        ),
                        child: Text(
                          l.tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (l.isFeatured)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kGold,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Color(0xFF1A1717),
                          size: 11,
                        ),
                      ),
                    ),
                  if (l.distanceKm != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: _kGold.withValues(alpha: 0.35), width: 0.6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.pin_drop,
                                color: _kGold, size: 9),
                            const SizedBox(width: 3),
                            Text(
                              l.distanceKm! < 1
                                  ? '${(l.distanceKm! * 1000).toStringAsFixed(0)}m'
                                  : '${l.distanceKm!.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
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
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          color: _kMutedText, size: 10.5),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${l.city}${l.country != null && l.country!.isNotEmpty ? ', ${l.country}' : ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: _kMutedText, fontSize: 10.5),
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
                        l.rentDisplay,
                        style: const TextStyle(
                          color: _kGold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          l.period,
                          style: const TextStyle(
                            color: _kMutedText,
                            fontSize: 10,
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
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1919), Color(0xFF2A2626)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_work_outlined,
                color: _kGold.withValues(alpha: 0.35), size: 32),
            const SizedBox(height: 6),
            Text(
              'Roommate Finder',
              style: TextStyle(
                color: _kGold.withValues(alpha: 0.25),
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
