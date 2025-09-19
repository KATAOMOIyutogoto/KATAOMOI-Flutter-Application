import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/env_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/claim_token.dart';
import '../../domain/repositories/claim_repository.dart';
import '../models/claim_token_model.dart';

class ClaimRepositoryImpl implements ClaimRepository {
  final Dio _dio;

  ClaimRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Either<Failure, void>> startClaim({
    required String email,
    required String cardId,
  }) async {
    try {
      final response = await _dio.post(
        '/claim/start',
        data: {
          'email': email,
          'cardId': cardId,
        },
        options: Options(
          headers: {
            'apikey': EnvConstants.supabaseAnonKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: 'OTP送信に失敗しました'));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: '予期しないエラーが発生しました: $e'));
    }
  }

  @override
  Future<Either<Failure, ClaimToken>> verifyOtp({
    required String email,
    required String otp,
    required String cardId,
  }) async {
    try {
      final response = await _dio.post(
        '/claim/verify',
        data: {
          'email': email,
          'otp': otp,
          'cardId': cardId,
        },
        options: Options(
          headers: {
            'apikey': EnvConstants.supabaseAnonKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final claimTokenModel = ClaimTokenModel.fromJson(response.data);
        return Right(claimTokenModel.toEntity());
      } else {
        return Left(ServerFailure(message: 'OTP検証に失敗しました'));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: '予期しないエラーが発生しました: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> claimCard({
    required String cardId,
    required String claimToken,
  }) async {
    try {
      final response = await _dio.post(
        '/cards/$cardId/claim',
        options: Options(
          headers: {
            'Authorization': 'Bearer $claimToken',
            'apikey': EnvConstants.supabaseAnonKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return Left(ServerFailure(message: 'カードのClaimに失敗しました'));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
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
        final message = e.response?.data?['message'] ?? 'サーバーエラーが発生しました';
        return ServerFailure(message: 'HTTP $statusCode: $message');
      default:
        return ServerFailure(message: 'ネットワークエラーが発生しました: ${e.message}');
    }
  }
}


