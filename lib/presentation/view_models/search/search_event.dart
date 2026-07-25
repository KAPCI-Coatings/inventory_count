import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchInitialized extends SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String matnr;
  final String batchNo;

  const SearchQueryChanged({required this.matnr, required this.batchNo});

  @override
  List<Object?> get props => [matnr, batchNo];
}
