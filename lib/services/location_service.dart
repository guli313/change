import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// User ki current GPS position
class UserLocation {
  final double latitude;
  final double longitude;
  final String? cityName;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.cityName,
  });
}

/// City/address ko coordinates mein convert karne ke baad mila result
class GeoResult {
  final double latitude;
  final double longitude;

  const GeoResult({required this.latitude, required this.longitude});
}

class LocationService {
  static UserLocation? _cachedLocation;
  static DateTime? _lastFetch;

  // ── User ka GPS location lena ─────────────────────────────────────────────

  /// Device ka current GPS location return karta hai.
  /// Permission nahi hai to null return karega (crash nahi karega).
  static Future<UserLocation?> getCurrentLocation() async {
    // 30 second cache — baar baar GPS nahi uthana
    if (_cachedLocation != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < const Duration(seconds: 30)) {
      return _cachedLocation;
    }

    try {
      // Permission check
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      // GPS position lo
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Reverse geocode — lat/lng → city name
      String? city;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          city = p.locality ?? p.subAdministrativeArea ?? p.administrativeArea;
        }
      } catch (_) {
        // Geocoding fail hua to city null rahega — koi baat nahi
      }

      _cachedLocation = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: city,
      );
      _lastFetch = DateTime.now();
      return _cachedLocation;
    } catch (e) {
      debugPrint('LocationService: GPS error — $e');
      return null;
    }
  }

  /// Cache clear karo (refresh ke liye)
  static void clearCache() {
    _cachedLocation = null;
    _lastFetch = null;
  }

  // ── City name se coordinates lena ─────────────────────────────────────────

  /// "Lahore", "London" jaise city name ko lat/lng mein convert karta hai.
  /// Cache mein rakha jata hai taake baar baar geocoding na ho.
  static final Map<String, GeoResult?> _geoCache = {};

  static Future<GeoResult?> getCoordinatesForCity(String cityName) async {
    final key = cityName.trim().toLowerCase();
    if (_geoCache.containsKey(key)) return _geoCache[key];

    try {
      final locations = await locationFromAddress(cityName);
      if (locations.isEmpty) {
        _geoCache[key] = null;
        return null;
      }
      final result = GeoResult(
        latitude: locations.first.latitude,
        longitude: locations.first.longitude,
      );
      _geoCache[key] = result;
      return result;
    } catch (e) {
      debugPrint('LocationService: Geocoding failed for "$cityName" — $e');
      _geoCache[key] = null;
      return null;
    }
  }

  // ── Distance calculation (Haversine formula) ──────────────────────────────

  /// Do points ke beech ka distance kilometers mein return karta hai.
  /// Koi external package nahi — pure Dart math.
  static double distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0; // Earth radius km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _toRad(double deg) => deg * pi / 180;

  // ── Distance display string ────────────────────────────────────────────────

  /// 2.3 km → "2.3 km", 0.45 km → "450 m", 100+ km → "100+ km"
  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).round()} m';
    } else if (km >= 100) {
      return '100+ km';
    } else {
      return '${km.toStringAsFixed(1)} km';
    }
  }

  // ── Permission status check ────────────────────────────────────────────────

  static Future<bool> isPermissionGranted() async {
    final perm = await Geolocator.checkPermission();
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
