import 'package:equatable/equatable.dart';

enum SettingsStatus { initial, loading, success, submitSuccess, error, navigateToAssets, navigateToScanner }

enum SettingsOption { inventory, asset, rowMaterial }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final String language;
  final String devId;
  final SettingsOption selectedOption;
  final String? message;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.language = 'en',
    this.devId = '001',
    this.selectedOption = SettingsOption.inventory,
    this.message,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    String? language,
    String? devId,
    SettingsOption? selectedOption,
    String? message,
  }) {
    return SettingsState(
      status: status ?? this.status,
      language: language ?? this.language,
      devId: devId ?? this.devId,
      selectedOption: selectedOption ?? this.selectedOption,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        language,
        devId,
        selectedOption,
        message,
      ];
}
