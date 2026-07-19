import 'package:fithub_portal_admin/core/network/accept_language.dart';
import 'package:fithub_portal_admin/core/network/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// AC-I6 / AC-I7: keep Supabase REST/auth calls aligned with UI locale.
///
/// Call sites:
/// - [main.dart] — `Supabase.initialize(..., headers: Accept-Language)`
/// - [apply] — on every locale change via [App] rebuild
abstract final class SupabaseLocaleHeaders {
  static const headerName = AcceptLanguage.headerName;

  /// Merges `Accept-Language` into the live client header map (AC-I7).
  static void apply(String languageCode) {
    if (!SupabaseConfig.isConfigured) return;
    try {
      if (!Supabase.instance.isInitialized) return;
      final client = Supabase.instance.client;
      final next = Map<String, String>.from(client.headers);
      next[headerName] = AcceptLanguage.normalize(languageCode);
      // Setter propagates to rest / auth / functions / storage clients.
      client.headers = next;
    } catch (_) {
      // Supabase may be unavailable in widget tests without --dart-define.
    }
  }

  static Map<String, String> initialHeaders(String languageCode) => {
    headerName: AcceptLanguage.normalize(languageCode),
  };
}
