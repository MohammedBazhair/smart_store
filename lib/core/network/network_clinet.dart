import 'package:http/http.dart' as http;

import 'network_response.dart';

abstract class NetworkClient {
  Future<NetworkResponse> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  });

  Future<NetworkResponse> get(String url, {Map<String, String>? headers});
}

class NetworkClientImpl implements NetworkClient {
  NetworkClientImpl(this._client);

  final http.Client _client;

  @override
  Future<NetworkResponse> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await _client.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    return NetworkResponse(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  @override
  Future<NetworkResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.get(Uri.parse(url), headers: headers);

    return NetworkResponse(
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}
