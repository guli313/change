import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'favorite_listings';
  static List<String> _favoriteIds = [];
  static bool _loaded = false;

  static Future<void> init() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _favoriteIds = prefs.getStringList(_key) ?? [];
      _loaded = true;
    } catch (e) {
      debugPrint('Error loading favorites: $e');
      _favoriteIds = [];
      _loaded = true;
    }
  }

  static List<String> get favoriteIds => List.unmodifiable(_favoriteIds);

  static bool isFavorite(String listingId) {
    return _favoriteIds.contains(listingId);
  }

  static Future<void> toggleFavorite(String listingId) async {
    if (_favoriteIds.contains(listingId)) {
      _favoriteIds.remove(listingId);
    } else {
      _favoriteIds.add(listingId);
    }
    await _save();
  }

  static Future<void> addFavorite(String listingId) async {
    if (!_favoriteIds.contains(listingId)) {
      _favoriteIds.add(listingId);
      await _save();
    }
  }

  static Future<void> removeFavorite(String listingId) async {
    if (_favoriteIds.contains(listingId)) {
      _favoriteIds.remove(listingId);
      await _save();
    }
  }

  static Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _favoriteIds);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  static int get count => _favoriteIds.length;
}
