import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/error/barcode_exceptions.dart';
import 'package:inventory_count_flutter_app/core/services/api_service.dart';
import 'package:inventory_count_flutter_app/core/services/scanner_service.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';
import 'package:inventory_count_flutter_app/data/datasources/settings_local_datasource.dart';
import 'package:inventory_count_flutter_app/domain/repositories/barcode_repository.dart';
import 'package:inventory_count_flutter_app/domain/uescases/process_barcode_usecase.dart';
import 'barcode_event.dart';
import 'barcode_state.dart';

class BarcodeBloc extends Bloc<BarcodeEvent, BarcodeState> {
  final ScannerService _scannerService;
  final ProcessBarcodeUseCase _processBarcodeUseCase;
  final ApiService _apiService;
  final SettingsLocalDataSource _settingsDataSource;
  final BarcodeRepository _barcodeRepository;
  StreamSubscription<ScanResult>? _scanSubscription;
  bool _isProcessingScan = false;

  BarcodeBloc(
    this._scannerService,
    this._processBarcodeUseCase,
    this._apiService,
    this._settingsDataSource,
    this._barcodeRepository,
  ) : super(const BarcodeState()) {
    on<BarcodeInitializeRequested>((event, emit) async {
      debugPrint('[BarcodeBloc] BarcodeInitializeRequested — loading cached items from DB');
      final dbItems = await _barcodeRepository.getScannedItems();
      if (dbItems.isNotEmpty) {
        int boxCount = 0;
        int palletCount = 0;
        int palletBoxCount = 0;

        for (final item in dbItems) {
          if (item.isPallet) {
            palletCount += 1;
            palletBoxCount += 1;
            boxCount += item.qty;
          } else {
            boxCount += 1;
            palletBoxCount += 1;
          }
        }

        emit(state.copyWith(
          itemBoxes: dbItems,
          lastScan: dbItems.last,
          boxCount: boxCount,
          palletCount: palletCount,
          palletBoxCount: palletBoxCount,
        ));
      }
    });

    on<BarcodeClearMessageRequested>((event, emit) {
      _scannerService.enableScanner().catchError((_) {});
      emit(state.copyWith(
        message: null,
        centeredErrorMessage: null,
        centeredSuccessMessage: null,
        centeredWarningMessage: null,
        status: BarcodeStatus.initial,
      ));
    });

    on<BarcodeDismissCenteredMessageRequested>((event, emit) {
      _scannerService.enableScanner().catchError((_) {});
      emit(state.copyWith(
        centeredErrorMessage: null,
        centeredSuccessMessage: null,
        centeredWarningMessage: null,
        status: BarcodeStatus.initial,
      ));
    });

    on<BarcodeDuplicateConfirmed>((event, emit) async {
      final itemBox = state.lastScan;
      if (itemBox == null) return;

      // Save to database now that user confirmed
      await _barcodeRepository.saveScannedBarcode(itemBox);

      final updatedItems = List.of(state.itemBoxes)..add(itemBox);

      int boxCount = state.boxCount;
      int palletCount = state.palletCount;
      int palletBoxCount = state.palletBoxCount;

      if (itemBox.isPallet) {
        palletCount += 1;
        palletBoxCount += 1;
        boxCount += itemBox.qty;
      } else {
        boxCount += 1;
        palletBoxCount += 1;
      }

      emit(state.copyWith(
        status: BarcodeStatus.success,
        itemBoxes: updatedItems,
        boxCount: boxCount,
        palletCount: palletCount,
        palletBoxCount: palletBoxCount,
        dailyScanCount: state.dailyScanCount + 1,
        centeredWarningMessage: null,
      ));

      _scannerService.enableScanner().catchError((_) {});
    });

    on<BarcodeDuplicateRejected>((event, emit) {
      emit(state.copyWith(
        status: BarcodeStatus.initial,
        centeredWarningMessage: null,
      ));
      _scannerService.enableScanner().catchError((_) {});
    });

    // ── Send to Backend ─────────────────────────────────────────────────────
    on<BarcodePostCurrentOrderRequested>(_onPostCurrentOrder);

    // ── Clear Screen & Cache ──────────────────────────────────────────────────
    on<BarcodeNewOrderRequested>((event, emit) async {
      debugPrint('[BarcodeBloc] BarcodeNewOrderRequested — clearing cache DB and resetting screen');
      await _barcodeRepository.clearSession();
      emit(const BarcodeState());
      // Re-enable scanner after reset so the next scan works immediately
      _scannerService.enableScanner().catchError((_) {});
    });

    // ── Hard Reset ───────────────────────────────────────────────────────────
    on<BarcodeResetRequested>((event, emit) {
      debugPrint('[BarcodeBloc] BarcodeResetRequested — clearing session state');
      emit(const BarcodeState());
    });

    // ── Scanner Control ──────────────────────────────────────────────────────
    on<BarcodeScannerEnableRequested>((event, emit) async {
      debugPrint('[BarcodeBloc] BarcodeScannerEnableRequested received');
      try {
        _scanSubscription ??= _scannerService.onScan.listen(
          (result) {
            debugPrint(
              '[BarcodeBloc] ★ SCAN RECEIVED from stream: "${result.data}" label=${result.labelType}',
            );
            add(BarcodeScanned(result.data, result.labelType));
          },
          onError: (error) {
            debugPrint('[BarcodeBloc] ★ SCAN STREAM ERROR: $error');
          },
        );
        debugPrint('[BarcodeBloc] Scanner stream listener active');

        await _scannerService.enableScanner();
        debugPrint('[BarcodeBloc] Scanner enabled successfully');
      } catch (e) {
        debugPrint('[BarcodeBloc] ERROR enabling scanner: $e');
      }
    });

    on<BarcodeScannerDisableRequested>((event, emit) async {
      debugPrint('[BarcodeBloc] BarcodeScannerDisableRequested received (no-op)');
    });

    // ── Barcode Scanned ──────────────────────────────────────────────────────
    on<BarcodeScanned>(_onBarcodeScanned);
  }

  // ── Event Handlers ──────────────────────────────────────────────────────────

  Future<void> _onBarcodeScanned(
    BarcodeScanned event,
    Emitter<BarcodeState> emit,
  ) async {
    if (_isProcessingScan || state.status == BarcodeStatus.warning) {
      debugPrint('[BarcodeBloc] Ignored scan while processing/warning: "${event.barcode}"');
      return;
    }
    
    _isProcessingScan = true;
    
    debugPrint(
      '[BarcodeBloc] BarcodeScanned received: "${event.barcode}" (${event.barcode.length} chars)',
    );

    try {
      final cleanBarcode = event.barcode.trim();
      debugPrint(
        '[BarcodeBloc] Clean barcode: "$cleanBarcode" (${cleanBarcode.length} chars)',
      );

      final result = await _processBarcodeUseCase(cleanBarcode);
      final itemBox = result.itemBox;

      debugPrint(
        '[BarcodeBloc] UseCase returned: matnr=${itemBox.matnr}, batch=${itemBox.batchNo}, isPallet=${itemBox.isPallet}, qty=${itemBox.qty}, isDuplicate=${result.isDuplicate}',
      );

      if (result.isDuplicate) {
        debugPrint('[BarcodeBloc] DUPLICATE detected: $cleanBarcode');
        
        if (!itemBox.isPallet) {
          debugPrint('[BarcodeBloc] Box duplicate. Emitting error state.');
          await _scannerService.disableScanner();
          emit(state.copyWith(
            status: BarcodeStatus.error,
            centeredErrorMessage: 'error_box_duplicate',
          ));
          return;
        }

        // Do NOT update lists or counters yet. Save it in lastScan for confirmation.
        emit(state.copyWith(
          status: BarcodeStatus.warning,
          lastScan: itemBox,
          centeredWarningMessage: 'warning_duplicate_barcode',
          message: 'warning_duplicate_barcode',
        ));
      } else {
        final updatedItems = List.of(state.itemBoxes)..add(itemBox);
        int boxCount = state.boxCount;
        int palletCount = state.palletCount;
        int palletBoxCount = state.palletBoxCount;

        if (itemBox.isPallet) {
          palletCount += 1;
          palletBoxCount += 1;
          boxCount += itemBox.qty;
        } else {
          boxCount += 1;
          palletBoxCount += 1;
        }

        // Success
        emit(BarcodeState(
          status: BarcodeStatus.success,
          itemBoxes: updatedItems,
          lastScan: itemBox,
          boxCount: boxCount,
          palletCount: palletCount,
          palletBoxCount: palletBoxCount,
          dailyScanCount: state.dailyScanCount + 1,
          message: 'success_barcode_scanned',
        ));
      }
    } on InvalidBarcodeFormatException catch (e) {
      debugPrint('[BarcodeBloc] INVALID FORMAT: ${e.message}');
      emit(BarcodeState(
        status: BarcodeStatus.error,
        itemBoxes: state.itemBoxes,
        lastScan: state.lastScan,
        boxCount: state.boxCount,
        palletCount: state.palletCount,
        palletBoxCount: state.palletBoxCount,
        dailyScanCount: state.dailyScanCount,
        centeredErrorMessage: e.message, // already a localisation key
      ));
    } catch (e, stackTrace) {
      debugPrint('[BarcodeBloc] UNEXPECTED ERROR: $e\n$stackTrace');
      emit(BarcodeState(
        status: BarcodeStatus.error,
        itemBoxes: state.itemBoxes,
        lastScan: state.lastScan,
        boxCount: state.boxCount,
        palletCount: state.palletCount,
        palletBoxCount: state.palletBoxCount,
        dailyScanCount: state.dailyScanCount,
        centeredErrorMessage: 'error_unexpected_scan',
      ));
    } finally {
      _isProcessingScan = false;
    }
  }

  Future<void> _onPostCurrentOrder(
    BarcodePostCurrentOrderRequested event,
    Emitter<BarcodeState> emit,
  ) async {
    // Always load cached items from SQLite DB to ensure all cached items are sent
    final dbItems = await _barcodeRepository.getScannedItems();
    final allItems = dbItems.isNotEmpty ? dbItems : state.itemBoxes;
    
    final itemsToSend = allItems.where((item) => !item.isSent).toList();

    if (itemsToSend.isEmpty) {
      emit(state.copyWith(
        status: BarcodeStatus.error,
        centeredErrorMessage: 'error_no_scanned_data',
      ));
      return;
    }

    final String baseUrl = _settingsDataSource.getBaseUrl() ?? '';
    final String devId = _settingsDataSource.getDevId() ?? '';

    if (baseUrl.trim().isEmpty) {
      emit(state.copyWith(
        status: BarcodeStatus.error,
        centeredErrorMessage: 'error_invalid_url',
      ));
      return;
    }

    final int countToSend = itemsToSend.length;

    debugPrint('[BarcodeBloc] Sending ${itemsToSend.length} items to $baseUrl (Count=$countToSend)');
    emit(state.copyWith(status: BarcodeStatus.posting, isSending: true));

    final ApiPostResult result = await _apiService.sendInventoryData(
      baseUrl: baseUrl,
      devId: devId,
      items: itemsToSend,
      count: countToSend,
    );

    if (result.success) {
      debugPrint('[BarcodeBloc] POST success — keeping data in cache & on screen');
      
      final sentBarcodes = itemsToSend.map((e) => e.barCodeNo).toList();
      await _barcodeRepository.markAsSent(sentBarcodes);
      
      final updatedItemBoxes = state.itemBoxes.map((item) {
        if (sentBarcodes.contains(item.barCodeNo)) {
          return ItemBox(
            barCodeNo: item.barCodeNo,
            matnr: item.matnr,
            batchNo: item.batchNo,
            serialNo: item.serialNo,
            palletBox: item.palletBox,
            qty: item.qty,
            isPallet: item.isPallet,
            palletNo: item.palletNo,
            isSent: true,
          );
        }
        return item;
      }).toList();
      
      emit(state.copyWith(
        status: BarcodeStatus.success,
        itemBoxes: updatedItemBoxes,
        isSending: false,
        sendResultMessage: 'success_post_clear_cache',
        centeredSuccessMessage: 'success_post_clear_cache',
      ));
      _scannerService.enableScanner().catchError((_) {});
    } else {
      debugPrint('[BarcodeBloc] POST failed: ${result.errorKey} — ${result.details}');
      emit(state.copyWith(
        status: BarcodeStatus.error,
        isSending: false,
        sendResultMessage: result.errorKey,
        centeredErrorMessage: result.errorKey,
      ));
    }
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }
}
