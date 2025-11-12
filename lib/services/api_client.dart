import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smartlocker/config/env.dart';
import 'package:smartlocker/services/auth_service.dart';

class ApiClient {
  final http.Client _client;
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Uri _buildUri(String path, {Map<String, dynamic>? queryParameters}) {
    final parsed = Uri.tryParse(path);
    if (parsed != null && parsed.hasScheme) {
      final mergedQuery = {
        ...parsed.queryParameters,
        if (queryParameters != null) ...queryParameters,
      };
      return parsed.replace(queryParameters: mergedQuery.isEmpty ? null : mergedQuery);
    }

    final cleanBase = Env.apiBaseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    final effectiveBase = cleanBase.isEmpty ? Env.apiBaseUrl.trim() : cleanBase;
    if (effectiveBase.isEmpty) {
      throw StateError('API base URL is not configured.');
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$effectiveBase$cleanPath')
        .replace(queryParameters: queryParameters);
  }

  Future<Map<String, String>> _authHeaders({Map<String, String>? extra}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    final token = AuthService.instance.accessToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (extra != null) headers.addAll(extra);
    return headers;
  }

  Future<http.Response> _sendWithRetry(
    Future<http.Response> Function(Map<String, String> headers) sender, {
    Map<String, String>? extraHeaders,
  }) async {
    Future<Map<String, String>> buildHeaders() =>
        _authHeaders(extra: extraHeaders);

    Future<http.Response> send() async => sender(await buildHeaders());

    var response = await send();
    if (response.statusCode == 401 && AuthService.instance.hasRefreshToken) {
      final refreshed = await AuthService.instance.refresh();
      if (refreshed) {
        response = await send();
      }
    }
    _throwIfError(response);
    return response;
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode >= 400) {
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['detail'] != null) {
          throw ApiException(body['detail'].toString(),
              statusCode: response.statusCode);
        }
        if (body is Map && body['error'] != null) {
          throw ApiException(body['error'].toString(),
              statusCode: response.statusCode);
        }
      } catch (_) {
        // ignore parsing errors, fall through
      }
      throw ApiException('Request failed with status ${response.statusCode}',
          statusCode: response.statusCode);
    }
  }

  Future<http.Response> multipart(
    String method,
    String path, {
    Map<String, String>? fields,
    Map<String, String>? headers,
    Map<String, String>? files,
  }) async {
    Future<http.Response> sendRequest() async {
      final request =
          http.MultipartRequest(method.toUpperCase(), _buildUri(path));
      request.headers.addAll(await _authHeaders(extra: headers));
      if (fields != null) {
        request.fields.addAll(fields);
      }
      if (files != null) {
        for (final entry in files.entries) {
          request.files
              .add(await http.MultipartFile.fromPath(entry.key, entry.value));
        }
      }
      final streamed = await request.send();
      return http.Response.fromStream(streamed);
    }

    var response = await sendRequest();
    if (response.statusCode == 401 && AuthService.instance.hasRefreshToken) {
      final refreshed = await AuthService.instance.refresh();
      if (refreshed) {
        response = await sendRequest();
      }
    }
    _throwIfError(response);
    return response;
  }

  Future<http.Response> get(String path, {Map<String, dynamic>? query}) {
    return _sendWithRetry(
      (h) => _client.get(_buildUri(path, queryParameters: query), headers: h),
    );
  }

  Future<http.Response> post(String path,
      {Object? body, Map<String, String>? headers}) {
    return _sendWithRetry(
      (h) => _client.post(
        _buildUri(path),
        headers: {...h, ...?headers},
        body: body == null ? null : (body is String ? body : jsonEncode(body)),
      ),
      extraHeaders: const {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> multipartPost(
    String path, {
    Map<String, String>? fields,
    Map<String, String>? files,
    Map<String, String>? headers,
  }) {
    return multipart('POST', path,
        fields: fields, files: files, headers: headers);
  }

  Future<http.Response> put(String path,
      {Object? body, Map<String, String>? headers}) {
    return _sendWithRetry(
      (h) => _client.put(
        _buildUri(path),
        headers: {...h, ...?headers},
        body: body == null ? null : (body is String ? body : jsonEncode(body)),
      ),
      extraHeaders: const {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> delete(String path, {Map<String, String>? headers}) {
    return _sendWithRetry(
      (h) => _client.delete(_buildUri(path), headers: {...h, ...?headers}),
    );
  }
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => statusCode != null ? '$statusCode: $message' : message;
}
