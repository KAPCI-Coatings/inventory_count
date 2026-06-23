import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:inventory_count_flutter_app/domain/entities/scan_item.dart';
import 'package:inventory_count_flutter_app/domain/entities/scanner_cache.dart';
import 'package:inventory_count_flutter_app/domain/entities/scanner_settings.dart';
import 'package:inventory_count_flutter_app/domain/uescases/get_scanner_settings_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/initialize_scanner_usecase.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/scanner/scanner_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/scanner/scanner_state.dart';

import '../../../domain/entities/item_box.dart';
import '../../../domain/uescases/clear_scanner_cache_usecase.dart';
import '../../../domain/uescases/disable_scanner_usecase.dart';
import '../../../domain/uescases/enable_scanner_usecase.dart';
import '../../../domain/uescases/load_scanner_cache_usecase.dart';
import '../../../domain/uescases/observe_scans_usecase.dart';
import '../../../domain/uescases/post_handling_details_usecase.dart';
import '../../../domain/uescases/save_scanner_cache_usecase.dart';
import '../../../domain/uescases/save_scanner_settings_usecase.dart';
import '../../../domain/uescases/switch_profile_usecase.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final InitializeScannerUseCase _initializeScanner;
  final ObserveScansUseCase _observeScans;
  final EnableScannerUseCase _enableScanner;
  final DisableScannerUseCase _disableScanner;
  final SwitchProfileUseCase _switchProfile;
  final GetScannerSettingsUseCase _getScannerSettings;
  final SaveScannerSettingsUseCase _saveScannerSettings;
  final LoadScannerCacheUseCase _loadScannerCache;
  final SaveScannerCacheUseCase _saveScannerCache;
  final ClearScannerCacheUseCase _clearScannerCache;
  final PostHandlingDetailsUseCase _postHandlingDetails;

  StreamSubscription<ScanItem>? _scanSubscription;
  bool _isInitializing = false;
  bool _isInitialized = false;

  ScannerBloc({
    required InitializeScannerUseCase initializeScanner,
    required ObserveScansUseCase observeScans,
    required EnableScannerUseCase enableScanner,
    required DisableScannerUseCase disableScanner,
    required SwitchProfileUseCase switchProfile,
    required GetScannerSettingsUseCase getScannerSettings,
    required SaveScannerSettingsUseCase saveScannerSettings,
    required LoadScannerCacheUseCase loadScannerCache,
    required SaveScannerCacheUseCase saveScannerCache,
    required ClearScannerCacheUseCase clearScannerCache,
    required PostHandlingDetailsUseCase postHandlingDetails,
  }) : _initializeScanner = initializeScanner,
       _observeScans = observeScans,
       _enableScanner = enableScanner,
       _disableScanner = disableScanner,
       _switchProfile = switchProfile,
       _getScannerSettings = getScannerSettings,
       _saveScannerSettings = saveScannerSettings,
       _loadScannerCache = loadScannerCache,
       _saveScannerCache = saveScannerCache,
       _clearScannerCache = clearScannerCache,
       _postHandlingDetails = postHandlingDetails,
       super(const ScannerState()) {
    on<ScannerInitializeRequested>(_onInitializeRequested);
    on<ScannerScanReceived>(_onScanReceived);
    on<ScannerScanErrorReceived>(_onScanErrorReceived);
    on<ScannerNewOrderRequested>(_onNewOrderRequested);
    on<ScannerNewPalletRequested>(_onNewPalletRequested);
    on<ScannerPostCurrentOrderRequested>(_onPostCurrentOrderRequested);
    on<ScannerClearMessageRequested>(_onClearMessageRequested);
    on<ScannerDismissCenteredMessageRequested>(_onDismissCenteredMessageRequested);
    on<ScannerAcknowledgeCenteredErrorRequested>(_onAcknowledgeCenteredErrorRequested);
    on<ScannerSetEnabledRequested>(_onSetEnabledRequested);
    on<ScannerChangeProfileRequested>(_onChangeProfileRequested);
    on<ScannerSaveAdminSettingsRequested>(_onSaveAdminSettingsRequested);
    on<ScannerDuplicatePalletConfirmed>(_onDuplicatePalletConfirmed);
    on<ScannerDuplicatePalletRejected>(_onDuplicatePalletRejected);
  }

  void _attachScanSubscription() {
    _scanSubscription = _observeScans().listen(
      (ScanItem scan) {
        if (!state.isScannerEnabled) {
          return;
        }
        add(ScannerScanReceived(scan));
      },
      onError: (Object error) {
        add(ScannerScanErrorReceived(error));
      },
    );
  }

  Future<void> _onScanReceived(ScannerScanReceived event, Emitter<ScannerState> emit) async {
    final ScanItem scan = event.scan;
    try {
      final String palletLabel = _buildPalletLabel(state.palletCount);
      final ItemBox itemBox = ItemBox.fromBarcode(
        barcode: scan.code,
        palletBox: palletLabel,
        readDate: scan.scannedAt,
      );

      if (itemBox.isPallet) {
        // ── Pallet scan ──
        final bool duplicatePallet = state.itemBoxes.any(
          (ItemBox existing) => existing.barCodeNo == itemBox.barCodeNo,
        );

        if (duplicatePallet) {
          // Show warning and wait for user confirmation
          await SystemSound.play(SystemSoundType.alert);

          try {
            await _disableScanner();
          } catch (_) {}

          emit(
            state.copyWith(
              status: ScannerStatus.ready,
              isScannerEnabled: false,
              pendingDuplicatePallet: itemBox,
              centeredWarningMessage: 'هل أنت متأكد أنك تريد تكرار هذا الباليت؟',
              centeredErrorMessage: null,
              centeredSuccessMessage: null,
              message: null,
            ),
          );
          return;
        }

        // Not a duplicate pallet → accept immediately
        await _acceptItem(itemBox, emit);
      } else {
        // ── Box scan ──
        final List<ItemBox> currentOrderItems = state.currentOrderItemBoxes;
        if (currentOrderItems.isNotEmpty) {
          final ItemBox firstItem = currentOrderItems.first;
          final bool hasDifferentMaterialOrBatch =
              itemBox.matnr != firstItem.matnr ||
              itemBox.batchNo != firstItem.batchNo;

          if (hasDifferentMaterialOrBatch) {
            await _triggerWrongBarcodeFlow(
              'يجب أن يكون الماتيريال والباتش مطابقين لأول باركود تم قراءته.',
              emit,
            );
            return;
          }
        }

        final bool duplicateSerial = currentOrderItems.any(
          (ItemBox existing) => existing.serialNo == itemBox.serialNo,
        );

        if (duplicateSerial) {
          await _triggerWrongBarcodeFlow('رقم السيريال مكرر داخل نفس الأوردر.', emit);
          return;
        }

        await _acceptItem(itemBox, emit);
      }
    } on FormatException {
      await _triggerWrongBarcodeFlow(
        'باركود غير صحيح. يجب أن يكون 20 أو 21 حرف بالضبط.',
        emit,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ScannerStatus.error,
          message: 'حدث خطأ غير متوقع أثناء معالجة القراءة.',
          centeredErrorMessage: null,
          centeredSuccessMessage: null,
          centeredWarningMessage: null,
        ),
      );
    }
  }

  /// Shared helper to add an [ItemBox] (box or pallet) to the lists and persist.
  Future<void> _acceptItem(ItemBox itemBox, Emitter<ScannerState> emit) async {
    final List<ItemBox> nextAllItems = List<ItemBox>.from(state.itemBoxes)
      ..add(itemBox);
    final List<ItemBox> nextCurrentOrderItems = List<ItemBox>.from(
      state.currentOrderItemBoxes,
    )..add(itemBox);

    final int nextDailyScanCount = state.dailyScanCount + itemBox.qty;
    final String todayKey = _todayKey();

    emit(
      state.copyWith(
        status: ScannerStatus.ready,
        lastScan: itemBox,
        itemBoxes: nextAllItems,
        currentOrderItemBoxes: nextCurrentOrderItems,
        dailyScanCount: nextDailyScanCount,
        dailyKey: todayKey,
        message: null,
        centeredErrorMessage: null,
        centeredSuccessMessage: null,
        centeredWarningMessage: null,
        pendingDuplicatePallet: null,
      ),
    );

    await _persistCache(
      itemBoxes: nextAllItems,
      palletCount: state.palletCount,
      dailyScanCount: nextDailyScanCount,
      dailyKey: todayKey,
    );
  }

  Future<void> _onDuplicatePalletConfirmed(
    ScannerDuplicatePalletConfirmed event,
    Emitter<ScannerState> emit,
  ) async {
    final ItemBox? pendingItem = state.pendingDuplicatePallet;
    if (pendingItem == null) return;

    try {
      await _enableScanner();
    } catch (_) {}

    emit(
      state.copyWith(
        isScannerEnabled: true,
        centeredWarningMessage: null,
        pendingDuplicatePallet: null,
      ),
    );

    await _acceptItem(pendingItem, emit);
  }

  Future<void> _onDuplicatePalletRejected(
    ScannerDuplicatePalletRejected event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      await _enableScanner();
    } catch (_) {}

    emit(
      state.copyWith(
        status: ScannerStatus.ready,
        isScannerEnabled: true,
        centeredWarningMessage: null,
        pendingDuplicatePallet: null,
        centeredErrorMessage: null,
        centeredSuccessMessage: null,
        message: null,
      ),
    );
  }

  void _onScanErrorReceived(ScannerScanErrorReceived event, Emitter<ScannerState> emit) {
    emit(
      state.copyWith(
        status: ScannerStatus.error,
        message: 'حدث خطأ أثناء قراءة الباركود.',
        centeredErrorMessage: null,
        centeredSuccessMessage: null,
      ),
    );
  }

  Future<void> _triggerWrongBarcodeFlow(String errorMessage, Emitter<ScannerState> emit) async {
    await SystemSound.play(SystemSoundType.alert);

    try {
      await _disableScanner();
    } catch (_) {
      // Keep UI flow consistent even if scanner disable call fails.
    }

    emit(
      state.copyWith(
        status: ScannerStatus.error,
        isScannerEnabled: false,
        centeredErrorMessage: errorMessage,
        message: null,
        centeredSuccessMessage: null,
      ),
    );
  }

  Future<void> _onInitializeRequested(ScannerInitializeRequested event, Emitter<ScannerState> emit) async {
    if (_isInitializing || _isInitialized) {
      return;
    }

    _isInitializing = true;
    emit(state.copyWith(status: ScannerStatus.loading, message: null));

    try {
      await _scanSubscription?.cancel();
      _attachScanSubscription();

      final ScannerSettings settings = await _getScannerSettings();
      final ScannerCache cache = await _loadScannerCache();
      final String todayKey = _todayKey();
      final int normalizedDailyCount = cache.dailyKey == todayKey
          ? cache.dailyScanCount
          : 0;
      final int normalizedPalletCount = cache.palletCount < 1
          ? 1
          : cache.palletCount;

      await _initializeScanner();
      if (state.isScannerEnabled) {
        await _enableScanner();
      }

      emit(
        state.copyWith(
          status: ScannerStatus.ready,
          activeProfile: settings.profileName,
          itemBoxes: cache.itemBoxes,
          currentOrderItemBoxes: const <ItemBox>[],
          palletCount: normalizedPalletCount,
          dailyScanCount: normalizedDailyCount,
          dailyKey: todayKey,
          baseUrl: settings.baseUrl,
          deviceId: settings.deviceId,
          isScannerEnabled: true,
          lastScan: null,
          message: null,
          centeredErrorMessage: null,
          centeredSuccessMessage: null,
        ),
      );

      if (cache.dailyKey != todayKey ||
          cache.dailyScanCount != normalizedDailyCount ||
          cache.palletCount != normalizedPalletCount) {
        await _persistCache(
          itemBoxes: cache.itemBoxes,
          palletCount: normalizedPalletCount,
          dailyScanCount: normalizedDailyCount,
          dailyKey: todayKey,
        );
      }

      _isInitialized = true;
    } catch (e) {
      emit(
        state.copyWith(
          status: ScannerStatus.error,
          message: 'تعذر تهيئة الماسح. تأكد من الإعدادات.',
          centeredErrorMessage: null,
          centeredSuccessMessage: null,
        ),
      );
    } finally {
      _isInitializing = false;
    }
  }

  void _onNewOrderRequested(ScannerNewOrderRequested event, Emitter<ScannerState> emit) {
    final String todayKey = _todayKey();
    emit(
      state.copyWith(
        status: ScannerStatus.ready,
        lastScan: null,
        currentOrderItemBoxes: const <ItemBox>[],
        palletCount: 1,
        dailyKey: todayKey,
        message: null,
        centeredErrorMessage: null,
        centeredSuccessMessage: null,
      ),
    );
  }

  Future<void> _onNewPalletRequested(ScannerNewPalletRequested event, Emitter<ScannerState> emit) async {
    final int nextPalletCount = state.palletCount + 1;
    final String todayKey = _todayKey();

    emit(
      state.copyWith(
        status: ScannerStatus.ready,
        palletCount: nextPalletCount,
        dailyKey: todayKey,
        message: null,
        centeredErrorMessage: null,
        centeredSuccessMessage: null,
      ),
    );

    await _persistCache(
      itemBoxes: state.itemBoxes,
      palletCount: nextPalletCount,
      dailyScanCount: state.dailyScanCount,
      dailyKey: todayKey,
    );
  }

  Future<void> _onPostCurrentOrderRequested(ScannerPostCurrentOrderRequested event, Emitter<ScannerState> emit) async {
    if (state.itemBoxes.isEmpty) {
      emit(
        state.copyWith(
          status: ScannerStatus.error,
          message: 'لا توجد بيانات ممسوحة للإرسال.',
          centeredErrorMessage: null,
          centeredSuccessMessage: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ScannerStatus.posting,
        message: null,
        centeredErrorMessage: null,
        centeredSuccessMessage: null,
      ),
    );

    try {
      await _postHandlingDetails(
        baseUrl: state.baseUrl,
        devId: state.deviceId,
        itemBoxes: state.itemBoxes,
      );
      await _clearScannerCache();

      emit(
        state.copyWith(
          status: ScannerStatus.postSuccess,
          itemBoxes: const <ItemBox>[],
          currentOrderItemBoxes: const <ItemBox>[],
          lastScan: null,
          palletCount: 1,
          dailyScanCount: 0,
          dailyKey: _todayKey(),
          message: null,
          centeredErrorMessage: null,
          centeredSuccessMessage: 'تم الإرسال بنجاح وتم مسح الكاش.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ScannerStatus.error,
          message: _buildPostErrorMessage(e),
          centeredErrorMessage: null,
          centeredSuccessMessage: null,
        ),
      );
    }
  }

  void _onClearMessageRequested(ScannerClearMessageRequested event, Emitter<ScannerState> emit) {
    if (state.message == null || state.message!.isEmpty) {
      return;
    }

    final ScannerStatus normalizedStatus =
        state.status == ScannerStatus.postSuccess
        ? ScannerStatus.ready
        : state.status;

    emit(state.copyWith(status: normalizedStatus, message: null));
  }

  Future<void> _onDismissCenteredMessageRequested(ScannerDismissCenteredMessageRequested event, Emitter<ScannerState> emit) async {
    if (state.centeredErrorMessage != null &&
        state.centeredErrorMessage!.isNotEmpty) {
      add(ScannerAcknowledgeCenteredErrorRequested());
      return;
    }

    if (state.centeredSuccessMessage == null ||
        state.centeredSuccessMessage!.isEmpty) {
      return;
    }

    final ScannerStatus normalizedStatus =
        state.status == ScannerStatus.postSuccess
        ? ScannerStatus.ready
        : state.status;

    emit(
      state.copyWith(
        status: normalizedStatus,
        centeredSuccessMessage: null,
        message: null,
      ),
    );
  }

  Future<void> _onAcknowledgeCenteredErrorRequested(ScannerAcknowledgeCenteredErrorRequested event, Emitter<ScannerState> emit) async {
    if (state.centeredErrorMessage == null ||
        state.centeredErrorMessage!.isEmpty) {
      return;
    }

    try {
      await _enableScanner();
      emit(
        state.copyWith(
          status: ScannerStatus.ready,
          isScannerEnabled: true,
          centeredErrorMessage: null,
          centeredSuccessMessage: null,
          message: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ScannerStatus.error,
          centeredErrorMessage: null,
          centeredSuccessMessage: null,
          message: 'تعذر إعادة تشغيل الماسح.',
        ),
      );
    }
  }

  Future<void> _onSetEnabledRequested(ScannerSetEnabledRequested event, Emitter<ScannerState> emit) async {
    final isEnabled = event.isEnabled;
    if (isEnabled == state.isScannerEnabled) {
      return;
    }

    emit(
      state.copyWith(
        status: ScannerStatus.ready,
        isScannerEnabled: isEnabled,
        message: isEnabled ? null : 'تم إيقاف الماسح.',
        centeredErrorMessage: null,
        centeredSuccessMessage: null,
      ),
    );

    try {
      if (!isEnabled) {
        await _disableScanner();
        return;
      }

      await _enableScanner();

      emit(
        state.copyWith(
          status: ScannerStatus.ready,
          isScannerEnabled: true,
          message: null,
          centeredErrorMessage: null,
          centeredSuccessMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ScannerStatus.error,
          isScannerEnabled: !isEnabled,
          message: 'تعذر تغيير حالة الماسح.',
          centeredErrorMessage: null,
          centeredSuccessMessage: null,
        ),
      );
    }
  }

  Future<void> _onChangeProfileRequested(ScannerChangeProfileRequested event, Emitter<ScannerState> emit) async {
    final String nextProfile = event.profileName.trim();
    if (nextProfile.isEmpty) {
      emit(
        state.copyWith(
          status: ScannerStatus.error,
          message: 'اسم البروفايل لا يمكن أن يكون فارغا.',
          centeredErrorMessage: null,
          centeredSuccessMessage: null,
        ),
      );
      return;
    }

    try {
      await _switchProfile(nextProfile);
      if (state.isScannerEnabled) {
        await _enableScanner();
      }

      emit(
        state.copyWith(
          status: ScannerStatus.ready,
          activeProfile: nextProfile,
          message: null,
          centeredErrorMessage: null,
          centeredSuccessMessage: 'تم تغيير البروفايل بنجاح.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ScannerStatus.error,
          message: 'تعذر تغيير البروفايل.',
          centeredErrorMessage: null,
          centeredSuccessMessage: null,
        ),
      );
    }
  }

  Future<void> _onSaveAdminSettingsRequested(ScannerSaveAdminSettingsRequested event, Emitter<ScannerState> emit) async {
    final String normalizedBaseUrl = event.baseUrl.trim().replaceAll(
      RegExp(r'/+$'),
      '',
    );
    final int? parsedDeviceId = int.tryParse(event.deviceIdText.trim());

    final Uri? parsedUri = Uri.tryParse(normalizedBaseUrl);
    final bool invalidUrl =
        parsedUri == null ||
        parsedUri.host.isEmpty ||
        (parsedUri.scheme != 'http' && parsedUri.scheme != 'https');

    if (invalidUrl) {
      emit(
        state.copyWith(
          status: ScannerStatus.error,
          message: 'الرابط غير صحيح. مثال: http://10.10.30.47:2604',
          centeredErrorMessage: null,
          centeredSuccessMessage: null,
        ),
      );
      event.onResult(false);
      return;
    }

    if (parsedDeviceId == null || parsedDeviceId <= 0) {
      emit(
        state.copyWith(
          status: ScannerStatus.error,
          message: 'رقم الجهاز غير صحيح.',
          centeredErrorMessage: null,
          centeredSuccessMessage: null,
        ),
      );
      event.onResult(false);
      return;
    }

    try {
      await _saveScannerSettings(
        ScannerSettings(
          profileName: state.activeProfile,
          baseUrl: normalizedBaseUrl,
          deviceId: parsedDeviceId,
        ),
      );

      final ScannerSettings persistedSettings = await _getScannerSettings();
      final bool mismatchAfterSave =
          persistedSettings.baseUrl != normalizedBaseUrl ||
          persistedSettings.deviceId != parsedDeviceId;
      if (mismatchAfterSave) {
        throw StateError('تعذر تأكيد حفظ إعدادات الإرسال.');
      }

      emit(
        state.copyWith(
          status: ScannerStatus.ready,
          baseUrl: persistedSettings.baseUrl,
          deviceId: persistedSettings.deviceId,
          message: null,
          centeredErrorMessage: null,
          centeredSuccessMessage:
              'تم حفظ إعدادات الإرسال بنجاح.\n$normalizedBaseUrl',
        ),
      );
      event.onResult(true);
    } catch (_) {
      emit(
        state.copyWith(
          status: ScannerStatus.error,
          message: 'تعذر حفظ الإعدادات.',
          centeredErrorMessage: null,
          centeredSuccessMessage: null,
        ),
      );
      event.onResult(false);
    }
  }

  String _todayKey() {
    final DateTime now = DateTime.now();
    final String year = now.year.toString().padLeft(4, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _buildPalletLabel(int palletCount) {
    return 'B';
  }

  String _buildPostErrorMessage(Object error) {
    final String details = error.toString();
    final String normalizedDetails = details.toLowerCase();
    final String shortDetails = details.replaceAll('\n', ' ').trim();

    if (normalizedDetails.contains('socketexception') ||
        normalizedDetails.contains('failed host lookup') ||
        normalizedDetails.contains('connection refused') ||
        normalizedDetails.contains('timed out')) {
      return 'فشل الإرسال. لا يوجد اتصال بالخادم. تأكد من نفس الشبكة والرابط.';
    }

    if (normalizedDetails.contains('clientexception')) {
      return 'فشل الإرسال. تعذر الاتصال بالخادم. $shortDetails';
    }

    if (normalizedDetails.contains('cleartext http traffic')) {
      return 'فشل الإرسال. اتصال HTTP غير مسموح على الجهاز.';
    }

    final RegExp statusCodePattern = RegExp(r'\(\d{3}\)');
    final Match? statusMatch = statusCodePattern.firstMatch(details);
    if (statusMatch != null) {
      return 'فشل الإرسال. الخادم أرجع كود ${statusMatch.group(0)?.replaceAll(RegExp(r'[\(\)]'), '')}.';
    }

    return 'فشل الإرسال. سبب الخطأ: $shortDetails';
  }

  Future<void> _persistCache({
    required List<ItemBox> itemBoxes,
    required int palletCount,
    required int dailyScanCount,
    required String dailyKey,
  }) {
    return _saveScannerCache(
      ScannerCache(
        itemBoxes: itemBoxes,
        palletCount: palletCount,
        dailyScanCount: dailyScanCount,
        dailyKey: dailyKey,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _scanSubscription?.cancel();
    return super.close();
  }
}
