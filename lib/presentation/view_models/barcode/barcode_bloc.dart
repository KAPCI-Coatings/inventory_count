import 'package:flutter_bloc/flutter_bloc.dart';
import 'barcode_event.dart';
import 'barcode_state.dart';

class BarcodeBloc extends Bloc<BarcodeEvent, BarcodeState> {
  BarcodeBloc() : super(const BarcodeState()) {
    on<BarcodeInitializeRequested>((event, emit) {});
    on<BarcodeClearMessageRequested>((event, emit) {});
    on<BarcodeDismissCenteredMessageRequested>((event, emit) {});
    on<BarcodeDuplicatePalletConfirmed>((event, emit) {});
    on<BarcodeDuplicatePalletRejected>((event, emit) {});
    on<BarcodePostCurrentOrderRequested>((event, emit) {});
    on<BarcodeNewOrderRequested>((event, emit) {});
  }
}
