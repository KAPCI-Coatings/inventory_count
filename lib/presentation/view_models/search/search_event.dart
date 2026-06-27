import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchDataLoaded extends SearchEvent {}

class SearchMaterialChanged extends SearchEvent {
  final String material;

  const SearchMaterialChanged(this.material);

  @override
  List<Object?> get props => [material];
}

class SearchBatchFilterChanged extends SearchEvent {
  final String? batch;

  const SearchBatchFilterChanged(this.batch);

  @override
  List<Object?> get props => [batch];
}

class SearchSubmitClicked extends SearchEvent {}

class SearchClearRequested extends SearchEvent {}
