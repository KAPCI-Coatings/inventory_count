import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';

/// Displays confirmed, locally saved upload progress.
class SendingProgressPopup extends StatelessWidget {
  const SendingProgressPopup({
    super.key,
    required this.sentCount,
    required this.totalToSend,
  });
  final int sentCount;
  final int totalToSend;

  @override
  Widget build(BuildContext context) {
    final progress = totalToSend == 0
        ? 0.0
        : (sentCount / totalToSend).clamp(0.0, 1.0);
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
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
            children: [
              // Animated progress indicator
              SizedBox(
                width: ResponsiveUtils.responsiveFontSize(context, 64),
                height: ResponsiveUtils.responsiveFontSize(context, 64),
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  value: progress,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'جاري الإرسال...',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'يرجى الانتظار حتى اكتمال الإرسال',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Confirmed progress
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$sentCount / $totalToSend — ${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, 28),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
