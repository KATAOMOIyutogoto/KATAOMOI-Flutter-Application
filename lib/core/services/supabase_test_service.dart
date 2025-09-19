import 'package:dio/dio.dart';
import '../constants/env_constants.dart';

class SupabaseTestService {
  static final Dio _dio = Dio();

  static Future<Map<String, dynamic>> testConnection() async {
    try {
      print('🔍 Supabase接続テスト開始');
      print('  URL: ${EnvConstants.supabaseUrl}');
      print('  Key: ${EnvConstants.supabaseAnonKey.substring(0, 10)}...');
      
      final response = await _dio.get(
        '${EnvConstants.supabaseUrl}/rest/v1/',
        options: Options(
          headers: {
            'apikey': EnvConstants.supabaseAnonKey,
            'Authorization': 'Bearer ${EnvConstants.supabaseAnonKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ Supabase接続成功: ${response.statusCode}');
      
      return {
        'success': true,
        'statusCode': response.statusCode,
        'message': 'Supabaseに正常に接続できました',
        'url': EnvConstants.supabaseUrl,
      };
    } on DioException catch (e) {
      print('❌ Supabase接続エラー: ${e.message}');
      print('  Status: ${e.response?.statusCode}');
      print('  Data: ${e.response?.data}');
      
      String message = 'Supabaseに接続できませんでした';
      if (e.response?.statusCode == 401) {
        message = '認証に失敗しました。APIキーを確認してください';
      } else if (e.response?.statusCode == 404) {
        message = 'Supabaseプロジェクトが見つかりません。URLを確認してください';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        message = '接続がタイムアウトしました。ネットワークを確認してください';
      }
      
      return {
        'success': false,
        'statusCode': e.response?.statusCode,
        'message': message,
        'error': e.message,
        'url': EnvConstants.supabaseUrl,
      };
    } catch (e) {
      print('❌ 予期しないエラー: $e');
      
      return {
        'success': false,
        'message': '予期しないエラーが発生しました: $e',
        'url': EnvConstants.supabaseUrl,
      };
    }
  }

  static Future<Map<String, dynamic>> testCardsTable() async {
    try {
      print('🔍 カードテーブル接続テスト開始');
      
      final response = await _dio.get(
        '${EnvConstants.supabaseUrl}/rest/v1/cards?limit=1',
        options: Options(
          headers: {
            'apikey': EnvConstants.supabaseAnonKey,
            'Authorization': 'Bearer ${EnvConstants.supabaseAnonKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ カードテーブル接続成功: ${response.statusCode}');
      
      return {
        'success': true,
        'statusCode': response.statusCode,
        'message': 'カードテーブルに正常にアクセスできました',
        'data': response.data,
      };
    } on DioException catch (e) {
      print('❌ カードテーブル接続エラー: ${e.message}');
      
      String message = 'カードテーブルにアクセスできませんでした';
      if (e.response?.statusCode == 401) {
        message = '認証に失敗しました';
      } else if (e.response?.statusCode == 403) {
        message = 'アクセス権限がありません';
      } else if (e.response?.statusCode == 404) {
        message = 'カードテーブルが見つかりません';
      }
      
      return {
        'success': false,
        'statusCode': e.response?.statusCode,
        'message': message,
        'error': e.message,
      };
    } catch (e) {
      print('❌ 予期しないエラー: $e');
      
      return {
        'success': false,
        'message': '予期しないエラーが発生しました: $e',
      };
    }
  }
}

