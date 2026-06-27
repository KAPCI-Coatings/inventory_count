import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/item_box.dart';

abstract class ScannerRemoteDataSource {
  Future<void> postHandlingDetails({
    required String baseUrl,
    required int devId,
    required List<ItemBox> itemBoxes,
  });
}

class ScannerRemoteDataSourceImpl implements ScannerRemoteDataSource {
  static const String _endpoint = '';

  final http.Client _client;

  ScannerRemoteDataSourceImpl(this._client);

  @override
  Future<void> postHandlingDetails({
    required String baseUrl,
    required int devId,
    required List<ItemBox> itemBoxes,
  }) async {
    final String normalizedBaseUrl = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final Uri uri = Uri.parse('$normalizedBaseUrl$_endpoint');
    final String body = jsonEncode(<String, dynamic>{
      'dev_ID': devId,
      'itemBoxes': itemBoxes
          .map((ItemBox itemBox) => itemBox.toApiJson())
          .toList(growable: false),
    });

    final http.Response response = await _client.post(
      uri,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to post data (${response.statusCode}): ${response.body}',
      );
    }
  }
}
