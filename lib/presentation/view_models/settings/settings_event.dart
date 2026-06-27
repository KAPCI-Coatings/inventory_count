import 'package:equatable/equatable.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_state.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsEvent {}

class SettingsLanguageChanged extends SettingsEvent {
  final String language;

  const SettingsLanguageChanged(this.language);

  @override
  List<Object?> get props => [language];
}

class SettingsDevIdChanged extends SettingsEvent {
  final String devId;

  const SettingsDevIdChanged(this.devId);

  @override
  List<Object?> get props => [devId];
}

class SettingsOptionChanged extends SettingsEvent {
  final SettingsOption option;

  const SettingsOptionChanged(this.option);

  @override
  List<Object?> get props => [option];
}

class SettingsSubmitted extends SettingsEvent {}
