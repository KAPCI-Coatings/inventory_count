import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences sharedPreferences;

  static const String _languageKey = 'settings_language';
  static const String _devIdKey = 'settings_dev_id';
  static const String _optionKey = 'settings_option';

  SettingsBloc({required this.sharedPreferences})
      : super(const SettingsState()) {
    on<SettingsLoaded>(_onLoaded);
    on<SettingsLanguageChanged>(_onLanguageChanged);
    on<SettingsDevIdChanged>(_onDevIdChanged);
    on<SettingsOptionChanged>(_onOptionChanged);
    on<SettingsSubmitted>(_onSubmitted);
  }

  void _onLoaded(SettingsLoaded event, Emitter<SettingsState> emit) {
    emit(state.copyWith(status: SettingsStatus.loading));

    final String language =
        sharedPreferences.getString(_languageKey) ?? 'en';
    final String devId = sharedPreferences.getString(_devIdKey) ?? '001';
    final String? optionString = sharedPreferences.getString(_optionKey);

    SettingsOption option = SettingsOption.inventory;
    if (optionString == SettingsOption.asset.name) {
      option = SettingsOption.asset;
    } else if (optionString == SettingsOption.rowMaterial.name) {
      option = SettingsOption.rowMaterial;
    }

    emit(
      state.copyWith(
        status: SettingsStatus.success,
        language: language,
        devId: devId,
        selectedOption: option,
      ),
    );
  }

  void _onLanguageChanged(
      SettingsLanguageChanged event, Emitter<SettingsState> emit) {
    emit(state.copyWith(language: event.language));
  }

  void _onDevIdChanged(
      SettingsDevIdChanged event, Emitter<SettingsState> emit) {
    emit(state.copyWith(devId: event.devId));
  }

  void _onOptionChanged(
      SettingsOptionChanged event, Emitter<SettingsState> emit) {
    emit(state.copyWith(selectedOption: event.option));
  }

  Future<void> _onSubmitted(
      SettingsSubmitted event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    await sharedPreferences.setString(_languageKey, state.language);
    await sharedPreferences.setString(_devIdKey, state.devId);
    await sharedPreferences.setString(_optionKey, state.selectedOption.name);

    if (state.devId.isEmpty) {
      emit(
        state.copyWith(
          status: SettingsStatus.error,
        ),
      );
    } else if (state.selectedOption == SettingsOption.asset) {
      emit(
        state.copyWith(
          status: SettingsStatus.navigateToAssets,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: SettingsStatus.navigateToScanner,
        ),
      );
    }
  }
}
