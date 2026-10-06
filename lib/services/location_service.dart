import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// User ki current GPS position
class UserLocation {
  final double latitude;
  final double longitude;
  final String? cityName;
  final String? countryName;
  final String? countryIsoCode;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.countryName,
    this.countryIsoCode,
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

  // ── Known Cities Static Coordinates Lookup ──────────────────────────────
  static const Map<String, GeoResult> _kKnownCityCoords = {
    // Pakistan
    'lahore': GeoResult(latitude: 31.5204, longitude: 74.3587),
    'karachi': GeoResult(latitude: 24.8607, longitude: 67.0011),
    'islamabad': GeoResult(latitude: 33.6844, longitude: 73.0479),
    'rawalpindi': GeoResult(latitude: 33.5651, longitude: 73.0169),
    'faisalabad': GeoResult(latitude: 31.4504, longitude: 73.1350),
    'multan': GeoResult(latitude: 30.1575, longitude: 71.5249),
    'peshawar': GeoResult(latitude: 34.0151, longitude: 71.5249),
    'quetta': GeoResult(latitude: 30.1798, longitude: 66.9750),
    'sialkot': GeoResult(latitude: 32.4945, longitude: 74.5229),
    'gujranwala': GeoResult(latitude: 32.1877, longitude: 74.1945),
    'sheikhupura': GeoResult(latitude: 31.7167, longitude: 73.9850),
    'kasur': GeoResult(latitude: 31.1179, longitude: 74.4461),
    'hyderabad': GeoResult(latitude: 25.3960, longitude: 68.3578),
    'bahawalpur': GeoResult(latitude: 29.3544, longitude: 71.6911),
    'sargodha': GeoResult(latitude: 32.0836, longitude: 72.6711),
    'abbottabad': GeoResult(latitude: 34.1688, longitude: 73.2215),
    'gujrat': GeoResult(latitude: 32.5742, longitude: 74.0754),
    'sukkur': GeoResult(latitude: 27.7052, longitude: 68.8574),
    // UK
    'london': GeoResult(latitude: 51.5074, longitude: -0.1278),
    'manchester': GeoResult(latitude: 53.4808, longitude: -2.2426),
    'birmingham': GeoResult(latitude: 52.4862, longitude: -1.8904),
    'leeds': GeoResult(latitude: 53.8008, longitude: -1.5491),
    'edinburgh': GeoResult(latitude: 55.9533, longitude: -3.1883),
    'sheffield': GeoResult(latitude: 53.3811, longitude: -1.4701),
    'nottingham': GeoResult(latitude: 52.9548, longitude: -1.1581),
    // USA & Others
    'new york': GeoResult(latitude: 40.7128, longitude: -74.0060),
    'los angeles': GeoResult(latitude: 34.0522, longitude: -118.2437),
    'chicago': GeoResult(latitude: 41.8781, longitude: -87.6298),
    'houston': GeoResult(latitude: 29.7604, longitude: -95.3698),
    'boston': GeoResult(latitude: 42.3601, longitude: -71.0589),
    'san francisco': GeoResult(latitude: 37.7749, longitude: -122.4194),
    'toronto': GeoResult(latitude: 43.6532, longitude: -79.3832),
    'vancouver': GeoResult(latitude: 49.2827, longitude: -123.1207),
    'dubai': GeoResult(latitude: 25.2048, longitude: 55.2708),
  };

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

      // Reverse geocode — lat/lng → city + country
      String? city;
      String? country;
      String? countryIso;
      try {
        if (!kIsWeb) {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            city = p.locality ?? p.subAdministrativeArea ?? p.administrativeArea;
            country = p.country;
            countryIso = p.isoCountryCode;
          }
        }
      } catch (_) {
        // Geocoding fail hua to city null rahega
      }

      // Free OpenStreetMap Nominatim Reverse Geocoding API
      if (city == null) {
        try {
          final uri = Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json',
          );
          final res = await http.get(uri, headers: {
            'User-Agent': 'RoommateFinderApp/1.0',
          }).timeout(const Duration(seconds: 4));
          if (res.statusCode == 200) {
            final Map<String, dynamic> data = jsonDecode(res.body);
            final address = data['address'] as Map<String, dynamic>?;
            if (address != null) {
              city = address['city']?.toString() ??
                  address['town']?.toString() ??
                  address['suburb']?.toString() ??
                  address['county']?.toString() ??
                  address['state']?.toString();
              country = address['country']?.toString();
              countryIso = address['country_code']?.toString();
            }
          }
        } catch (_) {}
      }

      // Web ya missing city fallback ke liye nearest known city dhundo
      if (city == null) {
        String? closestCity;
        double minDistance = double.infinity;
        for (final entry in _kKnownCityCoords.entries) {
          final d = distanceKm(
            position.latitude,
            position.longitude,
            entry.value.latitude,
            entry.value.longitude,
          );
          if (d < minDistance) {
            minDistance = d;
            closestCity = entry.key[0].toUpperCase() + entry.key.substring(1);
          }
        }
        if (minDistance <= 150 && closestCity != null) {
          city = closestCity;
          country ??= 'Pakistan';
        }
      }

      _cachedLocation = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: city,
        countryName: country,
        countryIsoCode: countryIso,
      );
      _lastFetch = DateTime.now();
      return _cachedLocation;
    } catch (e) {
      debugPrint('LocationService: GPS error — $e');
      return null;
    }
  }

  /// Manual ya fallback city set karne ke liye
  static UserLocation setManualLocation(
    String cityName, {
    double? lat,
    double? lng,
    String? country,
  }) {
    final key = cityName.trim().toLowerCase();
    GeoResult? match;
    for (final entry in _kKnownCityCoords.entries) {
      if (key == entry.key || key.contains(entry.key) || entry.key.contains(key)) {
        match = entry.value;
        break;
      }
    }
    final finalLat = lat ?? match?.latitude ?? 31.5204;
    final finalLng = lng ?? match?.longitude ?? 74.3587;
    final titleCity = cityName.isNotEmpty
        ? cityName[0].toUpperCase() + cityName.substring(1)
        : 'Lahore';
    _cachedLocation = UserLocation(
      latitude: finalLat,
      longitude: finalLng,
      cityName: titleCity,
      countryName: country ?? 'Pakistan',
    );
    _lastFetch = DateTime.now();
    return _cachedLocation!;
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

    // Known cities lookup
    for (final entry in _kKnownCityCoords.entries) {
      if (key == entry.key || key.contains(entry.key) || entry.key.contains(key)) {
        _geoCache[key] = entry.value;
        return entry.value;
      }
    }

    // Free OpenStreetMap Nominatim Geocoding API
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(cityName)}&format=json&limit=1',
      );
      final res = await http.get(uri, headers: {
        'User-Agent': 'RoommateFinderApp/1.0',
      }).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        if (data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat'].toString());
          final lon = double.tryParse(data[0]['lon'].toString());
          if (lat != null && lon != null) {
            final geo = GeoResult(latitude: lat, longitude: lon);
            _geoCache[key] = geo;
            return geo;
          }
        }
      }
    } catch (_) {}

    if (!kIsWeb) {
      try {
        final locations = await locationFromAddress(cityName);
        if (locations.isNotEmpty) {
          final result = GeoResult(
            latitude: locations.first.latitude,
            longitude: locations.first.longitude,
          );
          _geoCache[key] = result;
          return result;
        }
      } catch (e) {
        debugPrint('LocationService: Geocoding failed for "$cityName" — $e');
      }
    }

    _geoCache[key] = null;
    return null;
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
