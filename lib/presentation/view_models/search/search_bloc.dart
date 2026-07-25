import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/domain/repositories/barcode_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final BarcodeRepository _barcodeRepository;

  SearchBloc(this._barcodeRepository) : super(const SearchState()) {
    on<SearchInitialized>(_onInitialized);
    on<SearchQueryChanged>(_onQueryChanged);
  }

  Future<void> _onInitialized(SearchInitialized event, Emitter<SearchState> emit) async {
    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final items = await _barcodeRepository.getScannedItems();
      final totalQty = items.fold<int>(0, (sum, item) => sum + item.qty);
      emit(state.copyWith(
        status: SearchStatus.success,
        items: items,
        totalQty: totalQty,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) async {
    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final items = await _barcodeRepository.getScannedItems(
        matnr: event.matnr,
        batchNo: event.batchNo,
      );
      final totalQty = items.fold<int>(0, (sum, item) => sum + item.qty);
      emit(state.copyWith(
        status: SearchStatus.success,
        items: items,
        totalQty: totalQty,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SearchStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
