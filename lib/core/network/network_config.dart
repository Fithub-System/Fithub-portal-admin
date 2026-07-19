import 'supabase_config.dart';

/// Compile-time network hosts (FEAT-04 AC-C1).
abstract final class NetworkConfig {
  /// Portable HTTP API host. When empty and Supabase is configured, falls back
  /// to the Supabase project URL so Dio is usable while BaaS is still primary.
  static const String _baseUrlDefine = String.fromEnvironment('BASE_URL');

  static String get baseUrl {
    final defined = _baseUrlDefine.trim();
    if (defined.isNotEmpty) {
      return defined.endsWith('/')
          ? defined.substring(0, defined.length - 1)
          : defined;
    }
    if (SupabaseConfig.isConfigured) {
      final url = SupabaseConfig.url.trim();
      return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    }
    return '';
  }

  static bool get hasBaseUrl => baseUrl.isNotEmpty;
}
