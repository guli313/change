import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Listing {
  final String id;
  final String title;
  final String city;
  final int rent;
  final String period;
  final String tag;
  final String? description;
  final String? imageUrl;
  final String? userId;
  final DateTime? createdAt;
  final bool isFeatured;

  const Listing({
    required this.id,
    required this.title,
    required this.city,
    required this.rent,
    this.period = '/month',
    this.tag = '',
    this.description,
    this.imageUrl,
    this.userId,
    this.createdAt,
    this.isFeatured = false,
  });

  factory Listing.fromMap(Map<String, dynamic> map) {
    return Listing(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      rent: map['rent'] is int
          ? map['rent']
          : int.tryParse(map['rent']?.toString() ?? '0') ?? 0,
      period: map['period']?.toString() ?? '/month',
      tag: map['tag']?.toString() ?? '',
      description: map['description']?.toString(),
      imageUrl: map['image_url']?.toString(),
      userId: map['user_id']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      isFeatured: map['is_featured'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'city': city,
      'rent': rent,
      'period': period,
      'tag': tag,
      'description': description,
      'image_url': imageUrl,
      'user_id': userId,
      'is_featured': isFeatured,
    };
  }

  String get rentDisplay => 'PKR ${rent.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';

  Map<String, String> toDisplayMap() {
    return {
      'id': id,
      'title': title,
      'city': city,
      'rent': rentDisplay,
      'period': period,
      'tag': tag,
      'description': description ?? '',
      'imageUrl': imageUrl ?? '',
    };
  }
}

class ListingsService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<List<Listing>> fetchListings({
    String? searchQuery,
    String? city,
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
          'title.ilike.%$searchQuery%,city.ilike.%$searchQuery%,tag.ilike.%$searchQuery%',
        );
      }
      if (city != null && city.isNotEmpty) {
        filterQuery = filterQuery.ilike('city', '%$city%');
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
}
