import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/domain/entities/item_box.dart';
import 'package:inventory_count_flutter_app/domain/uescases/load_scanner_cache_usecase.dart';

import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final LoadScannerCacheUseCase loadScannerCache;

  SearchBloc({required this.loadScannerCache}) : super(const SearchState()) {
    on<SearchDataLoaded>(_onSearchDataLoaded);
    on<SearchMaterialChanged>(_onSearchMaterialChanged);
    on<SearchBatchFilterChanged>(_onSearchBatchFilterChanged);
    on<SearchSubmitClicked>(_onSearchSubmitClicked);
    on<SearchClearRequested>(_onSearchClearRequested);
  }

  Future<void> _onSearchDataLoaded(
    SearchDataLoaded event,
    Emitter<SearchState> emit,
  ) async {
    emit(state.copyWith(status: SearchStatus.loading));
    try {
      final cache = await loadScannerCache();
      final allItems = cache.itemBoxes;

      emit(
        state.copyWith(
          status: SearchStatus.loaded,
          allItems: allItems,
          filteredItems: allItems, // Initially display all or none depending on req. Let's just pass all for now.
        ),
      );
      // Initialize available batches but don't populate table yet
      _updateAvailableBatches(emit);
    } catch (e) {
      emit(state.copyWith(status: SearchStatus.error));
    }
  }

  void _onSearchMaterialChanged(
    SearchMaterialChanged event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(material: event.material));
    _updateAvailableBatches(emit);
  }

  void _onSearchBatchFilterChanged(
    SearchBatchFilterChanged event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWith(selectedBatch: event.batch));
  }

  void _onSearchSubmitClicked(
    SearchSubmitClicked event,
    Emitter<SearchState> emit,
  ) {
    _applyFilters(emit);
  }

  void _onSearchClearRequested(
    SearchClearRequested event,
    Emitter<SearchState> emit,
  ) {
    emit(state.copyWithNullBatch(material: ''));
    _updateAvailableBatches(emit);
    _applyFilters(emit);
  }

  void _updateAvailableBatches(Emitter<SearchState> emit) {
    List<ItemBox> filtered = state.allItems;
    if (state.material.trim().isNotEmpty) {
      filtered = filtered.where((item) => item.matnr == state.material.trim() || item.barCodeNo == state.material.trim()).toList();
    }
    
    // Calculate total qty for the material
    int totalQty = 0;
    for (var item in filtered) {
      totalQty += item.qty;
    }

    final Set<String> batches = {'All'};
    for (var item in filtered) {
      if (item.batchNo.isNotEmpty) {
        batches.add(item.batchNo);
      }
    }
    
    String? currentBatch = state.selectedBatch;
    if (currentBatch != null && currentBatch != 'All' && !batches.contains(currentBatch)) {
      currentBatch = null;
    }

    if (currentBatch == null) {
      emit(state.copyWithNullBatch(availableBatches: batches.toList()..sort(), totalQty: totalQty));
    } else {
      emit(state.copyWith(selectedBatch: currentBatch, availableBatches: batches.toList()..sort(), totalQty: totalQty));
    }
  }

  void _applyFilters(Emitter<SearchState> emit) {
    List<ItemBox> filtered = state.allItems;
    
    // Filter by material if not empty
    if (state.material.trim().isNotEmpty) {
      filtered = filtered.where((item) => item.matnr == state.material.trim() || item.barCodeNo == state.material.trim()).toList();
    }

    // Calculate total qty (before batch filter)
    int totalQty = 0;
    for (var item in filtered) {
      totalQty += item.qty;
    }

    // Filter by batch
    String? currentBatch = state.selectedBatch;
    if (currentBatch != null && currentBatch != 'All') {
      filtered = filtered.where((item) => item.batchNo == currentBatch).toList();
    }

    if (currentBatch == null) {
      emit(
        state.copyWithNullBatch(
          filteredItems: filtered,
          totalQty: totalQty,
        ),
      );
    } else {
      emit(
        state.copyWith(
          filteredItems: filtered,
          totalQty: totalQty,
        ),
      );
    }
  }
}
