class SupabaseConfig {
  static bool isConfigured({required String url, required String anonKey}) {
    final normalizedUrl = url.trim();
    final normalizedKey = anonKey.trim();

    if (normalizedUrl.isEmpty || normalizedKey.isEmpty) {
      return false;
    }

    final placeholderPatterns = <String>[
      'YOUR_SUPABASE',
      'YOUR_ANON_KEY',
      'YOUR_SERVICE_ROLE_KEY',
      'YOUR_SUPABASE_ANON_KEY',
      'REPLACE_ME',
      'YOUR_KEY',
    ];

    final hasPlaceholder = placeholderPatterns.any(
      (pattern) =>
          normalizedUrl.toLowerCase().contains(pattern.toLowerCase()) ||
          normalizedKey.toLowerCase().contains(pattern.toLowerCase()),
    );

    return !hasPlaceholder;
  }
}
