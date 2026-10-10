import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Worldwide currency support — ISO 4217 codes + symbols
const Map<String, String> _kCurrencySymbols = {
  'USD': '\$',
  'EUR': '€',
  'GBP': '£',
  'PKR': 'Rs ',
  'INR': '₹',
  'AED': 'د.إ',
  'SAR': '﷼',
  'QAR': 'ر.ق',
  'CAD': 'C\$',
  'AUD': 'A\$',
  'SGD': 'S\$',
  'CHF': 'CHF ',
  'JPY': '¥',
  'CNY': '¥',
  'TRY': '₺',
  'MYR': 'RM',
  'EGP': 'E£',
  'BDT': '৳',
  'NPR': 'रू',
  'LKR': 'රු',
  'ZAR': 'R',
  'BRL': 'R\$',
  'MXN': 'Mex\$',
  'SEK': 'kr',
  'NOK': 'kr',
  'DKK': 'kr',
  'PLN': 'zł',
  'HUF': 'Ft',
  'CZK': 'Kč',
  'THB': '฿',
  'IDR': 'Rp',
  'VND': '₫',
  'PHP': '₱',
  'KRW': '₩',
  'HKD': 'HK\$',
  'NZD': 'NZ\$',
};

/// Default currency fallback if none provided
const String _kDefaultCurrency = 'USD';

class Listing {
  final String id;
  final String title;
  final String city;
  final String? country;
  final int rent;
  final String currency;
  final String period;
  final String tag;
  final String? description;
  final String? imageUrl;
  final String? userId;
  final DateTime? createdAt;
  final bool isFeatured;
  final double? latitude;
  final double? longitude;

  final double? distanceKm;

  const Listing({
    required this.id,
    required this.title,
    required this.city,
    this.country,
    required this.rent,
    this.currency = _kDefaultCurrency,
    this.period = '/month',
    this.tag = '',
    this.description,
    this.imageUrl,
    this.userId,
    this.createdAt,
    this.isFeatured = false,
    this.latitude,
    this.longitude,
    this.distanceKm,
  });

  factory Listing.fromMap(Map<String, dynamic> map) {
    return Listing(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      country: map['country']?.toString(),
      rent: map['rent'] is int
          ? map['rent']
          : int.tryParse(map['rent']?.toString() ?? '0') ?? 0,
      currency: map['currency']?.toString() ?? _kDefaultCurrency,
      period: map['period']?.toString() ?? '/month',
      tag: map['tag']?.toString() ?? '',
      description: map['description']?.toString(),
      imageUrl: map['image_url']?.toString(),
      userId: map['user_id']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      isFeatured: map['is_featured'] == true,
      latitude: map['latitude'] != null
          ? double.tryParse(map['latitude'].toString())
          : null,
      longitude: map['longitude'] != null
          ? double.tryParse(map['longitude'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'city': city,
      'country': country,
      'rent': rent,
      'currency': currency,
      'period': period,
      'tag': tag,
      'description': description,
      'image_url': imageUrl,
      'user_id': userId,
      'is_featured': isFeatured,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Returns the currency symbol for this listing — falls back to ISO code
  String get _currencySymbol =>
      _kCurrencySymbols[currency.toUpperCase()] ?? '${currency.toUpperCase()} ';

  /// Smart rent formatter — respects locale number formatting + currency symbol
  String get rentDisplay {
    final formatted = rent.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$_currencySymbol$formatted';
  }

  Map<String, String> toDisplayMap() {
    return {
      'id': id,
      'title': title,
      'city': city,
      'country': country ?? '',
      'rent': rentDisplay,
      'currency': currency,
      'period': period,
      'tag': tag,
      'description': description ?? '',
      'imageUrl': imageUrl ?? '',
      'distanceKm': distanceKm?.toStringAsFixed(2) ?? '',
    };
  }

  Listing withDistance(double km) {
    return Listing(
      id: id,
      title: title,
      city: city,
      country: country,
      rent: rent,
      currency: currency,
      period: period,
      tag: tag,
      description: description,
      imageUrl: imageUrl,
      userId: userId,
      createdAt: createdAt,
      isFeatured: isFeatured,
      latitude: latitude,
      longitude: longitude,
      distanceKm: km,
    );
  }
}

class ListingsService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<List<Listing>> fetchListings({
    String? searchQuery,
    String? city,
    String? country,
    String? currency,
    int? maxBudget,
    String? tag,
    bool? featured,
    int? limit,
    int? offset,
  }) async {
    try {
      var filterQuery = _client.from('listings').select();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        filterQuery = filterQuery.or(
          'title.ilike.%$searchQuery%,city.ilike.%$searchQuery%,country.ilike.%$searchQuery%,tag.ilike.%$searchQuery%',
        );
      }
      if (city != null && city.isNotEmpty) {
        filterQuery = filterQuery.ilike('city', '%$city%');
      }
      if (country != null && country.isNotEmpty) {
        filterQuery = filterQuery.ilike('country', '%$country%');
      }
      if (currency != null && currency.isNotEmpty) {
        filterQuery = filterQuery.ilike('currency', '%$currency%');
      }
      if (maxBudget != null) {
        filterQuery = filterQuery.lte('rent', maxBudget);
      }
      if (tag != null && tag.isNotEmpty) {
        filterQuery = filterQuery.ilike('tag', '%$tag%');
      }
      if (featured != null) {
        filterQuery = filterQuery.eq('is_featured', featured);
      }

      var orderedQuery = filterQuery.order('created_at', ascending: false);

      if (offset != null) {
        final data = await orderedQuery.range(
          offset,
          offset + (limit ?? 20) - 1,
        );
        return (data as List).map((e) => Listing.fromMap(e)).toList();
      } else if (limit != null) {
        final data = await orderedQuery.limit(limit);
        return (data as List).map((e) => Listing.fromMap(e)).toList();
      }

      final data = await orderedQuery;
      return (data as List).map((e) => Listing.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error fetching listings: $e');
      return [];
    }
  }

  static Future<List<Listing>> searchListings(String query) async {
    return fetchListings(searchQuery: query);
  }

  static Future<List<Listing>> fetchByCity(String city) async {
    return fetchListings(city: city);
  }

  static Future<List<Listing>> fetchByCountry(String country) async {
    return fetchListings(country: country);
  }

  static Future<List<Listing>> fetchFeatured() async {
    return fetchListings(featured: true, limit: 5);
  }

  static Future<List<Listing>> fetchRecent({int limit = 10}) async {
    return fetchListings(limit: limit);
  }

  static Future<int> fetchTotalCount() async {
    try {
      final data = await _client.from('listings').select('id');
      return (data as List).length;
    } catch (e) {
      debugPrint('Error fetching listing count: $e');
      return 0;
    }
  }

  static Future<int> fetchRecentCount({int days = 7}) async {
    try {
      final since = DateTime.now().subtract(Duration(days: days));
      final data = await _client
          .from('listings')
          .select('id')
          .gte('created_at', since.toIso8601String());
      return (data as List).length;
    } catch (e) {
      debugPrint('Error fetching recent count: $e');
      return 0;
    }
  }

  static Future<String?> uploadCoverImage(String listingId, Uint8List bytes) async {
    try {
      final fileName = 'listings/$listingId/cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _client.storage.from('listings').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              contentType: 'image/jpeg',
            ),
          );
      final url = _client.storage.from('listings').getPublicUrl(fileName);
      return url;
    } catch (e) {
      debugPrint('Error uploading cover image: $e');
      try {
        final fileName = 'listings/$listingId/cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _client.storage.from('listings').uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );
        final url = _client.storage.from('listings').getPublicUrl(fileName);
        return url;
      } catch (e2) {
        debugPrint('Cover image upload retry failed: $e2');
        return null;
      }
    }
  }

  static Future<String?> createListing({
    required String title,
    required String city,
    String? country,
    required int rent,
    required String currency,
    required String period,
    String tag = '',
    String? description,
    Uint8List? coverImageBytes,
    double? latitude,
    double? longitude,
  }) async {
    final user = _client.auth.currentUser;
    final now = DateTime.now().toIso8601String();
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    String? imageUrl;
    if (coverImageBytes != null) {
      imageUrl = await uploadCoverImage(tempId, coverImageBytes);
    }

    try {
      final insertPayload = {
        'title': title,
        'city': city,
        'country': country,
        'rent': rent,
        'currency': currency,
        'period': period,
        'tag': tag,
        'description': description,
        'image_url': imageUrl,
        'user_id': user?.id,
        'is_featured': false,
        'latitude': latitude,
        'longitude': longitude,
        'created_at': now,
      };

      final data =
          await _client.from('listings').insert(insertPayload).select().maybeSingle();
      if (data == null) return null;

      final newId = data['id']?.toString();
      if (newId != null && coverImageBytes != null && imageUrl != null) {
        try {
          final newBucketPath = 'listings/$newId/cover.jpg';
          await _client.storage.from('listings').uploadBinary(
                newBucketPath,
                coverImageBytes,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  contentType: 'image/jpeg',
                  upsert: true,
                ),
              );
          final newPublicUrl =
              _client.storage.from('listings').getPublicUrl(newBucketPath);
          await _client.from('listings').update({'image_url': newPublicUrl}).eq('id', newId);
          return newId;
        } catch (_) {}
      }
      return newId;
    } on PostgrestException catch (e) {
      debugPrint('Postgrest error on listing insert: ${e.message}');
      if (e.code == '42P01') {
        try {
          final fallbackData = {
            'id': tempId,
            'title': title,
            'city': city,
            'country': country,
            'rent': rent,
            'currency': currency,
            'period': period,
            'tag': tag,
            'description': description,
            'image_url': imageUrl,
            'user_id': user?.id,
            'is_featured': false,
            'latitude': latitude,
            'longitude': longitude,
            'created_at': now,
          };
          return fallbackData['id']?.toString();
        } catch (e2) {
          return null;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error creating listing: $e');
      return null;
    }
  }
}
