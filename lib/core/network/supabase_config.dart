/// Supabase connection via `--dart-define` (no committed secrets).
abstract final class SupabaseConfig {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Auth email `emailRedirectTo`. GHA sets this from `AUTH_REDIRECT_URL`
  /// (live host: `https://fithub-portal-admin.vercel.app/`).
  static const String authRedirectUrl = String.fromEnvironment(
    'AUTH_REDIRECT_URL',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// Non-empty HTTPS redirect for founder confirm. Skips localhost.
  static String get emailRedirectTo {
    final raw = authRedirectUrl.trim();
    final uri = Uri.tryParse(raw);
    if (raw.isNotEmpty &&
        uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty &&
        uri.host != 'localhost' &&
        uri.host != '127.0.0.1') {
      return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
    }
    return 'https://fithub-portal-admin.vercel.app';
  }
}
