import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to handle Admin Approval for user registrations and logins,
/// as well as storing and checking user approval status.
class UserApprovalService {
  static SupabaseClient get _client => Supabase.instance.client;

  static const String _kApprovedUsersKey = 'approved_user_emails';
  static const String _kPendingRequestsKey = 'pending_user_approval_requests';
  static const String _kRejectedUsersKey = 'rejected_user_emails';

  // Seed demo/default approved users
  static const List<String> _kDefaultApproved = [
    'hamza.ali@example.com',
    'ayesha.k@example.com',
    'admin@roommatefinder.com',
    'admin@roommate.com',
  ];

  /// Checks if an email is an Admin email
  static bool isAdminEmail(String? email) {
    if (email == null) return false;
    final clean = email.trim().toLowerCase();
    return clean == 'admin@roommatefinder.com' ||
        clean == 'admin@roommate.com' ||
        clean.startsWith('admin@') ||
        clean.contains('admin');
  }

  /// Checks the approval status of a user.
  /// Returns: 'approved' | 'pending' | 'rejected'
  static Future<String> checkApprovalStatus(String email, {String? userId}) async {
    final clean = email.trim().toLowerCase();

    // Admins are always automatically approved
    if (isAdminEmail(clean)) {
      return 'approved';
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check rejected list
      final rejected = prefs.getStringList(_kRejectedUsersKey) ?? [];
      if (rejected.contains(clean)) {
        return 'rejected';
      }

      // Check approved list
      final approved = prefs.getStringList(_kApprovedUsersKey) ?? [];
      if (approved.contains(clean) || _kDefaultApproved.contains(clean)) {
        return 'approved';
      }

      // Check Supabase profiles table
      final uid = userId ?? _client.auth.currentUser?.id;
      if (uid != null) {
        final Map<String, dynamic>? data = await _client
            .from('profiles')
            .select('approval_status, is_approved, user_type')
            .eq('id', uid)
            .maybeSingle();

        if (data != null) {
          final status = data['approval_status']?.toString().toLowerCase();
          final isApproved = data['is_approved'] == true;
          final userType = data['user_type']?.toString().toLowerCase();

          if (userType == 'admin') return 'approved';
          if (status == 'approved' || isApproved) {
            approved.add(clean);
            await prefs.setStringList(_kApprovedUsersKey, approved);
            return 'approved';
          }
          if (status == 'rejected') {
            return 'rejected';
          }
        }
      }
    } catch (e) {
      debugPrint('checkApprovalStatus error: $e');
    }

    // Default status for any non-approved user is pending
    return 'pending';
  }

  /// Submits an approval request to the Admin for the user.
  static Future<void> submitApprovalRequest({
    required String email,
    String? userId,
    String? name,
    String? phone,
  }) async {
    final clean = email.trim().toLowerCase();
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final requestItem = {
      'id': userId ?? 'req_${DateTime.now().millisecondsSinceEpoch}',
      'email': clean,
      'name': (name != null && name.trim().isNotEmpty) ? name.trim() : clean.split('@').first,
      'phone': (phone != null && phone.trim().isNotEmpty) ? phone.trim() : '+92 300 0000000',
      'requestedAt': dateStr,
      'status': 'pending',
      'message': 'Please approve the request',
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPendingRequestsKey);
      List<Map<String, dynamic>> list = [];
      if (raw != null && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            list = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          }
        } catch (_) {}
      }

      list.removeWhere((item) => item['email'].toString().toLowerCase() == clean);
      list.insert(0, requestItem);
      await prefs.setString(_kPendingRequestsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('submitApprovalRequest local storage error: $e');
    }

    // Try upserting to Supabase profiles
    try {
      final uid = userId ?? _client.auth.currentUser?.id;
      if (uid != null) {
        await _client.from('profiles').upsert({
          'id': uid,
          'email': clean,
          'approval_status': 'pending',
          'is_approved': false,
          if (name != null) 'full_name': name,
          if (phone != null) 'phone': phone,
        });
      }
    } catch (e) {
      debugPrint('submitApprovalRequest Supabase upsert error: $e');
    }
  }

  /// Retrieves all pending user approval requests for the Admin Dashboard.
  static Future<List<Map<String, dynamic>>> getPendingRequests() async {
    List<Map<String, dynamic>> results = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPendingRequestsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          results = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('getPendingRequests local error: $e');
    }

    // Try syncing from Supabase
    try {
      final rows = await _client
          .from('profiles')
          .select('id, email, full_name, phone, created_at, approval_status')
          .eq('approval_status', 'pending');
      if (rows is List) {
        for (final r in rows) {
          final em = r['email']?.toString() ?? '';
          if (em.isNotEmpty && !results.any((req) => req['email'] == em)) {
            results.add({
              'id': r['id']?.toString() ?? 'sup_${DateTime.now().millisecondsSinceEpoch}',
              'email': em,
              'name': r['full_name']?.toString() ?? em.split('@').first,
              'phone': r['phone']?.toString() ?? 'Not provided',
              'requestedAt': 'Recent',
              'status': 'pending',
              'message': 'Please approve the request',
            });
          }
        }
      }
    } catch (_) {}

    return results;
  }

  /// Admin approves a user request.
  static Future<void> approveUser(String email, {String? userId}) async {
    final clean = email.trim().toLowerCase();
    try {
      final prefs = await SharedPreferences.getInstance();

      // Add to approved
      final approved = prefs.getStringList(_kApprovedUsersKey) ?? [];
      if (!approved.contains(clean)) {
        approved.add(clean);
        await prefs.setStringList(_kApprovedUsersKey, approved);
      }

      // Remove from rejected
      final rejected = prefs.getStringList(_kRejectedUsersKey) ?? [];
      if (rejected.contains(clean)) {
        rejected.remove(clean);
        await prefs.setStringList(_kRejectedUsersKey, rejected);
      }

      // Remove from pending
      final raw = prefs.getString(_kPendingRequestsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final list = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          list.removeWhere((item) => item['email'].toString().toLowerCase() == clean);
          await prefs.setString(_kPendingRequestsKey, jsonEncode(list));
        }
      }
    } catch (e) {
      debugPrint('approveUser local storage error: $e');
    }

    // Update Supabase
    try {
      if (userId != null) {
        await _client.from('profiles').update({
          'approval_status': 'approved',
          'is_approved': true,
        }).eq('id', userId);
      } else {
        await _client.from('profiles').update({
          'approval_status': 'approved',
          'is_approved': true,
        }).eq('email', clean);
      }
    } catch (e) {
      debugPrint('approveUser Supabase error: $e');
    }
  }

  /// Admin rejects a user request.
  static Future<void> rejectUser(String email, {String? userId}) async {
    final clean = email.trim().toLowerCase();
    try {
      final prefs = await SharedPreferences.getInstance();

      final rejected = prefs.getStringList(_kRejectedUsersKey) ?? [];
      if (!rejected.contains(clean)) {
        rejected.add(clean);
        await prefs.setStringList(_kRejectedUsersKey, rejected);
      }

      final approved = prefs.getStringList(_kApprovedUsersKey) ?? [];
      if (approved.contains(clean)) {
        approved.remove(clean);
        await prefs.setStringList(_kApprovedUsersKey, approved);
      }

      final raw = prefs.getString(_kPendingRequestsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final list = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
          list.removeWhere((item) => item['email'].toString().toLowerCase() == clean);
          await prefs.setString(_kPendingRequestsKey, jsonEncode(list));
        }
      }
    } catch (e) {
      debugPrint('rejectUser local storage error: $e');
    }

    try {
      if (userId != null) {
        await _client.from('profiles').update({
          'approval_status': 'rejected',
          'is_approved': false,
        }).eq('id', userId);
      } else {
        await _client.from('profiles').update({
          'approval_status': 'rejected',
          'is_approved': false,
        }).eq('email', clean);
      }
    } catch (_) {}
  }
}
