/// Shared `Accept-Language` normalization (FEAT-03 / FEAT-04).
abstract final class AcceptLanguage {
  static const headerName = 'Accept-Language';

  /// Maps BCP-47 tags to Portal-supported `en` | `ar`.
  static String normalize(String languageCode) {
    final code = languageCode.toLowerCase();
    if (code.startsWith('ar')) return 'ar';
    return 'en';
  }
}
