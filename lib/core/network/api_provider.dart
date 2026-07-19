import 'package:dio/dio.dart';

import '../../config/app_helper/app_extension.dart';
import 'accept_language.dart';

enum RequestType { post, get, put, delete }

/// Starter-kit Dio HTTP boundary (FEAT-04 AC-C1).
///
/// Registered in DI with `BASE_URL`, `Accept-Language`, and optional bearer.
class ApiProvider {
  ApiProvider(this._dio);

  final Dio _dio;

  Dio get dio => _dio;

  /// Builds a configured [ApiProvider] for DI.
  factory ApiProvider.create({
    required String baseUrl,
    required String Function() languageCode,
    String? Function()? accessToken,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers[AcceptLanguage.headerName] = AcceptLanguage.normalize(
            languageCode(),
          );
          final token = accessToken?.call();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    return ApiProvider(dio);
  }

  Future<dynamic> requestAPI({
    required String url,
    dynamic body,
    Map<String, String>? headers,
    RequestType type = RequestType.post,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        url,
        options: Options(method: type.name.capitalize(), headers: headers),
        data: body,
      );

      final code = response.statusCode ?? 0;
      if (code == 200 || code == 201 || code == 204 || code == 206) {
        return response.data;
      }

      final data = response.data;
      if (data is Map) {
        throw Exception(data['message'] ?? 'error from server');
      }
      throw Exception('error from server ($code)');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('please check internet connection');
      }
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        final nested = data['error'];
        if (nested is Map && nested['message'] != null) {
          throw Exception(nested['message']);
        }
        throw Exception(data['message'] ?? 'an error occurred');
      }
      rethrow;
    }
  }
}
