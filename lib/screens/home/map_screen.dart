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

enum MapStyle {
  english,
  streets,
  dark,
  satellite,
  local,
}

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
  MapStyle _mapStyle = MapStyle.english;
  bool _isNoListingsMinimized = false;
  bool _isBottomListMinimized = false;
  bool _isShowingFallbackAll = false;

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
      });
      if (_allListings.isNotEmpty) {
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
        if (listings.isNotEmpty) {
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
    if (_allListings.isEmpty) return;
    setState(() => _isLoadingMarkers = true);

    final double? userLat = _userLocation?.latitude;
    final double? userLng = _userLocation?.longitude;
    final List<Marker> userPins = [];

    if (userLat != null && userLng != null) {
      userPins.add(
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
    }

    final List<Listing> nearbyList = [];
    final List<Marker> nearbyMarkers = [];
    final List<Listing> allWithDist = [];
    final List<Marker> allListingMarkers = [];

    for (final listing in _allListings) {
      if (listing.city.isEmpty) continue;
      try {
        final geo = await LocationService.getCoordinatesForCity(listing.city);
        if (geo != null) {
          double? km;
          if (userLat != null && userLng != null) {
            km = LocationService.distanceKm(
              userLat,
              userLng,
              geo.latitude,
              geo.longitude,
            );
          }

          final listingWithDist =
              km != null ? listing.withDistance(km) : listing;
          allWithDist.add(listingWithDist);

          final marker = Marker(
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
          );

          allListingMarkers.add(marker);

          if (km != null && km <= _radiusKm) {
            nearbyList.add(listingWithDist);
            nearbyMarkers.add(marker);
          }
        }
      } catch (_) {}
    }

    if (userLat != null && userLng != null) {
      nearbyList
          .sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
      allWithDist
          .sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
    }

    final bool hasNearby = nearbyList.isNotEmpty;
    final List<Marker> finalMarkers = [];
    finalMarkers.addAll(userPins);

    if (hasNearby) {
      finalMarkers.addAll(nearbyMarkers);
    } else {
      // Fallback: Agar range me listings na hon tou jahan jahan listings hain sab map pe show karo
      finalMarkers.addAll(allListingMarkers);
    }

    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll(finalMarkers);
        _nearbyListings = hasNearby ? nearbyList : allWithDist;
        _isShowingFallbackAll = !hasNearby && allWithDist.isNotEmpty;
        _isLoadingMarkers = false;
      });

      if (hasNearby && userLat != null && userLng != null) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            _mapController.move(
              LatLng(userLat, userLng),
              11.0,
            );
          }
        });
      } else if (!hasNearby && allListingMarkers.isNotEmpty) {
        // Map camera ko listings wali location par move karo
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            final firstPoint = allListingMarkers.first.point;
            _mapController.move(
              LatLng(firstPoint.latitude, firstPoint.longitude),
              allListingMarkers.length > 1 ? 6.5 : 12.0,
            );
          }
        });
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
      _isNoListingsMinimized = false;
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

  TileLayer _buildTileLayer() {
    switch (_mapStyle) {
      case MapStyle.english:
        // CartoDB Voyager: 100% Free, Global English Names (No API key needed)
        return TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.example.roommate_finder',
          retinaMode: true,
          maxZoom: 19,
        );
      case MapStyle.streets:
        // Esri World Street Map: 100% Free, English Street Details
        return TileLayer(
          urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.example.roommate_finder',
          maxZoom: 19,
        );
      case MapStyle.dark:
        // CartoDB Dark Matter: 100% Free, English Labels Dark Theme
        return TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.example.roommate_finder',
          retinaMode: true,
          maxZoom: 19,
        );
      case MapStyle.satellite:
        // Esri World Imagery: 100% Free Aerial Satellite View
        return TileLayer(
          urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.example.roommate_finder',
          maxZoom: 19,
        );
      case MapStyle.local:
        // OpenStreetMap Standard: Local language script
        return TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.roommate_finder',
          maxZoom: 19,
        );
    }
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
        minZoom: 3.0,
        maxZoom: 19.0,
      ),
      children: [
        _buildTileLayer(),
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
                      )
                    else
                      const Text(
                        '📍 All listings view',
                        style: TextStyle(color: _kGoldLight, fontSize: 11),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _showMapStyleSheet,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _kGold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.layers_outlined,
                      color: _kGold, size: 20),
                ),
              ),
              const SizedBox(width: 8),
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

  void _showMapStyleSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
            const Row(
              children: [
                Icon(Icons.map, color: _kGold, size: 20),
                SizedBox(width: 8),
                Text(
                  'Choose Free Map Layer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Select any free map provider (No API key required)',
              style: TextStyle(color: _kMutedText, fontSize: 12),
            ),
            const SizedBox(height: 16),
            _buildStyleTile(
              style: MapStyle.english,
              title: 'English Map (Default)',
              subtitle: 'Free OSM map with global English labels (CartoDB Voyager)',
              icon: Icons.language,
            ),
            _buildStyleTile(
              style: MapStyle.streets,
              title: 'English Streets (Esri)',
              subtitle: 'Free high-res English streets & city details',
              icon: Icons.alt_route,
            ),
            _buildStyleTile(
              style: MapStyle.dark,
              title: 'Dark Mode (CartoDB)',
              subtitle: 'Free sleek dark-mode map with English labels',
              icon: Icons.dark_mode,
            ),
            _buildStyleTile(
              style: MapStyle.satellite,
              title: 'Satellite Imagery (Esri)',
              subtitle: 'Free aerial satellite view',
              icon: Icons.satellite_alt,
            ),
            _buildStyleTile(
              style: MapStyle.local,
              title: 'OpenStreetMap (Local Names)',
              subtitle: 'Standard OSM with local script (Urdu/Regional)',
              icon: Icons.public,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleTile({
    required MapStyle style,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _mapStyle == style;
    return GestureDetector(
      onTap: () {
        setState(() => _mapStyle = style);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? _kGold.withValues(alpha: 0.15) : _kCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _kGold : _kBorder,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? _kGold : _kMutedText, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? _kGoldLight : Colors.white,
                      fontSize: 13.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _kMutedText, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: _kGold, size: 18),
          ],
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
      if (_isNoListingsMinimized) {
        return Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _isNoListingsMinimized = false),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _kSurface.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: _kBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_off_outlined,
                            color: _kGold, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'No listings found',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.keyboard_arrow_up_rounded,
                              color: Colors.white70, size: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      return Positioned(
        bottom: 20,
        left: 14,
        right: 14,
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 60),
                    const Center(
                      child: Icon(Icons.location_off,
                          color: _kGold, size: 30),
                    ),
                    InkWell(
                      onTap: () =>
                          setState(() => _isNoListingsMinimized = true),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: _kBorder.withOpacity(0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Minimize',
                              style: TextStyle(
                                  color: _kMutedText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                color: _kMutedText, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'No listings found',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'No listings exist in the database yet.',
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: _isBottomListMinimized ? 56 : 200,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(
                    () => _isBottomListMinimized = !_isBottomListMinimized),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: Padding(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isShowingFallbackAll
                                  ? '${_nearbyListings.length} Listings (All Locations)'
                                  : '${_nearbyListings.length} Nearby Listings',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_isShowingFallbackAll)
                              Text(
                                _userLocation != null
                                    ? 'None within ${_radiusKm}km • Showing across map'
                                    : 'Showing all available listings on map',
                                style: const TextStyle(
                                  color: _kGold,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        _isBottomListMinimized
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: _kMutedText,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (!_isBottomListMinimized) ...[
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
                        isSelected: _selectedListing?.id == l.id,
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
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onFocus;

  const _NearbyListItem({
    required this.listing,
    this.isSelected = false,
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
          color: isSelected ? _kGold.withValues(alpha: 0.08) : _kCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _kGold : _kBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
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
