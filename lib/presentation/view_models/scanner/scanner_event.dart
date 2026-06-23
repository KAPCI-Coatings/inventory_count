import 'package:equatable/equatable.dart';

import '../../../domain/entities/scan_item.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

class ScannerInitializeRequested extends ScannerEvent {}

class ScannerNewOrderRequested extends ScannerEvent {}

class ScannerNewPalletRequested extends ScannerEvent {}

class ScannerPostCurrentOrderRequested extends ScannerEvent {}

class ScannerClearMessageRequested extends ScannerEvent {}

class ScannerDismissCenteredMessageRequested extends ScannerEvent {}

class ScannerAcknowledgeCenteredErrorRequested extends ScannerEvent {}

class ScannerSetEnabledRequested extends ScannerEvent {
  final bool isEnabled;

  const ScannerSetEnabledRequested(this.isEnabled);

  @override
  List<Object?> get props => [isEnabled];
}

class ScannerChangeProfileRequested extends ScannerEvent {
  final String profileName;

  const ScannerChangeProfileRequested(this.profileName);

  @override
  List<Object?> get props => [profileName];
}

class ScannerSaveAdminSettingsRequested extends ScannerEvent {
  final String baseUrl;
  final String deviceIdText;
  final void Function(bool) onResult;

  const ScannerSaveAdminSettingsRequested({
    required this.baseUrl,
    required this.deviceIdText,
    required this.onResult,
  });

  @override
  List<Object?> get props => [baseUrl, deviceIdText];
}

class ScannerScanReceived extends ScannerEvent {
  final ScanItem scan;

  const ScannerScanReceived(this.scan);

  @override
  List<Object?> get props => [scan];
}

class ScannerScanErrorReceived extends ScannerEvent {
  final Object error;

  const ScannerScanErrorReceived(this.error);

  @override
  List<Object?> get props => [error];
}

class ScannerDuplicatePalletConfirmed extends ScannerEvent {}

class ScannerDuplicatePalletRejected extends ScannerEvent {}
