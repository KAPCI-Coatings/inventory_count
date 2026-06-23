import 'item_box.dart';

class ScannerCache {
  final List<ItemBox> itemBoxes;
  final int palletCount;
  final int dailyScanCount;
  final String dailyKey;

  const ScannerCache({
    this.itemBoxes = const <ItemBox>[],
    this.palletCount = 1,
    this.dailyScanCount = 0,
    this.dailyKey = '',
  });

  ScannerCache copyWith({
    List<ItemBox>? itemBoxes,
    int? palletCount,
    int? dailyScanCount,
    String? dailyKey,
  }) {
    return ScannerCache(
      itemBoxes: itemBoxes ?? this.itemBoxes,
      palletCount: palletCount ?? this.palletCount,
      dailyScanCount: dailyScanCount ?? this.dailyScanCount,
      dailyKey: dailyKey ?? this.dailyKey,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'itemBoxes': itemBoxes
          .map((ItemBox itemBox) => itemBox.toCacheJson())
          .toList(growable: false),
      'palletCount': palletCount,
      'dailyScanCount': dailyScanCount,
      'dailyKey': dailyKey,
    };
  }

  factory ScannerCache.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems =
        (json['itemBoxes'] as List<dynamic>?) ?? const <dynamic>[];

    return ScannerCache(
      itemBoxes: rawItems
          .whereType<Map<String, dynamic>>()
          .map(ItemBox.fromCacheJson)
          .toList(growable: false),
      palletCount: (json['palletCount'] as num?)?.toInt() ?? 1,
      dailyScanCount: (json['dailyScanCount'] as num?)?.toInt() ?? 0,
      dailyKey: (json['dailyKey'] as String?) ?? '',
    );
  }
}
