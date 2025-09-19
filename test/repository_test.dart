import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:kataomoi_app/features/cards/data/repositories/card_repository_impl.dart';
import 'package:kataomoi_app/features/cards/domain/entities/card.dart';
import 'package:kataomoi_app/features/claim/data/repositories/claim_repository_impl.dart';
import 'package:kataomoi_app/features/claim/domain/entities/claim_token.dart';
import 'package:kataomoi_app/core/errors/failures.dart';

void main() {
  group('CardRepository Tests', () {
    late CardRepositoryImpl repository;
    late Dio mockDio;

    setUp(() {
      mockDio = Dio();
      repository = CardRepositoryImpl(dio: mockDio);
    });

    test('getCard - 正常なレスポンスの場合', () async {
      // モックデータ
      final mockResponse = [
        {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'owner_user_id': null,
          'status': 'preprovisioned',
          'current_url': 'https://kataomoi.org',
          'default_source': 'org_default',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        }
      ];

      // モックDioの設定
      mockDio.options.baseUrl = 'https://test.supabase.co';
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: options,
          ));
        },
      ));

      // テスト実行
      final result = await repository.getCard('550e8400-e29b-41d4-a716-446655440000');

      // 結果の検証
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (card) {
          expect(card.id, '550e8400-e29b-41d4-a716-446655440000');
          expect(card.status, 'preprovisioned');
          expect(card.currentUrl, 'https://kataomoi.org');
        },
      );
    });

    test('getCard - カードが見つからない場合', () async {
      // モックDioの設定
      mockDio.options.baseUrl = 'https://test.supabase.co';
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            data: [],
            statusCode: 200,
            requestOptions: options,
          ));
        },
      ));

      // テスト実行
      final result = await repository.getCard('non-existent-card');

      // 結果の検証
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'カードが見つかりません');
        },
        (card) => fail('Expected failure but got success: $card'),
      );
    });

    test('updateCardUrl - 正常な更新の場合', () async {
      // モックデータ
      final mockResponse = [
        {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'owner_user_id': 'user-id',
          'status': 'claimed',
          'current_url': 'https://example.com',
          'default_source': 'custom',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        }
      ];

      // モックDioの設定
      mockDio.options.baseUrl = 'https://test.supabase.co';
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: options,
          ));
        },
      ));

      // テスト実行
      final result = await repository.updateCardUrl(
        cardId: '550e8400-e29b-41d4-a716-446655440000',
        currentUrl: 'https://example.com',
      );

      // 結果の検証
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (card) {
          expect(card.currentUrl, 'https://example.com');
          expect(card.defaultSource, 'custom');
        },
      );
    });
  });

  group('ClaimRepository Tests', () {
    late ClaimRepositoryImpl repository;
    late Dio mockDio;

    setUp(() {
      mockDio = Dio();
      repository = ClaimRepositoryImpl(dio: mockDio);
    });

    test('startClaim - 正常なOTP送信の場合', () async {
      // モックDioの設定
      mockDio.options.baseUrl = 'https://test.supabase.co';
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            data: {'message': 'OTP sent'},
            statusCode: 200,
            requestOptions: options,
          ));
        },
      ));

      // テスト実行
      final result = await repository.startClaim(
        email: 'test@example.com',
        cardId: '550e8400-e29b-41d4-a716-446655440000',
      );

      // 結果の検証
      expect(result.isRight(), true);
    });

    test('verifyOtp - 正常なOTP検証の場合', () async {
      // モックデータ
      final mockResponse = {
        'token': 'claim-token-123',
        'cardId': '550e8400-e29b-41d4-a716-446655440000',
        'expiresAt': '2024-01-01T01:00:00Z',
      };

      // モックDioの設定
      mockDio.options.baseUrl = 'https://test.supabase.co';
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: options,
          ));
        },
      ));

      // テスト実行
      final result = await repository.verifyOtp(
        email: 'test@example.com',
        otp: '123456',
        cardId: '550e8400-e29b-41d4-a716-446655440000',
      );

      // 結果の検証
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (claimToken) {
          expect(claimToken.token, 'claim-token-123');
          expect(claimToken.cardId, '550e8400-e29b-41d4-a716-446655440000');
        },
      );
    });

    test('claimCard - 正常なClaimの場合', () async {
      // モックDioの設定
      mockDio.options.baseUrl = 'https://test.supabase.co';
      mockDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            data: {'message': 'Card claimed successfully'},
            statusCode: 200,
            requestOptions: options,
          ));
        },
      ));

      // テスト実行
      final result = await repository.claimCard(
        cardId: '550e8400-e29b-41d4-a716-446655440000',
        claimToken: 'claim-token-123',
      );

      // 結果の検証
      expect(result.isRight(), true);
    });
  });
}

