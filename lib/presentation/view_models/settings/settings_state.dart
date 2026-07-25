import 'package:equatable/equatable.dart';

enum SettingsOption { inventory, asset, rawMaterial }

enum SettingsStatus { initial, loading, saved, error }

class SettingsState extends Equatable {
  final SettingsOption selectedOption;
  final String devId;
  final String baseUrl;
  final String language;
  final SettingsStatus status;
  final String? errorMessage;

  const SettingsState({
    this.selectedOption = SettingsOption.inventory,
    this.devId = '',
    this.baseUrl = '',
    this.language = 'en',
    this.status = SettingsStatus.initial,
    this.errorMessage,
  });

  SettingsState copyWith({
    SettingsOption? selectedOption,
    String? devId,
    String? baseUrl,
    String? language,
    SettingsStatus? status,
    String? errorMessage,
  }) {
    return SettingsState(
      selectedOption: selectedOption ?? this.selectedOption,
      devId: devId ?? this.devId,
      baseUrl: baseUrl ?? this.baseUrl,
      language: language ?? this.language,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        selectedOption,
        devId,
        baseUrl,
        language,
        status,
        errorMessage,
      ];
}
