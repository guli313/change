import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import 'user_approval_service.dart';

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

  // Admin Approval & Moderation fields
  final String status; // 'pending' | 'approved' | 'rejected'
  final bool isApproved;
  final String? hostName;
  final String? hostPhone;
  final String? hostEmail;
  final String? roomType;
  final String? rejectionReason;
  final String? submittedAt;

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
    this.status = 'approved',
    this.isApproved = true,
    this.hostName,
    this.hostPhone,
    this.hostEmail,
    this.roomType,
    this.rejectionReason,
    this.submittedAt,
  });

  factory Listing.fromMap(Map<String, dynamic> map) {
    final rawStatus = map['status']?.toString().toLowerCase();
    final rawApprovalStatus = map['approval_status']?.toString().toLowerCase();
    final bool rawIsApproved = map['is_approved'] is bool
        ? map['is_approved'] as bool
        : (map['is_approved']?.toString() == 'true');

    String resolvedStatus;
    bool resolvedIsApproved;

    if (rawStatus == 'rejected' || rawApprovalStatus == 'rejected') {
      resolvedStatus = 'rejected';
      resolvedIsApproved = false;
    } else if (rawStatus == 'pending' ||
        rawApprovalStatus == 'pending' ||
        rawIsApproved == false) {
      resolvedStatus = 'pending';
      resolvedIsApproved = false;
    } else if (rawStatus == 'approved' ||
        rawApprovalStatus == 'approved' ||
        rawIsApproved == true) {
      resolvedStatus = 'approved';
      resolvedIsApproved = true;
    } else {
      // Legacy records in database without approval status are considered approved
      resolvedStatus = 'approved';
      resolvedIsApproved = true;
    }

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
      imageUrl: map['image_url']?.toString() ?? map['imageUrl']?.toString(),
      userId: map['user_id']?.toString() ?? map['userId']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      isFeatured: map['is_featured'] == true || map['isFeatured'] == true,
      latitude: map['latitude'] != null
          ? double.tryParse(map['latitude'].toString())
          : null,
      longitude: map['longitude'] != null
          ? double.tryParse(map['longitude'].toString())
          : null,
      status: resolvedStatus,
      isApproved: resolvedIsApproved,
      hostName: map['host_name']?.toString() ?? map['hostName']?.toString(),
      hostPhone: map['host_phone']?.toString() ?? map['hostPhone']?.toString(),
      hostEmail: map['host_email']?.toString() ?? map['hostEmail']?.toString(),
      roomType: map['room_type']?.toString() ?? map['roomType']?.toString(),
      rejectionReason:
          map['rejection_reason']?.toString() ?? map['rejectionReason']?.toString(),
      submittedAt:
          map['submitted_at']?.toString() ?? map['submittedAt']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      'status': status,
      'is_approved': isApproved,
      'host_name': hostName,
      'host_phone': hostPhone,
      'host_email': hostEmail,
      'room_type': roomType,
      'rejection_reason': rejectionReason,
      'submitted_at': submittedAt,
      'created_at': createdAt?.toIso8601String(),
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
      'status': status,
      'isApproved': isApproved.toString(),
      'hostName': hostName ?? '',
      'hostPhone': hostPhone ?? '',
      'hostEmail': hostEmail ?? '',
      'roomType': roomType ?? '',
      'rejectionReason': rejectionReason ?? '',
      'submittedAt': submittedAt ?? '',
      'userId': userId ?? '',
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
      status: status,
      isApproved: isApproved,
      hostName: hostName,
      hostPhone: hostPhone,
      hostEmail: hostEmail,
      roomType: roomType,
      rejectionReason: rejectionReason,
      submittedAt: submittedAt,
    );
  }
}

class ListingsService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Local persistent storage keys for moderation
  static const String _kPendingRoomsKey = 'pending_room_listings_v2';
  static const String _kApprovedRoomIdsKey = 'approved_room_ids_v2';
  static const String _kRejectedRoomsKey = 'rejected_room_listings_v2';
  static const String _kCustomRoomListingsKey = 'custom_room_listings_v2';
  static const String _kRequireApprovalSettingKey = 'setting_require_listing_approval';

  /// Check whether Admin approval is globally required for new room listings (default: true)
  static Future<bool> isApprovalRequired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kRequireApprovalSettingKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Update the Admin approval requirement toggle
  static Future<void> setApprovalRequired(bool required) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kRequireApprovalSettingKey, required);
    } catch (_) {}
  }

  /// Fetches listings. By default [approvedOnly] is true so normal users only see approved rooms.
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
    bool approvedOnly = true,
    String? statusFilter,
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

      List<dynamic> data;
      if (offset != null) {
        data = await orderedQuery.range(
          offset,
          offset + (limit ?? 20) - 1,
        );
      } else if (limit != null) {
        data = await orderedQuery.limit(limit);
      } else {
        data = await orderedQuery;
      }

      List<Listing> listings =
          (data as List).map((e) => Listing.fromMap(e)).toList();

      // Merge local persistent custom listings (offline/demo fallback)
      try {
        final prefs = await SharedPreferences.getInstance();
        final rawCustom = prefs.getString(_kCustomRoomListingsKey);
        if (rawCustom != null && rawCustom.isNotEmpty) {
          final decoded = jsonDecode(rawCustom);
          if (decoded is List) {
            for (final c in decoded) {
              if (c is Map) {
                final customListing =
                    Listing.fromMap(Map<String, dynamic>.from(c));
                final existingIndex =
                    listings.indexWhere((l) => l.id == customListing.id);
                if (existingIndex >= 0) {
                  // Keep newest status from local storage
                  listings[existingIndex] = customListing;
                } else {
                  listings.insert(0, customListing);
                }
              }
            }
          }
        }
      } catch (_) {}

      // Apply approval filter
      if (approvedOnly) {
        listings =
            listings.where((l) => l.status == 'approved' && l.isApproved).toList();
      } else if (statusFilter != null &&
          statusFilter.isNotEmpty &&
          statusFilter.toLowerCase() != 'all') {
        listings = listings
            .where((l) =>
                l.status.toLowerCase() == statusFilter.toLowerCase())
            .toList();
      }

      return listings;
    } catch (e) {
      debugPrint('Error fetching listings: $e');
      // Offline fallback: load from local storage
      try {
        final prefs = await SharedPreferences.getInstance();
        final rawCustom = prefs.getString(_kCustomRoomListingsKey);
        if (rawCustom != null && rawCustom.isNotEmpty) {
          final decoded = jsonDecode(rawCustom);
          if (decoded is List) {
            var list = decoded
                .map((e) => Listing.fromMap(Map<String, dynamic>.from(e)))
                .toList();
            if (approvedOnly) {
              list =
                  list.where((l) => l.status == 'approved' && l.isApproved).toList();
            }
            return list;
          }
        }
      } catch (_) {}
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

  /// Fetches all listings for a host including pending and rejected so the host can track status
  static Future<List<Listing>> fetchHostListings(String userId) async {
    final all = await fetchListings(approvedOnly: false, limit: 100);
    final userListings = all.where((l) => l.userId == userId).toList()
      ..sort((a, b) {
        final da = a.createdAt ?? DateTime(2000);
        final db = b.createdAt ?? DateTime(2000);
        return db.compareTo(da);
      });
    return userListings;
  }

  /// Fetches all room listings awaiting Admin approval
  static Future<List<Listing>> fetchPendingListings() async {
    final List<Listing> results = [];
    final Set<String> seenIds = {};

    // 1. Read from SharedPreferences local queue
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPendingRoomsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              final listing = Listing.fromMap(Map<String, dynamic>.from(item));
              if (listing.status == 'pending' && seenIds.add(listing.id)) {
                results.add(listing);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('fetchPendingListings local error: $e');
    }

    // 2. Query Supabase listings table for pending items
    try {
      final data = await _client
          .from('listings')
          .select()
          .or('status.eq.pending,approval_status.eq.pending,is_approved.eq.false')
          .order('created_at', ascending: false);

      if (data is List) {
        for (final item in data) {
          final listing = Listing.fromMap(Map<String, dynamic>.from(item));
          if (seenIds.add(listing.id)) {
            results.add(listing);
          }
        }
      }
    } catch (_) {
      // Supabase table may not have approval columns yet
    }

    return results;
  }

  /// Admin approves a room listing — publishes it live
  static Future<bool> approveListing(String listingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Remove from local pending list
      final rawPending = prefs.getString(_kPendingRoomsKey);
      Listing? approvedListing;
      if (rawPending != null && rawPending.isNotEmpty) {
        final decoded = jsonDecode(rawPending);
        if (decoded is List) {
          final list =
              decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          final index =
              list.indexWhere((item) => item['id']?.toString() == listingId);
          if (index != -1) {
            final item = list[index];
            item['status'] = 'approved';
            item['is_approved'] = true;
            approvedListing = Listing.fromMap(item);
            list.removeAt(index);
            await prefs.setString(_kPendingRoomsKey, jsonEncode(list));
          }
        }
      }

      // 2. Add to approved IDs list
      final approvedIds = prefs.getStringList(_kApprovedRoomIdsKey) ?? [];
      if (!approvedIds.contains(listingId)) {
        approvedIds.add(listingId);
        await prefs.setStringList(_kApprovedRoomIdsKey, approvedIds);
      }

      // 3. Remove from rejected list
      final rawRejected = prefs.getString(_kRejectedRoomsKey);
      if (rawRejected != null && rawRejected.isNotEmpty) {
        final decoded = jsonDecode(rawRejected);
        if (decoded is List) {
          final list =
              decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          list.removeWhere((item) => item['id']?.toString() == listingId);
          await prefs.setString(_kRejectedRoomsKey, jsonEncode(list));
        }
      }

      // 4. Update in custom listings registry
      final rawCustom = prefs.getString(_kCustomRoomListingsKey);
      if (rawCustom != null && rawCustom.isNotEmpty) {
        final decoded = jsonDecode(rawCustom);
        if (decoded is List) {
          final list =
              decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          for (final item in list) {
            if (item['id']?.toString() == listingId) {
              item['status'] = 'approved';
              item['is_approved'] = true;
            }
          }
          await prefs.setString(_kCustomRoomListingsKey, jsonEncode(list));
        }
      }

      // 5. Update Supabase
      try {
        await _client
            .from('listings')
            .update({'status': 'approved', 'is_approved': true})
            .eq('id', listingId);
      } catch (e) {
        debugPrint('approveListing Supabase update error: $e');
      }

      // 6. Notify user
      final title = approvedListing?.title ?? 'Room Listing';
      NotificationService.addNotification(
        title: 'Listing Approved & Live!',
        subtitle: title,
        body:
            'Great news! The administrator has approved your room listing. It is now live and visible to all users.',
      );

      return true;
    } catch (e) {
      debugPrint('approveListing error: $e');
      return false;
    }
  }

  /// Admin rejects a room listing
  static Future<bool> rejectListing(String listingId, {String? reason}) async {
    final effectiveReason = reason ?? 'Does not comply with community guidelines';
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Remove from pending list
      final rawPending = prefs.getString(_kPendingRoomsKey);
      Listing? rejectedListing;
      if (rawPending != null && rawPending.isNotEmpty) {
        final decoded = jsonDecode(rawPending);
        if (decoded is List) {
          final list =
              decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          final index =
              list.indexWhere((item) => item['id']?.toString() == listingId);
          if (index != -1) {
            final item = list[index];
            item['status'] = 'rejected';
            item['is_approved'] = false;
            item['rejection_reason'] = effectiveReason;
            rejectedListing = Listing.fromMap(item);
            list.removeAt(index);
            await prefs.setString(_kPendingRoomsKey, jsonEncode(list));
          }
        }
      }

      // 2. Remove from approved IDs list
      final approvedIds = prefs.getStringList(_kApprovedRoomIdsKey) ?? [];
      if (approvedIds.contains(listingId)) {
        approvedIds.remove(listingId);
        await prefs.setStringList(_kApprovedRoomIdsKey, approvedIds);
      }

      // 3. Add to rejected list
      final rawRejected = prefs.getString(_kRejectedRoomsKey);
      List<dynamic> rejectedList =
          rawRejected != null ? jsonDecode(rawRejected) : [];
      rejectedList.removeWhere((item) => item['id']?.toString() == listingId);
      rejectedList.insert(0, {
        'id': listingId,
        'title': rejectedListing?.title ?? 'Room Listing',
        'reason': effectiveReason,
        'rejectedAt': DateTime.now().toIso8601String(),
      });
      await prefs.setString(_kRejectedRoomsKey, jsonEncode(rejectedList));

      // 4. Update custom listings registry
      final rawCustom = prefs.getString(_kCustomRoomListingsKey);
      if (rawCustom != null && rawCustom.isNotEmpty) {
        final decoded = jsonDecode(rawCustom);
        if (decoded is List) {
          final list =
              decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          for (final item in list) {
            if (item['id']?.toString() == listingId) {
              item['status'] = 'rejected';
              item['is_approved'] = false;
              item['rejection_reason'] = effectiveReason;
            }
          }
          await prefs.setString(_kCustomRoomListingsKey, jsonEncode(list));
        }
      }

      // 5. Update Supabase
      try {
        await _client.from('listings').update({
          'status': 'rejected',
          'is_approved': false,
          'rejection_reason': effectiveReason,
        }).eq('id', listingId);
      } catch (e) {
        debugPrint('rejectListing Supabase update error: $e');
      }

      // 6. Notify user
      final title = rejectedListing?.title ?? 'Room Listing';
      NotificationService.addNotification(
        title: 'Listing Update: Review Notice',
        subtitle: title,
        body:
            'Your room listing "$title" was not approved by admin. Reason: $effectiveReason. Please review our guidelines and update your submission.',
      );

      return true;
    } catch (e) {
      debugPrint('rejectListing error: $e');
      return false;
    }
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

  static Future<String?> uploadCoverImage(
      String listingId, Uint8List bytes) async {
    try {
      final fileName =
          'listings/$listingId/cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
        final fileName =
            'listings/$listingId/cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
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

  /// Creates a new room listing.
  /// When any user or host adds a room, it requires Admin approval (status: 'pending', is_approved: false).
  /// Admins posting listings are automatically approved.
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
    String? hostName,
    String? hostPhone,
    String? hostEmail,
    String? roomType,
  }) async {
    final user = _client.auth.currentUser;
    final now = DateTime.now();
    final nowIso = now.toIso8601String();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final tempId = 'room_${DateTime.now().millisecondsSinceEpoch}';

    String? imageUrl;
    if (coverImageBytes != null) {
      imageUrl = await uploadCoverImage(tempId, coverImageBytes);
    }

    // Check if Admin approval is required.
    // If the posting account is an Admin, auto-approve; otherwise set to pending.
    final requireApproval = await isApprovalRequired();
    final isAdmin = UserApprovalService.isAdminEmail(user?.email);
    final String initialStatus =
        (requireApproval && !isAdmin) ? 'pending' : 'approved';
    final bool initialIsApproved = initialStatus == 'approved';

    final effectiveHostName = (hostName != null && hostName.trim().isNotEmpty)
        ? hostName.trim()
        : (user?.userMetadata?['name'] ??
            user?.userMetadata?['full_name'] ??
            user?.email?.split('@').first ??
            'Host');
    final effectiveHostPhone =
        (hostPhone != null && hostPhone.trim().isNotEmpty)
            ? hostPhone.trim()
            : (user?.userMetadata?['phone'] ?? '+92 300 0000000');
    final effectiveHostEmail =
        (hostEmail != null && hostEmail.trim().isNotEmpty)
            ? hostEmail.trim()
            : (user?.email ?? 'host@roommatefinder.com');

    String createdId = tempId;

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
        'created_at': nowIso,
        'status': initialStatus,
        'is_approved': initialIsApproved,
      };

      Map<String, dynamic>? data;
      try {
        data = await _client
            .from('listings')
            .insert(insertPayload)
            .select()
            .maybeSingle();
      } on PostgrestException catch (pe) {
        debugPrint(
            'Supabase insert with status failed (${pe.code}): ${pe.message}. Retrying with legacy schema.');
        final legacyPayload = Map<String, dynamic>.from(insertPayload)
          ..remove('status')
          ..remove('is_approved');
        data = await _client
            .from('listings')
            .insert(legacyPayload)
            .select()
            .maybeSingle();
      }

      if (data != null && data['id'] != null) {
        createdId = data['id'].toString();
        if (coverImageBytes != null && imageUrl != null) {
          try {
            final newBucketPath = 'listings/$createdId/cover.jpg';
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
            await _client
                .from('listings')
                .update({'image_url': newPublicUrl})
                .eq('id', createdId);
            imageUrl = newPublicUrl;
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Error inserting listing to Supabase: $e');
    }

    // Save to local storage for offline moderation and demo reliability
    try {
      final prefs = await SharedPreferences.getInstance();

      final listingMap = {
        'id': createdId,
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
        'created_at': nowIso,
        'status': initialStatus,
        'is_approved': initialIsApproved,
        'host_name': effectiveHostName,
        'host_phone': effectiveHostPhone,
        'host_email': effectiveHostEmail,
        'room_type': roomType ?? (tag.isNotEmpty ? tag : 'Room'),
        'submitted_at': dateStr,
      };

      // 1. Add to custom listings registry
      final rawCustom = prefs.getString(_kCustomRoomListingsKey);
      List<dynamic> customList =
          rawCustom != null ? jsonDecode(rawCustom) : [];
      customList.removeWhere((item) => item['id']?.toString() == createdId);
      customList.insert(0, listingMap);
      await prefs.setString(_kCustomRoomListingsKey, jsonEncode(customList));

      if (initialStatus == 'pending') {
        // 2. Add to pending queue for Admin review
        final rawPending = prefs.getString(_kPendingRoomsKey);
        List<dynamic> pendingList =
            rawPending != null ? jsonDecode(rawPending) : [];
        pendingList.removeWhere((item) => item['id']?.toString() == createdId);
        pendingList.insert(0, listingMap);
        await prefs.setString(_kPendingRoomsKey, jsonEncode(pendingList));
      } else {
        // Add to approved IDs list
        final approvedIds = prefs.getStringList(_kApprovedRoomIdsKey) ?? [];
        if (!approvedIds.contains(createdId)) {
          approvedIds.add(createdId);
          await prefs.setStringList(_kApprovedRoomIdsKey, approvedIds);
        }
      }
    } catch (e) {
      debugPrint('Error saving listing to local storage: $e');
    }

    return createdId;
  }
}
