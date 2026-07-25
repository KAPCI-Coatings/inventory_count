import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:inventory_count_flutter_app/domain/entities/barcode.dart';

/// Result of a POST attempt to the backend.
class ApiPostResult {
  final bool success;

  /// Short error key for localisation (matches a key in the .arb files).
  /// `null` when [success] is `true`.
  final String? errorKey;

  /// Extra detail string used as a placeholder inside some error messages.
  final String? details;

  const ApiPostResult.success()
      : success = true,
        errorKey = null,
        details = null;

  const ApiPostResult.failure(this.errorKey, {this.details}) : success = false;
}

/// Handles all HTTP communication with the backend.
///
/// The singleton is registered via GetIt in `di.dart`.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Normalizes the base URL configured in Admin Settings.
  /// Handles values like `http://localhost:5264/swagger/`, `http://localhost:5264/swagger`,
  /// or `http://localhost:5264/` and strips trailing `/swagger` paths and slashes.
  String _normalizeBaseUrl(String baseUrl) {
    String clean = baseUrl.trim();
    // Strip trailing slashes
    clean = clean.replaceAll(RegExp(r'/+$'), '');
    // Strip /swagger or /swagger/index.html if entered by admin
    clean = clean.replaceAll(RegExp(r'/swagger(/index\.html)?$', caseSensitive: false), '');
    clean = clean.replaceAll(RegExp(r'/+$'), '');
    return clean;
  }

  Map<String, dynamic> _itemToInventoryCountJson(ItemBox item, String devId) {
    // Backend requires ALL fields non-null and non-empty (including SerialNo, PalletBox).
    final String palletBox = item.palletBox.isNotEmpty ? item.palletBox : 'B';
    final String serialNo = item.serialNo.isNotEmpty ? item.serialNo : '0000';
    final int palletNo = (item.palletNo != null && item.palletNo! > 0)
        ? item.palletNo!
        : (int.tryParse(item.palletBox) ?? 1);

    return {
      'devId': devId,
      'matnr': item.matnr,
      'batchNo': item.batchNo,
      'qty': item.qty.toDouble(),
      'serialNo': serialNo,
      'palletBox': palletBox,
      'palletNo': palletNo,
    };
  }

  /// POSTs all scanned inventory items to `POST {baseUrl}/api/InventoryCount?Count={count}`.
  ///
  /// The request body is a JSON Array:
  /// ```json
  /// [
  ///   {
  ///     "devId": "002",
  ///     "matnr": "123456",
  ///     "batchNo": "0000000000",
  ///     "qty": 25,
  ///     "serialNo": "Z025",
  ///     "palletBox": "P",
  ///     "palletNo": 1
  ///   }
  /// ]
  /// ```
  Future<ApiPostResult> sendInventoryData({
    required String baseUrl,
    required String devId,
    required List<ItemBox> items,
    required int count,
  }) async {
    if (baseUrl.trim().isEmpty) {
      return const ApiPostResult.failure('error_invalid_url');
    }

    final String normalizedBaseUrl = _normalizeBaseUrl(baseUrl);
    final Uri uri = Uri.parse('$normalizedBaseUrl/api/InventoryCount').replace(
      queryParameters: {
        'count': count.toString(),
      },
    );

    final List<Map<String, dynamic>> bodyList =
        items.map((item) => _itemToInventoryCountJson(item, devId)).toList();
    final String jsonPayload = jsonEncode(bodyList);

    debugPrint('[ApiService] POST $uri — ${items.length} item(s), Count=$count');
    debugPrint('[ApiService] Payload: $jsonPayload');

    try {
      final http.Response response = await _client
          .post(
            uri,
            headers: {
              HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
              HttpHeaders.acceptHeader: 'application/json',
            },
            body: jsonPayload,
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[ApiService] Response status: ${response.statusCode}');
      debugPrint('[ApiService] Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const ApiPostResult.success();
      }

      return ApiPostResult.failure(
        'error_post_server_code',
        details: '${response.statusCode}: ${response.body}',
      );
    } on SocketException catch (e) {
      debugPrint('[ApiService] SocketException: $e');
      return const ApiPostResult.failure('error_post_no_connection');
    } on HandshakeException catch (e) {
      debugPrint('[ApiService] HandshakeException (cleartext?): $e');
      return const ApiPostResult.failure('error_post_http_not_allowed');
    } catch (e) {
      debugPrint('[ApiService] Unknown error: $e');
      return ApiPostResult.failure('error_post_unknown', details: e.toString());
    }
  }

  void dispose() => _client.close();
}
