import 'package:flutter/foundation.dart';
import '../constants/env_constants.dart';

class DebugHelper {
  static void printEnvironmentInfo() {
    if (kDebugMode) {
      print('🔧 環境変数設定:');
      print('  SUPABASE_URL: ${EnvConstants.supabaseUrl}');
      print('  SUPABASE_ANON_KEY: ${EnvConstants.supabaseAnonKey.isNotEmpty ? "設定済み" : "未設定"}');
      print('  APP_DEEP_LINK_SCHEME: ${EnvConstants.appDeepLinkScheme}');
      print('  GO_DOMAIN: ${EnvConstants.goDomain}');
      print('  FALLBACK_URL: ${EnvConstants.fallbackUrl}');
      print('  BASE_URL: ${EnvConstants.baseUrl}');
    }
  }

  static void printApiRequest(String method, String endpoint, Map<String, dynamic>? data) {
    if (kDebugMode) {
      print('🌐 API Request:');
      print('  Method: $method');
      print('  Endpoint: $endpoint');
      print('  Data: $data');
    }
  }

  static void printApiResponse(int statusCode, dynamic data) {
    if (kDebugMode) {
      print('📡 API Response:');
      print('  Status: $statusCode');
      print('  Data: $data');
    }
  }

  static void printError(String context, dynamic error) {
    if (kDebugMode) {
      print('❌ Error in $context:');
      print('  Error: $error');
    }
  }

  static void printSuccess(String context, String message) {
    if (kDebugMode) {
      print('✅ Success in $context: $message');
    }
  }
}

