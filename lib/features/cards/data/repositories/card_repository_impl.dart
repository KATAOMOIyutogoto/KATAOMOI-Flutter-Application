import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/env_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/card.dart';
import '../../domain/repositories/card_repository.dart';
import '../models/card_model.dart';

class CardRepositoryImpl implements CardRepository {
  final Dio _dio;

  CardRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Either<Failure, Card>> getCard(String cardId) async {
    try {
      final response = await _dio.get(
        '/cards?id=eq.$cardId',
        options: Options(
          headers: {
            'apikey': EnvConstants.supabaseAnonKey,
            'Authorization': 'Bearer ${EnvConstants.supabaseAnonKey}',
            'Content-Type': 'application/json',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data;
        if (dataList.isEmpty) {
          return Left(ServerFailure(message: 'カードが見つかりません'));
        }
        final cardModel = CardModel.fromJson(dataList.first);
        return Right(cardModel.toEntity());
      } else {
        return Left(ServerFailure(message: 'カード情報の取得に失敗しました'));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: '予期しないエラーが発生しました: $e'));
    }
  }

  @override
  Future<Either<Failure, Card>> updateCardUrl({
    required String cardId,
    required String currentUrl,
  }) async {
    try {
      print('🔄 カードURL更新開始: cardId=$cardId, currentUrl=$currentUrl');
      
      // SupabaseのPATCHリクエストは更新後にデータを返さないため、
      // まず更新を実行し、その後でカード情報を再取得する
      final updateResponse = await _dio.patch(
        '/cards?id=eq.$cardId',
        data: {
          'current_url': currentUrl,
          'default_source': 'custom', // URLを更新したらcustomに変更
        },
        options: Options(
          headers: {
            'apikey': EnvConstants.supabaseServiceRoleKey,
            'Authorization': 'Bearer ${EnvConstants.supabaseServiceRoleKey}',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal', // 最小限のレスポンスを要求
          },
        ),
      );
      
      print('✅ カードURL更新レスポンス: statusCode=${updateResponse.statusCode}');

      if (updateResponse.statusCode == 204 || updateResponse.statusCode == 200) {
        // 更新成功後、カード情報を再取得（Service Role Keyで直接取得）
        print('🔄 カード情報を再取得中...');
        await Future.delayed(const Duration(milliseconds: 500)); // 少し待機
        
        // Service Role Keyで直接取得
        final getResponse = await _dio.get(
          '/cards?id=eq.$cardId',
          options: Options(
            headers: {
              'apikey': EnvConstants.supabaseServiceRoleKey,
              'Authorization': 'Bearer ${EnvConstants.supabaseServiceRoleKey}',
              'Content-Type': 'application/json',
              'Cache-Control': 'no-cache',
              'Pragma': 'no-cache',
            },
          ),
        );
        
        if (getResponse.statusCode == 200) {
          final List<dynamic> dataList = getResponse.data;
          if (dataList.isEmpty) {
            return Left(ServerFailure(message: 'カードが見つかりません'));
          }
          final cardModel = CardModel.fromJson(dataList.first);
          return Right(cardModel.toEntity());
        } else {
          return Left(ServerFailure(message: 'カード情報の再取得に失敗しました'));
        }
      } else {
        print('❌ カードURL更新失敗: statusCode=${updateResponse.statusCode}');
        return Left(ServerFailure(message: 'カードURLの更新に失敗しました'));
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      return Left(_handleDioError(e));
    } catch (e) {
      print('❌ 予期しないエラー: $e');
      return Left(ServerFailure(message: '予期しないエラーが発生しました: $e'));
    }
  }

  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(message: 'ネットワーク接続がタイムアウトしました');
      case DioExceptionType.connectionError:
        return const NetworkFailure(message: 'ネットワーク接続エラーが発生しました');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        
        // Supabaseのエラーメッセージを抽出
        String message = 'サーバーエラーが発生しました';
        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ?? responseData['error'] ?? message;
        } else if (responseData is String) {
          message = responseData;
        }
        
        // 認証エラーの場合
        if (statusCode == 401) {
          message = '認証に失敗しました。APIキーを確認してください';
        } else if (statusCode == 403) {
          message = 'アクセスが拒否されました。権限を確認してください';
        } else if (statusCode == 404) {
          message = 'リソースが見つかりません';
        }
        
        return ServerFailure(message: 'HTTP $statusCode: $message');
      default:
        return ServerFailure(message: 'ネットワークエラーが発生しました: ${e.message}');
    }
  }
}

