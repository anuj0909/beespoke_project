import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static const String _baseUrl = 'https://fakestoreapi.com';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client = http.Client();


  Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    AppLogger.i('GET $uri', tag: 'ApiService');

    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException {
      throw const ApiException('No internet connection.');
    } on HttpException {
      throw const ApiException('Network error. Please try again.');
    } on FormatException {
      throw const ApiException('Invalid response format.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }



  Future<List<dynamic>> getProducts() async {
    final data = await get('/products');
    return data as List<dynamic>;
  }

  Future<List<dynamic>> getProductsByCategory(String category) async {
    final data = await get('/products/category/$category');
    return data as List<dynamic>;
  }

  Future<List<dynamic>> getCategories() async {
    final data = await get('/products/categories');
    return data as List<dynamic>;
  }



  dynamic _handleResponse(http.Response response) {
    AppLogger.d(
      'Response ${response.statusCode} — ${response.body.length} bytes',
      tag: 'ApiService',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    switch (response.statusCode) {
      case 400:
        throw ApiException('Bad request.', statusCode: 400);
      case 401:
        throw ApiException('Unauthorised.', statusCode: 401);
      case 403:
        throw ApiException('Forbidden.', statusCode: 403);
      case 404:
        throw ApiException('Resource not found.', statusCode: 404);
      case 500:
      case 502:
      case 503:
        throw ApiException('Server error. Please try again later.',
            statusCode: response.statusCode);
      default:
        throw ApiException(
          'Request failed with status ${response.statusCode}.',
          statusCode: response.statusCode,
        );
    }
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void dispose() => _client.close();
}