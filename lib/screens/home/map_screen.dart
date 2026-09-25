import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../services/listings_service.dart';
import '../../services/location_service.dart';
import 'listing_detail_screen.dart';

const Color _kBackground = Color(0xFF0D0D0D);
const Color _kSurface = Color(0xFF1A1717);
const Color _kCardBg = Color(0xFF1C1919);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMaroonEnd = Color(0xFF4E1220);
const Color _kMutedText = Color(0xFF9B9B9B);
const Color _kBorder = Color(0xFF2A2626);

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  UserLocation? _userLocation;
  List<Listing> _allListings = [];
  List<Listing> _nearbyListings = [];
  final List<Marker> _markers = [];

  bool _isLoadingLocation = true;
  bool _isLoadingListings = true;
  bool _isLoadingMarkers = false;
  String? _errorMessage;

  Listing? _selectedListing;
  int _radiusKm = 50;
  final List<int> _radiusOptions = [5, 10, 20, 50, 100, 200];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await Future.wait([_loadLocation(), _loadListings()]);
  }

  Future<void> _loadLocation() async {
    setState(() => _isLoadingLocation = true);
    final loc = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _userLocation = loc;
        _isLoadingLocation = false;
        if (loc == null) {
          _errorMessage = 'Location permission denied. Enable GPS to use map.';
        }
      });
      if (_allListings.isNotEmpty && loc != null) {
        _computeDistancesAndBuildMarkers();
      }
    }
  }

  Future<void> _loadListings() async {
    setState(() => _isLoadingListings = true);
    try {
      final listings = await ListingsService.fetchListings(limit: 100);
      if (mounted) {
        setState(() {
          _allListings = listings;
          _isLoadingListings = false;
        });
        if (_userLocation != null && listings.isNotEmpty) {
          _computeDistancesAndBuildMarkers();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingListings = false;
          _errorMessage = 'Failed to load listings.';
        });
      }
    }
  }

  Future<void> _computeDistancesAndBuildMarkers() async {
    if (_userLocation == null || _allListings.isEmpty) return;
    setState(() => _isLoadingMarkers = true);

    final userLat = _userLocation!.latitude;
    final userLng = _userLocation!.longitude;
    final List<Marker> markers = [];
    final List<Listing> nearby = [];

    markers.add(
      Marker(
        point: LatLng(userLat, userLng),
        width: 80,
        height: 80,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _UserLocationPin(),
          ],
        ),
      ),
    );

    for (final listing in _allListings) {
      if (listing.city.isEmpty) continue;
      try {
        final geo = await LocationService.getCoordinatesForCity(listing.city);
        if (geo != null) {
          final km = LocationService.distanceKm(
            userLat,
            userLng,
            geo.latitude,
            geo.longitude,
          );

          final listingWithDist = listing.withDistance(km);

          if (km <= _radiusKm) {
            nearby.add(listingWithDist);
            markers.add(
              Marker(
                point: LatLng(geo.latitude, geo.longitude),
                width: 70,
                height: 70,
                child: _ListingMarker(
                  listing: listingWithDist,
                  onTap: () {
                    setState(() => _selectedListing = listingWithDist);
                    _showListingSheet(listingWithDist);
                  },
                ),
              ),
            );
          }
        }
      } catch (_) {}
    }

    nearby.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));

    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll(markers);
        _nearbyListings = nearby;
        _isLoadingMarkers = false;
      });

      if (nearby.isNotEmpty && nearby.first.distanceKm != null) {
        final firstGeo =
            await LocationService.getCoordinatesForCity(nearby.first.city);
        if (firstGeo != null) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              _mapController.move(
                LatLng(userLat, userLng),
                11.0,
              );
            }
          });
        }
      }
    }
  }

  void _showListingSheet(Listing listing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ListingBottomSheet(listing: listing),
    );
  }

  void _onRadiusChanged(int? value) {
    if (value == null) return;
    setState(() {
      _radiusKm = value;
      _selectedListing = null;
    });
    _computeDistancesAndBuildMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      body: Stack(
        children: [
          _buildMap(),
          _buildTopBar(),
          _buildRadiusChips(),
          _buildBottomList(),
          if (_isLoadingMarkers) _buildLoadingOverlay(),
          if (_errorMessage != null && !_isLoadingLocation && !_isLoadingListings)
            _buildErrorWidget(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    LatLng center = const LatLng(31.5204, 74.3587);
    double zoom = 10.0;

    if (_userLocation != null) {
      center = LatLng(_userLocation!.latitude, _userLocation!.longitude);
      zoom = 11.5;
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        minZoom: 5.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.example.roommate_finder',
          retinaMode: true,
        ),
        if (_userLocation != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: LatLng(
                  _userLocation!.latitude,
                  _userLocation!.longitude,
                ),
                radius: _radiusKm * 1000.0,
                color: _kGold.withValues(alpha: 0.08),
                borderColor: _kGold.withValues(alpha: 0.4),
                borderStrokeWidth: 2,
              ),
            ],
          ),
        MarkerLayer(markers: _markers),
      ],
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: _kGold, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find Nearby on Map',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_isLoadingLocation)
                      const Text(
                        'Detecting location...',
                        style: TextStyle(color: _kMutedText, fontSize: 11),
                      )
                    else if (_userLocation?.cityName != null)
                      Text(
                        '📍 ${_userLocation!.cityName}',
                        style:
                            const TextStyle(color: _kGoldLight, fontSize: 11),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _loadLocation,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _kGold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location,
                      color: _kGold, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadiusChips() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _radiusOptions.length,
            itemBuilder: (ctx, i) {
              final r = _radiusOptions[i];
              final selected = _radiusKm == r;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(
                    '$r km',
                    style: TextStyle(
                      color: selected ? _kBackground : Colors.white70,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  selected: selected,
                  selectedColor: _kGold,
                  backgroundColor: _kSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side:
                        BorderSide(color: selected ? _kGold : _kBorder),
                  ),
                  onSelected: (_) => _onRadiusChanged(r),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBottomList() {
    if (_isLoadingListings || _isLoadingMarkers) {
      return const SizedBox.shrink();
    }
    if (_nearbyListings.isEmpty) {
      return Positioned(
        bottom: 20,
        left: 14,
        right: 14,
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off, color: _kMutedText, size: 32),
                const SizedBox(height: 10),
                const Text(
                  'No listings found within range',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Try increasing the radius or check later.',
                  style: TextStyle(color: _kMutedText, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 200,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kGold, _kGoldLight],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_nearbyListings.length} Nearby Listings',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.drag_handle, color: _kMutedText, size: 20),
                  ],
                ),
              ),
              const Divider(color: _kBorder, height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  itemCount: _nearbyListings.length,
                  itemBuilder: (ctx, i) {
                    final l = _nearbyListings[i];
                    return _NearbyListItem(
                      listing: l,
                      onTap: () => _showListingSheet(l),
                      onFocus: () async {
                        final geo =
                            await LocationService.getCoordinatesForCity(
                                l.city);
                        if (geo != null && mounted) {
                          _mapController.move(
                            LatLng(geo.latitude, geo.longitude),
                            14.0,
                          );
                          setState(() => _selectedListing = l);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _kGold),
              SizedBox(height: 12),
              Text(
                'Finding rooms near you...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Positioned.fill(
      child: Container(
        color: _kBackground.withValues(alpha: 0.95),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: _kGold, size: 64),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _errorMessage = null);
                _initData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGold,
                foregroundColor: _kBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserLocationPin extends StatelessWidget {
  const _UserLocationPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _kGold,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.person, color: _kBackground, size: 18),
    );
  }
}

class _ListingMarker extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;

  const _ListingMarker({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rent = listing.rentDisplay;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kMaroonStart, _kMaroonEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _kGold.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              rent,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 0,
            height: 0,
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.transparent, width: 6),
                right: BorderSide(color: Colors.transparent, width: 6),
                top: BorderSide(color: _kMaroonEnd, width: 8),
              ),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _kGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyListItem extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final VoidCallback onFocus;

  const _NearbyListItem({
    required this.listing,
    required this.onTap,
    required this.onFocus,
  });

  @override
  Widget build(BuildContext context) {
    final km = listing.distanceKm;
    final distStr = km != null ? LocationService.formatDistance(km) : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _kCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kGold, _kGoldLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.home_outlined,
                  color: _kBackground, size: 24),
            ),
            const SizedBox(width: 10),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 11, color: _kGold),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          listing.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: _kMutedText, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  listing.rentDisplay,
                  style: const TextStyle(
                    color: _kGoldLight,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (distStr.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          distStr,
                          style: const TextStyle(
                            color: _kGold,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onFocus,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _kSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _kBorder),
                        ),
                        child: const Icon(Icons.center_focus_strong,
                            color: _kGold, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingBottomSheet extends StatelessWidget {
  final Listing listing;

  const _ListingBottomSheet({required this.listing});

  @override
  Widget build(BuildContext context) {
    final km = listing.distanceKm;
    final distStr = km != null ? LocationService.formatDistance(km) : '';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kMaroonStart, _kMaroonEnd],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child:
                    const Icon(Icons.home_outlined, color: _kGold, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 13, color: _kGold),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.city,
                            style: const TextStyle(
                                color: _kMutedText, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kGold, _kGoldLight],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  listing.rentDisplay,
                  style: const TextStyle(
                    color: _kBackground,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (listing.tag.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kMaroonStart.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kMaroonStart),
                  ),
                  child: Text(
                    listing.tag,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              const SizedBox(width: 10),
              if (distStr.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.near_me,
                          color: _kGold, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        distStr,
                        style: const TextStyle(
                            color: _kGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (listing.description != null &&
              listing.description!.isNotEmpty) ...[
            const Text(
              'Description',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              listing.description!,
              style: TextStyle(color: _kMutedText, fontSize: 13),
            ),
            const SizedBox(height: 18),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.favorite_border, color: _kGold),
                  label: const Text('Save'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kGold,
                    side: const BorderSide(color: _kGold),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListingDetailScreen(
                          listingData: listing.toDisplayMap(),
                          listingId: listing.id,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility, color: _kBackground),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGold,
                    foregroundColor: _kBackground,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
