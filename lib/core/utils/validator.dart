import 'package:easy_localization/easy_localization.dart';

class Validator {
  static String? isNotEmpty(
    String? value, {
    String? message,
  }) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'validation.field_empty'.tr();
    }
    return null;
  }

  static String? isValidEmail(
    String? value, {
    String? message,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.email_empty'.tr();
    }
    const pattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return message ?? 'validation.email_invalid'.tr();
    }
    return null;
  }

  static String? hasMinLength(
    String? value,
    int minLength, {
    String? message,
  }) {
    final resolved = message ??
        'validation.min_length'.tr(namedArgs: {'min': '$minLength'});
    if (value == null || value.length < minLength) {
      return resolved;
    }
    return null;
  }

  static String? hasMaxLength(
    String? value,
    int maxLength, {
    String? message,
  }) {
    final resolved = message ??
        'validation.max_length'.tr(namedArgs: {'max': '$maxLength'});
    if (value != null && value.length > maxLength) {
      return resolved;
    }
    return null;
  }

  static String? isNumeric(
    String? value, {
    String? message,
  }) {
    if (value == null || value.trim().isEmpty) {
      return message ?? 'validation.numeric'.tr();
    }
    if (double.tryParse(value) == null) {
      return message ?? 'validation.numeric'.tr();
    }
    return null;
  }

  static String? isValidPhone(
    String? value, {
    String? message,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'validation.phone_empty'.tr();
    }
    const pattern = r'^\+?[0-9]{7,15}$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return message ?? 'validation.phone_invalid'.tr();
    }
    return null;
  }

  static String? isValidPassword(
    String? value, {
    String? message,
  }) {
    if (value == null || value.isEmpty) {
      return 'validation.password_empty'.tr();
    }
    const pattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return message ?? 'validation.password_invalid'.tr();
    }
    return null;
  }

  static String? doPasswordsMatch(
    String? password,
    String? confirmPassword, {
    String? message,
  }) {
    if (password != confirmPassword) {
      return message ?? 'validation.passwords_mismatch'.tr();
    }
    return null;
  }
}
