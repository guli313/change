import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { renter, host }

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  static UserRole roleFromString(String? s) {
    switch ((s ?? '').toLowerCase().trim()) {
      case 'host':
      case 'landlord':
      case 'owner':
        return UserRole.host;
      default:
        return UserRole.renter;
    }
  }

  static String roleToString(UserRole r) {
    switch (r) {
      case UserRole.host:
        return 'host';
      case UserRole.renter:
        return 'renter';
    }
  }

  static String roleDisplay(UserRole r) {
    switch (r) {
      case UserRole.host:
        return 'Host';
      case UserRole.renter:
        return 'Renter';
    }
  }

  static String roleSubtitle(UserRole r) {
    switch (r) {
      case UserRole.host:
        return 'I have a room / property to rent out';
      case UserRole.renter:
        return 'I am looking for a room or roommate';
    }
  }

  static const String _kRolePrefKey = 'user_role';

  static Future<void> setLocalRole(UserRole role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kRolePrefKey, roleToString(role));
    } catch (e) {
      debugPrint('setLocalRole error: $e');
    }
  }

  static Future<UserRole> getUserRole() async {
    try {
      // 1. Check local cached selection
      final prefs = await SharedPreferences.getInstance();
      final localRole = prefs.getString(_kRolePrefKey);

      // 2. Check auth metadata if logged in
      final meta = currentUser?.userMetadata ?? {};
      final fromMeta = meta['user_type'] ?? meta['role'];
      if (fromMeta is String && fromMeta.trim().isNotEmpty) {
        final r = roleFromString(fromMeta);
        await prefs.setString(_kRolePrefKey, roleToString(r));
        return r;
      }

      // 3. Check profiles table
      final uid = currentUser?.id;
      if (uid != null) {
        final Map<String, dynamic>? data = await _client
            .from('profiles')
            .select('user_type,role')
            .eq('id', uid)
            .maybeSingle();
        if (data != null) {
          final t = data['user_type'] ?? data['role'];
          if (t is String && t.trim().isNotEmpty) {
            final r = roleFromString(t);
            await prefs.setString(_kRolePrefKey, roleToString(r));
            return r;
          }
        }
      }

      // 4. Fallback to local preference if present
      if (localRole != null && localRole.isNotEmpty) {
        return roleFromString(localRole);
      }
      return UserRole.renter;
    } catch (e) {
      debugPrint('getUserRole error: $e');
      return UserRole.renter;
    }
  }

  static Future<void> setUserRole(UserRole role, {String? fullName, String? phone, String? avatarUrl}) async {
    final roleStr = roleToString(role);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kRolePrefKey, roleStr);
    } catch (_) {}

    final uid = currentUser?.id;
    if (uid == null) return;
    try {
      await _client.auth.updateUser(
        UserAttributes(data: {'user_type': roleStr, ...(fullName != null ? {'name': fullName} : {})}),
      );
    } catch (e) {
      debugPrint('setUserRole auth.updateUser error (continuing): $e');
    }
    try {
      final payload = <String, dynamic>{
        'id': uid,
        'user_type': roleStr,
      };
      if (fullName != null) payload['full_name'] = fullName;
      if (phone != null) payload['phone'] = phone;
      if (avatarUrl != null) payload['avatar_url'] = avatarUrl;
      await _client.from('profiles').upsert(payload);
    } on PostgrestException catch (e) {
      if (e.code == '42P01') {
        debugPrint('profiles table missing — role stored locally via auth metadata.');
      } else {
        debugPrint('setUserRole profiles upsert error: $e');
      }
    } catch (e) {
      debugPrint('setUserRole profiles error (non-fatal): $e');
    }
  }

  static Future<int> getHostActiveListingCount() async {
    final uid = currentUser?.id;
    if (uid == null) return 0;
    try {
      final rows = await _client.from('listings').select('id').eq('user_id', uid);
      return (rows as List).length;
    } catch (e) {
      debugPrint('getHostActiveListingCount error: $e');
      return 0;
    }
  }

  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('signOut error: $e');
    }
  }
}
