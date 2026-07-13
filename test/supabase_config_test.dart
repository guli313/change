import 'package:flutter_test/flutter_test.dart';
import 'package:roommate_finder/utils/supabase_config.dart';

void main() {
  group('SupabaseConfig', () {
    test('treats placeholder values as not configured', () {
      expect(
        SupabaseConfig.isConfigured(
          url: 'https://example.supabase.co',
          anonKey: 'YOUR_SUPABASE_ANON_KEY',
        ),
        isFalse,
      );
    });

    test('accepts real-looking values', () {
      expect(
        SupabaseConfig.isConfigured(
          url: 'https://abc123.supabase.co',
          anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
        ),
        isTrue,
      );
    });
  });
}
