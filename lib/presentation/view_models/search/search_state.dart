import 'package:equatable/equatable.dart';
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';

enum SearchStatus { initial, loading, success, error }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<ItemBox> items;
  final int totalQty;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.items = const [],
    this.totalQty = 0,
    this.errorMessage,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<ItemBox>? items,
    int? totalQty,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      items: items ?? this.items,
      totalQty: totalQty ?? this.totalQty,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, totalQty, errorMessage];
}
