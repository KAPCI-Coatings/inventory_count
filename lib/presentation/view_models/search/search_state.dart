import 'package:equatable/equatable.dart';
import 'package:inventory_count_flutter_app/domain/entities/item_box.dart';

enum SearchStatus { initial, loading, loaded, error }

class SearchState extends Equatable {
  final SearchStatus status;
  final String material;
  final String? selectedBatch;
  final List<ItemBox> allItems;
  final List<ItemBox> filteredItems;
  final List<String> availableBatches;
  final int totalQty;

  const SearchState({
    this.status = SearchStatus.initial,
    this.material = '',
    this.selectedBatch,
    this.allItems = const [],
    this.filteredItems = const [],
    this.availableBatches = const [],
    this.totalQty = 0,
  });

  SearchState copyWith({
    SearchStatus? status,
    String? material,
    String? selectedBatch,
    List<ItemBox>? allItems,
    List<ItemBox>? filteredItems,
    List<String>? availableBatches,
    int? totalQty,
  }) {
    return SearchState(
      status: status ?? this.status,
      material: material ?? this.material,
      selectedBatch: selectedBatch ?? this.selectedBatch,
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      availableBatches: availableBatches ?? this.availableBatches,
      totalQty: totalQty ?? this.totalQty,
    );
  }

  SearchState copyWithNullBatch({
    SearchStatus? status,
    String? material,
    List<ItemBox>? allItems,
    List<ItemBox>? filteredItems,
    List<String>? availableBatches,
    int? totalQty,
  }) {
    return SearchState(
      status: status ?? this.status,
      material: material ?? this.material,
      selectedBatch: null,
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      availableBatches: availableBatches ?? this.availableBatches,
      totalQty: totalQty ?? this.totalQty,
    );
  }

  @override
  List<Object?> get props => [
        status,
        material,
        selectedBatch,
        allItems,
        filteredItems,
        availableBatches,
        totalQty,
      ];
}
