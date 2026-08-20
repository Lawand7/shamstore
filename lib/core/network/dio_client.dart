import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import '../../utils/app_localizations.dart';

class DioClient {
  DioClient._();

  static Future<void> Function()? onUnauthorized;
  static bool _isHandlingUnauthorized = false;

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

              options.headers['Accept-Language'] =
                  AppLocalizations.currentLanguageCode;

              if (!_isPublicAuthRequest(options.path) &&
                  token != null &&
                  token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              } else {
                options.headers.remove('Authorization');
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
            onError: (DioException error, handler) async {
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

              if (error.response?.statusCode == 401 &&
                  !_isPublicAuthRequest(error.requestOptions.path)) {
                await _expireLocalSession();
              }

              return handler.next(error);
            },
          ),
        );

  static bool _isPublicAuthRequest(String path) {
    final normalizedPath = path.trim().toLowerCase();

    return <String>{
      ApiConstants.login.toLowerCase(),
      ApiConstants.register.toLowerCase(),
      ApiConstants.sendOtp.toLowerCase(),
      ApiConstants.verifyOtp.toLowerCase(),
      ApiConstants.verifyRegister.toLowerCase(),
      ApiConstants.forgotPassword.toLowerCase(),
    }.contains(normalizedPath);
  }

  static Future<void> _expireLocalSession() async {
    if (_isHandlingUnauthorized || !TokenStorage.isLoggedIn) return;

    _isHandlingUnauthorized = true;

    try {
      await TokenStorage.clear();
      await onUnauthorized?.call();
    } finally {
      _isHandlingUnauthorized = false;
    }
  }
}
