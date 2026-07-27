import 'accept_language.dart';

/// Mutable locale code for Dio [Accept-Language] (updated from [App]).
abstract final class LocaleCodeHolder {
  static String _code = 'en';

  static String get code => _code;

  static void update(String languageCode) {
    _code = AcceptLanguage.normalize(languageCode);
  }
}
