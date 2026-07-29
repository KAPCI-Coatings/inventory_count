import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:inventory_count_flutter_app/core/di/di.dart';
import 'package:inventory_count_flutter_app/core/services/scanner_service.dart';

/// Variant of the popup dialog.
enum PopupVariant {
  /// Red — for unrecoverable scan errors or network failures.
  error,

  /// Amber/orange — for warnings that do NOT block the next scan (e.g. duplicates).
  warning,

  /// Green — for success feedback (e.g. data sent successfully).
  success,
}

class ErrorPopup extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final PopupVariant variant;

  const ErrorPopup({
    super.key,
    required this.message,
    this.onRetry,
    this.variant = PopupVariant.error,
  });

  // ── Static helpers ──────────────────────────────────────────────────────────

  /// returns a [Future] that resolves when the dialog is dismissed.
  static Future<void> show(
    BuildContext context,
    String message, {
    PopupVariant variant = PopupVariant.error,
    VoidCallback? onRetry,
  }) async {
    try {
      await instance<ScannerService>().disableScanner();
      await instance<ScannerService>().suspendScanner();
    } catch (e) {
      debugPrint('[ErrorPopup] suspend/disable error: $e');
    }
    try {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return ErrorPopup(
            message: message,
            variant: variant,
            onRetry: onRetry,
          );
        },
      );
    } finally {
      try {
        await instance<ScannerService>().resumeScanner();
        await instance<ScannerService>().enableScanner();
      } catch (e) {
        debugPrint('[ErrorPopup] resume/enable error: $e');
      }
    }
  }

  /// Convenience method for warning popups.
  /// Returns [true] if the user clicked "Yes", [false] or null if dismissed or "No"
  static Future<bool?> showWarning(BuildContext context, String message) async {
    try {
      await instance<ScannerService>().disableScanner();
      await instance<ScannerService>().suspendScanner();
    } catch (e) {
      debugPrint('[ErrorPopup] suspend/disable error: $e');
    }
    try {
      if (!context.mounted) return null;
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return ErrorPopup(
            message: message,
            variant: PopupVariant.warning,
          );
        },
      );
    } finally {
      try {
        await instance<ScannerService>().resumeScanner();
        await instance<ScannerService>().enableScanner();
      } catch (e) {
        debugPrint('[ErrorPopup] resume/enable error: $e');
      }
    }
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message, variant: PopupVariant.success);
  }

  // ── Widget ──────────────────────────────────────────────────────────────────

  Color get _accentColor {
    switch (variant) {
      case PopupVariant.warning:
        return const Color(0xFFE65100); // deep orange
      case PopupVariant.success:
        return const Color(0xFF388E3C); // green
      case PopupVariant.error:
        return Colors.redAccent;
    }
  }

  IconData get _icon {
    switch (variant) {
      case PopupVariant.warning:
        return Icons.warning_amber_rounded;
      case PopupVariant.success:
        return Icons.check_circle_outline_rounded;
      case PopupVariant.error:
        return Icons.error_outline_rounded;
    }
  }

  String _titleText(AppLocalizations? l10n) {
    switch (variant) {
      case PopupVariant.warning:
        return 'تحذير';
      case PopupVariant.success:
        return 'نجاح';
      case PopupVariant.error:
        return 'خطأ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              _icon,
              color: _accentColor,
              size: ResponsiveUtils.responsiveFontSize(context, 60.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              _titleText(l10n),
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 22.0),
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 16.0),
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              children: [
                if (variant == PopupVariant.warning) ...[
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        'لا',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(context, 16.0),
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'نعم',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(context, 16.0),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        'إغلاق',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(context, 16.0),
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onRetry!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.responsiveFontSize(context, 16.0),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
