class ItemBox {
  final String barCodeNo;
  final String matnr;
  final String batchNo;
  final String serialNo;
  final String palletBox;
  final int qty;
  final bool isPallet;
  final int? palletNo;

  const ItemBox({
    this.barCodeNo = '',
    this.matnr = '',
    this.batchNo = '',
    this.serialNo = '',
    this.palletBox = '',
    this.qty = 0,
    this.isPallet = false,
    this.palletNo,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemBox &&
          runtimeType == other.runtimeType &&
          barCodeNo == other.barCodeNo;

  @override
  int get hashCode => barCodeNo.hashCode;
}
