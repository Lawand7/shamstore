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

              options.extra['requestStartedAt'] = DateTime.now();
              debugPrint('[API REQUEST] ${options.method} ${options.path}');

              return handler.next(options);
            },
            onResponse: (response, handler) {
              final startedAt =
                  response.requestOptions.extra['requestStartedAt'];
              final durationMs = startedAt is DateTime
                  ? DateTime.now().difference(startedAt).inMilliseconds
                  : null;

              debugPrint(
                '[API RESPONSE] ${response.requestOptions.method} '
                '${response.requestOptions.path} '
                'status=${response.statusCode} '
                'durationMs=${durationMs ?? 'unknown'}',
              );

              return handler.next(response);
            },
            onError: (DioException error, handler) {
              final startedAt = error.requestOptions.extra['requestStartedAt'];
              final durationMs = startedAt is DateTime
                  ? DateTime.now().difference(startedAt).inMilliseconds
                  : null;

              debugPrint(
                '[API ERROR] ${error.requestOptions.method} '
                '${error.requestOptions.path} '
                'status=${error.response?.statusCode ?? 'none'} '
                'type=${error.type} '
                'durationMs=${durationMs ?? 'unknown'}',
              );

              return handler.next(error);
            },
          ),
        );
}
