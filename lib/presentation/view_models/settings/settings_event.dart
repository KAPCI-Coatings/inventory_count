import 'settings_state.dart';

abstract class SettingsEvent {}

class SettingsLoaded extends SettingsEvent {}

class SettingsDevIdChanged extends SettingsEvent {
  final String devId;
  SettingsDevIdChanged(this.devId);
}

class SettingsBaseUrlChanged extends SettingsEvent {
  final String baseUrl;
  SettingsBaseUrlChanged(this.baseUrl);
}

class SettingsLanguageChanged extends SettingsEvent {
  final String language;
  SettingsLanguageChanged(this.language);
}

class SettingsDataTypeChanged extends SettingsEvent {
  final SettingsOption option;
  SettingsDataTypeChanged(this.option);
}

class SettingsSubmitted extends SettingsEvent {}
