abstract class BarcodeEvent {}

class BarcodeInitializeRequested extends BarcodeEvent {}
class BarcodeClearMessageRequested extends BarcodeEvent {}
class BarcodeDismissCenteredMessageRequested extends BarcodeEvent {}
class BarcodeDuplicatePalletConfirmed extends BarcodeEvent {}
class BarcodeDuplicatePalletRejected extends BarcodeEvent {}
class BarcodePostCurrentOrderRequested extends BarcodeEvent {}
class BarcodeNewOrderRequested extends BarcodeEvent {}
