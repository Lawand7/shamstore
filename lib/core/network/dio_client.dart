import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class DioClient {
  DioClient._();

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 90),
            receiveTimeout: const Duration(seconds: 90),
            sendTimeout: const Duration(seconds: 90),
            headers: {'Accept': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              final token = TokenStorage.getToken();

              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }

              debugPrint('========== API REQUEST ==========');
              debugPrint('${options.method} ${options.baseUrl}${options.path}');
              debugPrint('Headers: ${options.headers}');
              debugPrint('Query: ${options.queryParameters}');
              debugPrint('=================================');

              return handler.next(options);
            },
            onResponse: (response, handler) {
              debugPrint('========== API RESPONSE ==========');
              debugPrint('Status: ${response.statusCode}');
              debugPrint('Data: ${response.data}');
              debugPrint('==================================');

              return handler.next(response);
            },
            onError: (DioException error, handler) {
              debugPrint('========== API ERROR ==========');
              debugPrint('Type: ${error.type}');
              debugPrint('Status: ${error.response?.statusCode}');
              debugPrint('Message: ${error.message}');
              debugPrint('Data: ${error.response?.data}');
              debugPrint('================================');

              return handler.next(error);
            },
          ),
        );
}
