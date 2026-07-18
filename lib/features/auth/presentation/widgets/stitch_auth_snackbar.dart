import 'package:flutter/material.dart';
import 'package:fithub_portal_admin/config/theme/app_colors.dart';

/// Stitch error treatment: error_container bg + on_error_container text.
abstract final class StitchAuthSnackbar {
  static void show(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.errorContainer,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    color: AppColors.onErrorContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
