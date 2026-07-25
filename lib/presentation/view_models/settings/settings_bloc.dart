import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/data/datasources/settings_local_datasource.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsLocalDataSource _settingsDataSource;

  SettingsBloc(this._settingsDataSource) : super(const SettingsState()) {
    on<SettingsLoaded>(_onSettingsLoaded);
    on<SettingsDevIdChanged>(_onDevIdChanged);
    on<SettingsBaseUrlChanged>(_onBaseUrlChanged);
    on<SettingsLanguageChanged>(_onLanguageChanged);
    on<SettingsDataTypeChanged>(_onDataTypeChanged);
    on<SettingsSubmitted>(_onSubmitted);
  }

  Future<void> _onSettingsLoaded(
      SettingsLoaded event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    
    final devId = _settingsDataSource.getDevId() ?? '';
    final baseUrl = _settingsDataSource.getBaseUrl() ?? '';
    final language = _settingsDataSource.getLanguage() ?? 'en';
    final dataTypeString = _settingsDataSource.getDataType() ?? 'inventory';

    SettingsOption option = SettingsOption.inventory;
    if (dataTypeString == 'asset') {
      option = SettingsOption.asset;
    } else if (dataTypeString == 'rawMaterial') {
      option = SettingsOption.rawMaterial;
    }

    emit(state.copyWith(
      devId: devId,
      baseUrl: baseUrl,
      language: language,
      selectedOption: option,
      status: SettingsStatus.initial,
    ));
  }

  void _onDevIdChanged(SettingsDevIdChanged event, Emitter<SettingsState> emit) {
    emit(state.copyWith(devId: event.devId, status: SettingsStatus.initial));
  }

  void _onBaseUrlChanged(SettingsBaseUrlChanged event, Emitter<SettingsState> emit) {
    emit(state.copyWith(baseUrl: event.baseUrl, status: SettingsStatus.initial));
  }

  void _onLanguageChanged(SettingsLanguageChanged event, Emitter<SettingsState> emit) {
    emit(state.copyWith(language: event.language, status: SettingsStatus.initial));
  }

  void _onDataTypeChanged(SettingsDataTypeChanged event, Emitter<SettingsState> emit) {
    emit(state.copyWith(selectedOption: event.option, status: SettingsStatus.initial));
  }

  Future<void> _onSubmitted(SettingsSubmitted event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading));

    if (state.devId.trim().isEmpty) {
      emit(state.copyWith(
        status: SettingsStatus.error,
        errorMessage: 'Device ID cannot be empty.',
      ));
      return;
    }

    String finalBaseUrl = state.baseUrl.trim();
    if (finalBaseUrl.isNotEmpty) {
      if (!finalBaseUrl.startsWith('http://') && !finalBaseUrl.startsWith('https://')) {
        finalBaseUrl = 'http://$finalBaseUrl';
      }
      final uri = Uri.tryParse(finalBaseUrl);
      if (uri == null || !uri.hasAuthority) {
        emit(state.copyWith(
          status: SettingsStatus.error,
          errorMessage: 'Invalid Base URL format.',
        ));
        return;
      }
    }

    await _settingsDataSource.saveDevId(state.devId.trim());
    await _settingsDataSource.saveBaseUrl(finalBaseUrl);
    await _settingsDataSource.saveLanguage(state.language);
    
    String dataTypeString = 'inventory';
    if (state.selectedOption == SettingsOption.asset) dataTypeString = 'asset';
    if (state.selectedOption == SettingsOption.rawMaterial) dataTypeString = 'rawMaterial';
    
    await _settingsDataSource.saveDataType(dataTypeString);

    emit(state.copyWith(status: SettingsStatus.saved, errorMessage: null));
  }
}
