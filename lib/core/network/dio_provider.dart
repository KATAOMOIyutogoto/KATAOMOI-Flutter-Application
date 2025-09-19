import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/env_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  
  // ベースURLを設定
  dio.options.baseUrl = '${EnvConstants.baseUrl}/rest/v1';
  dio.options.connectTimeout = EnvConstants.apiTimeout;
  dio.options.receiveTimeout = EnvConstants.apiTimeout;
  
  // ログインターセプター
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
  ));
  
  return dio;
});

