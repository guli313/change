import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';
import 'listings_service.dart';
import 'notification_service.dart';

class HostRequest {
  final String id;
  final String userId;
  final String userEmail;
  final String ownerName;
  final String phone;
  final String cnic;
  final String address;
  final String roomTitle;
  final String city;
  final String area;
  final String roomType;
  final int rent;
  final int deposit;
  final String genderPreference;
  final String description;
  final List<String> amenities;
  final List<String> roomImages; // base64 or url or local path
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? rejectionReason;
  final String submittedAt;
  final String? reviewedAt;
  final bool congratsAcknowledged;

  HostRequest({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.ownerName,
    required this.phone,
    required this.cnic,
    required this.address,
    required this.roomTitle,
    required this.city,
    required this.area,
    required this.roomType,
    required this.rent,
    required this.deposit,
    required this.genderPreference,
    required this.description,
    required this.amenities,
    required this.roomImages,
    this.status = 'pending',
    this.rejectionReason,
    required this.submittedAt,
    this.reviewedAt,
    this.congratsAcknowledged = false,
  });

  HostRequest copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? ownerName,
    String? phone,
    String? cnic,
    String? address,
    String? roomTitle,
    String? city,
    String? area,
    String? roomType,
    int? rent,
    int? deposit,
    String? genderPreference,
    String? description,
    List<String>? amenities,
    List<String>? roomImages,
    String? status,
    String? rejectionReason,
    String? submittedAt,
    String? reviewedAt,
    bool? congratsAcknowledged,
  }) {
    return HostRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      cnic: cnic ?? this.cnic,
      address: address ?? this.address,
      roomTitle: roomTitle ?? this.roomTitle,
      city: city ?? this.city,
      area: area ?? this.area,
      roomType: roomType ?? this.roomType,
      rent: rent ?? this.rent,
      deposit: deposit ?? this.deposit,
      genderPreference: genderPreference ?? this.genderPreference,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      roomImages: roomImages ?? this.roomImages,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      congratsAcknowledged: congratsAcknowledged ?? this.congratsAcknowledged,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userEmail': userEmail,
        'ownerName': ownerName,
        'phone': phone,
        'cnic': cnic,
        'address': address,
        'roomTitle': roomTitle,
        'city': city,
        'area': area,
        'roomType': roomType,
        'rent': rent,
        'deposit': deposit,
        'genderPreference': genderPreference,
        'description': description,
        'amenities': amenities,
        'roomImages': roomImages,
        'status': status,
        'rejectionReason': rejectionReason,
        'submittedAt': submittedAt,
        'reviewedAt': reviewedAt,
        'congratsAcknowledged': congratsAcknowledged,
      };

  factory HostRequest.fromMap(Map<String, dynamic> map) {
    return HostRequest(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      userEmail: map['userEmail']?.toString() ?? '',
      ownerName: map['ownerName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      cnic: map['cnic']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      roomTitle: map['roomTitle']?.toString() ?? '',
      city: map['city']?.toString() ?? 'Islamabad',
      area: map['area']?.toString() ?? '',
      roomType: map['roomType']?.toString() ?? 'Single Room',
      rent: int.tryParse(map['rent']?.toString() ?? '0') ?? 0,
      deposit: int.tryParse(map['deposit']?.toString() ?? '0') ?? 0,
      genderPreference: map['genderPreference']?.toString() ?? 'Anyone',
      description: map['description']?.toString() ?? '',
      amenities: (map['amenities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      roomImages: (map['roomImages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: map['status']?.toString() ?? 'pending',
      rejectionReason: map['rejectionReason']?.toString(),
      submittedAt: map['submittedAt']?.toString() ?? '',
      reviewedAt: map['reviewedAt']?.toString(),
      congratsAcknowledged: map['congratsAcknowledged'] == true,
    );
  }
}

class HostRequestService {
  static const String _kStorageKey = 'host_account_applications_v2';
  static SupabaseClient get _client => Supabase.instance.client;

  /// Retrieves all host applications (for Admin)
  static Future<List<HostRequest>> getAllRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStorageKey);
    List<HostRequest> list = [];

    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          list = decoded
              .map((e) => HostRequest.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }
      } catch (e) {
        debugPrint('getAllRequests json error: $e');
      }
    }

    // If completely empty, add a default demo request so the admin dashboard can be tested right away
    if (list.isEmpty) {
      list = [
        HostRequest(
          id: 'demo_req_01',
          userId: 'usr_demo_host',
          userEmail: 'usman.host@example.com',
          ownerName: 'Usman Farooq',
          phone: '+92 312 9876543',
          cnic: '37405-1234567-1',
          address: 'House 42, St 12, F-8/2, Islamabad',
          roomTitle: 'Furnished Executive Master Bed with Attached Bath',
          city: 'Islamabad',
          area: 'F-8/2',
          roomType: 'Single Room',
          rent: 32000,
          deposit: 20000,
          genderPreference: 'Male Only',
          description:
              'Executive spacious room for male student or working professional. Clean environment, silent street, walking distance to Metro.',
          amenities: ['WiFi', 'Air Conditioning', 'Attached Bath', 'Geyser', 'UPS Backup', 'Mess Available'],
          roomImages: [
            'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800',
            'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=800',
          ],
          status: 'pending',
          submittedAt: 'Today at 02:30 PM',
        ),
      ];
      await prefs.setString(
          _kStorageKey, jsonEncode(list.map((e) => e.toMap()).toList()));
    }

    return list;
  }

  /// Submits or updates a host account request for the current user
  static Future<HostRequest> submitHostRequest({
    required String ownerName,
    required String phone,
    required String cnic,
    required String address,
    required String roomTitle,
    required String city,
    required String area,
    required String roomType,
    required int rent,
    required int deposit,
    required String genderPreference,
    required String description,
    required List<String> amenities,
    required List<String> roomImages,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final user = _client.auth.currentUser;
    final userId = user?.id ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final userEmail = user?.email ?? 'user@roommatefinder.com';

    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final newRequest = HostRequest(
      id: 'hreq_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      userEmail: userEmail,
      ownerName: ownerName,
      phone: phone,
      cnic: cnic,
      address: address,
      roomTitle: roomTitle,
      city: city,
      area: area,
      roomType: roomType,
      rent: rent,
      deposit: deposit,
      genderPreference: genderPreference,
      description: description,
      amenities: amenities,
      roomImages: roomImages,
      status: 'pending',
      rejectionReason: null,
      submittedAt: dateStr,
      congratsAcknowledged: false,
    );

    // Save to list
    final all = await getAllRequests();
    // Replace any existing pending or rejected request for this user
    all.removeWhere((r) =>
        r.userId == userId ||
        (r.userEmail.isNotEmpty &&
            r.userEmail.toLowerCase() == userEmail.toLowerCase()));
    all.insert(0, newRequest);

    await prefs.setString(
        _kStorageKey, jsonEncode(all.map((e) => e.toMap()).toList()));

    // Store per-user lookup
    await prefs.setString('user_host_request_$userId', jsonEncode(newRequest.toMap()));
    if (userEmail.isNotEmpty) {
      await prefs.setString('user_host_request_email_${userEmail.toLowerCase()}',
          jsonEncode(newRequest.toMap()));
    }

    // Try syncing to Supabase profiles or custom table
    try {
      if (user != null) {
        await _client.from('profiles').upsert({
          'id': user.id,
          'email': userEmail,
          'full_name': ownerName,
          'phone': phone,
          'host_application_status': 'pending',
        });
      }
    } catch (_) {}

    // Add user notification
    try {
      NotificationService.addNotification(
        title: 'Host Application Submitted',
        subtitle: 'Wait for admin approval',
        body:
            'Your host account application for "$roomTitle" has been submitted. Please wait for admin approval.',
      );
    } catch (_) {}

    return newRequest;
  }

  /// Gets the latest host request for the current user
  static Future<HostRequest?> getLatestRequestForCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final user = _client.auth.currentUser;
    final userId = user?.id;
    final userEmail = user?.email?.toLowerCase().trim();

    // Check direct user key first
    if (userId != null) {
      final raw = prefs.getString('user_host_request_$userId');
      if (raw != null && raw.isNotEmpty) {
        try {
          return HostRequest.fromMap(jsonDecode(raw));
        } catch (_) {}
      }
    }

    if (userEmail != null && userEmail.isNotEmpty) {
      final raw = prefs.getString('user_host_request_email_$userEmail');
      if (raw != null && raw.isNotEmpty) {
        try {
          return HostRequest.fromMap(jsonDecode(raw));
        } catch (_) {}
      }
    }

    // Fallback: search in all requests
    final all = await getAllRequests();
    if (userId != null) {
      final match = all.where((r) => r.userId == userId).toList();
      if (match.isNotEmpty) return match.first;
    }
    if (userEmail != null && userEmail.isNotEmpty) {
      final match =
          all.where((r) => r.userEmail.toLowerCase() == userEmail).toList();
      if (match.isNotEmpty) return match.first;
    }

    return null;
  }

  /// Admin accepts/approves a host request
  static Future<void> approveRequest(String requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllRequests();
    final index = all.indexWhere((r) => r.id == requestId);

    if (index == -1) return;

    final target = all[index];
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final updated = target.copyWith(
      status: 'approved',
      rejectionReason: null,
      reviewedAt: dateStr,
      congratsAcknowledged: false, // User hasn't celebrated yet!
    );

    all[index] = updated;
    await prefs.setString(
        _kStorageKey, jsonEncode(all.map((e) => e.toMap()).toList()));

    // Update user keys
    await prefs.setString(
        'user_host_request_${target.userId}', jsonEncode(updated.toMap()));
    if (target.userEmail.isNotEmpty) {
      await prefs.setString(
          'user_host_request_email_${target.userEmail.toLowerCase()}',
          jsonEncode(updated.toMap()));
    }

    // Set user role to Host!
    try {
      await AuthService.setUserRole(UserRole.host,
          fullName: target.ownerName, phone: target.phone);
    } catch (e) {
      debugPrint('Error setting role to host: $e');
    }

    // Auto-create their listing so it appears in their Host Dashboard and Live Listings
    try {
      await ListingsService.createListing(
        title: target.roomTitle,
        city: target.city,
        rent: target.rent,
        currency: 'PKR',
        period: '/month',
        tag: target.genderPreference,
        description:
            '${target.description}\n\nArea: ${target.area}\nAmenities: ${target.amenities.join(', ')}',
        hostName: target.ownerName,
        hostPhone: target.phone,
        hostEmail: target.userEmail,
        roomType: target.roomType,
      );
    } catch (e) {
      debugPrint('Error auto-creating listing for approved host: $e');
    }

    // Add notification
    try {
      NotificationService.addNotification(
        title: '🎉 Congratulations! You are now a Host!',
        subtitle: 'Host Account Approved',
        body:
            'Admin accepted your request. Your host account is active and your room listing "${target.roomTitle}" is published!',
      );
    } catch (_) {}
  }

  /// Admin rejects a host request
  static Future<void> rejectRequest(String requestId, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllRequests();
    final index = all.indexWhere((r) => r.id == requestId);

    if (index == -1) return;

    final target = all[index];
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final updated = target.copyWith(
      status: 'rejected',
      rejectionReason:
          reason.trim().isNotEmpty ? reason.trim() : 'Incomplete room details or unclear photos.',
      reviewedAt: dateStr,
    );

    all[index] = updated;
    await prefs.setString(
        _kStorageKey, jsonEncode(all.map((e) => e.toMap()).toList()));

    // Update user keys
    await prefs.setString(
        'user_host_request_${target.userId}', jsonEncode(updated.toMap()));
    if (target.userEmail.isNotEmpty) {
      await prefs.setString(
          'user_host_request_email_${target.userEmail.toLowerCase()}',
          jsonEncode(updated.toMap()));
    }

    // Add notification
    try {
      NotificationService.addNotification(
        title: 'Host Application Update',
        subtitle: 'Admin Rejected',
        body:
            'Your host request was rejected by Admin. Reason: ${updated.rejectionReason}',
      );
    } catch (_) {}
  }

  /// Mark the congratulations screen as viewed so it doesn't interrupt repeatedly
  static Future<void> markCongratsAcknowledged(String requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllRequests();
    final index = all.indexWhere((r) => r.id == requestId);

    if (index != -1) {
      final updated = all[index].copyWith(congratsAcknowledged: true);
      all[index] = updated;
      await prefs.setString(
          _kStorageKey, jsonEncode(all.map((e) => e.toMap()).toList()));

      await prefs.setString(
          'user_host_request_${updated.userId}', jsonEncode(updated.toMap()));
      if (updated.userEmail.isNotEmpty) {
        await prefs.setString(
            'user_host_request_email_${updated.userEmail.toLowerCase()}',
            jsonEncode(updated.toMap()));
      }
    }
  }
}

