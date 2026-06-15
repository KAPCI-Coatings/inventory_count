import 'package:flutter_bloc/flutter_bloc.dart';

//ــــــــــــــــــ Barcode Events ــــــــــــــــــ
sealed class BarcodeEvent {}

class AddNewBarcodeEvent extends BarcodeEvent {
  final String barcode;

  AddNewBarcodeEvent(this.barcode);
}

//ــــــــــــــــــ Barcode State ــــــــــــــــــ
class BarcodeState {}

//ــــــــــــــــــ Barcode Bloc ــــــــــــــــــ
class BarcodeOperationsBloc extends Bloc<BarcodeEvent, BarcodeState> {
  BarcodeOperationsBloc() : super(BarcodeState()) {
    on<AddNewBarcodeEvent>(_addBarcode);
  }

  void _addBarcode(BarcodeEvent event, Emitter<BarcodeState> emit) {
    if(event is AddNewBarcodeEvent) {

    }
  }
}

