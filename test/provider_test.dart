import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kataomoi_app/features/cards/presentation/providers/card_provider.dart';
import 'package:kataomoi_app/features/claim/presentation/providers/claim_provider.dart';
import 'package:kataomoi_app/features/cards/domain/entities/card.dart';
import 'package:kataomoi_app/features/claim/domain/entities/claim_token.dart';
import 'package:kataomoi_app/features/cards/domain/repositories/card_repository.dart';
import 'package:kataomoi_app/features/claim/domain/repositories/claim_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:kataomoi_app/core/errors/failures.dart';

// モックリポジトリ
class MockCardRepository implements CardRepository {
  @override
  Future<Either<Failure, Card>> getCard(String cardId) async {
    if (cardId == '550e8400-e29b-41d4-a716-446655440000') {
      return Right(Card(
        id: cardId,
        status: 'preprovisioned',
        currentUrl: 'https://kataomoi.org',
        defaultSource: 'org_default',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    return Left(ServerFailure(message: 'カードが見つかりません'));
  }

  @override
  Future<Either<Failure, Card>> updateCardUrl({
    required String cardId,
    required String currentUrl,
  }) async {
    return Right(Card(
      id: cardId,
      status: 'claimed',
      currentUrl: currentUrl,
      defaultSource: 'custom',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }
}

class MockClaimRepository implements ClaimRepository {
  @override
  Future<Either<Failure, void>> startClaim({
    required String email,
    required String cardId,
  }) async {
    if (email.isNotEmpty && cardId.isNotEmpty) {
      return const Right(null);
    }
    return Left(ServerFailure(message: 'OTP送信に失敗しました'));
  }

  @override
  Future<Either<Failure, ClaimToken>> verifyOtp({
    required String email,
    required String otp,
    required String cardId,
  }) async {
    if (otp == '123456') {
      return Right(ClaimToken(
        token: 'claim-token-123',
        cardId: cardId,
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      ));
    }
    return Left(ServerFailure(message: 'OTP検証に失敗しました'));
  }

  @override
  Future<Either<Failure, void>> claimCard({
    required String cardId,
    required String claimToken,
  }) async {
    if (claimToken.isNotEmpty) {
      return const Right(null);
    }
    return Left(ServerFailure(message: 'カードのClaimに失敗しました'));
  }
}

void main() {
  group('CardProvider Tests', () {
    late ProviderContainer container;
    late MockCardRepository mockRepository;

    setUp(() {
      mockRepository = MockCardRepository();
      container = ProviderContainer(
        overrides: [
          cardRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('初期状態はCardInitial', () {
      final state = container.read(cardProvider);
      expect(state, isA<CardInitial>());
    });

    test('getCard - 成功時の状態変化', () async {
      final notifier = container.read(cardProvider.notifier);
      
      // カード取得を実行
      await notifier.getCard('550e8400-e29b-41d4-a716-446655440000');
      
      // 状態の確認
      final state = container.read(cardProvider);
      expect(state, isA<CardLoaded>());
      
      if (state is CardLoaded) {
        expect(state.card.id, '550e8400-e29b-41d4-a716-446655440000');
        expect(state.card.status, 'preprovisioned');
        expect(state.card.currentUrl, 'https://kataomoi.org');
      }
    });

    test('getCard - 失敗時の状態変化', () async {
      final notifier = container.read(cardProvider.notifier);
      
      // 存在しないカードIDで取得を実行
      await notifier.getCard('non-existent-card');
      
      // 状態の確認
      final state = container.read(cardProvider);
      expect(state, isA<CardError>());
      
      if (state is CardError) {
        expect(state.message, 'カードが見つかりません');
      }
    });

    test('updateCardUrl - 成功時の状態変化', () async {
      final notifier = container.read(cardProvider.notifier);
      
      // URL更新を実行
      await notifier.updateCardUrl(
        cardId: '550e8400-e29b-41d4-a716-446655440000',
        currentUrl: 'https://example.com',
      );
      
      // 状態の確認
      final state = container.read(cardProvider);
      expect(state, isA<CardUpdated>());
      
      if (state is CardUpdated) {
        expect(state.card.currentUrl, 'https://example.com');
        expect(state.card.defaultSource, 'custom');
      }
    });
  });

  group('ClaimProvider Tests', () {
    late ProviderContainer container;
    late MockClaimRepository mockRepository;

    setUp(() {
      mockRepository = MockClaimRepository();
      container = ProviderContainer(
        overrides: [
          claimRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('初期状態はClaimInitial', () {
      final state = container.read(claimProvider);
      expect(state, isA<ClaimInitial>());
    });

    test('startClaim - 成功時の状態変化', () async {
      final notifier = container.read(claimProvider.notifier);
      
      // OTP送信を実行
      await notifier.startClaim(
        email: 'test@example.com',
        cardId: '550e8400-e29b-41d4-a716-446655440000',
      );
      
      // 状態の確認（成功後は初期状態に戻る）
      final state = container.read(claimProvider);
      expect(state, isA<ClaimInitial>());
    });

    test('startClaim - 失敗時の状態変化', () async {
      final notifier = container.read(claimProvider.notifier);
      
      // 空のメールアドレスでOTP送信を実行
      await notifier.startClaim(
        email: '',
        cardId: '550e8400-e29b-41d4-a716-446655440000',
      );
      
      // 状態の確認
      final state = container.read(claimProvider);
      expect(state, isA<ClaimError>());
      
      if (state is ClaimError) {
        expect(state.message, 'OTP送信に失敗しました');
      }
    });

    test('verifyOtpAndClaim - 成功時の状態変化', () async {
      final notifier = container.read(claimProvider.notifier);
      
      // OTP検証とClaimを実行
      await notifier.verifyOtpAndClaim(
        email: 'test@example.com',
        otp: '123456',
        cardId: '550e8400-e29b-41d4-a716-446655440000',
      );
      
      // 状態の確認
      final state = container.read(claimProvider);
      expect(state, isA<ClaimSuccess>());
    });

    test('verifyOtpAndClaim - OTP検証失敗時の状態変化', () async {
      final notifier = container.read(claimProvider.notifier);
      
      // 間違ったOTPで検証を実行
      await notifier.verifyOtpAndClaim(
        email: 'test@example.com',
        otp: '000000',
        cardId: '550e8400-e29b-41d4-a716-446655440000',
      );
      
      // 状態の確認
      final state = container.read(claimProvider);
      expect(state, isA<ClaimError>());
      
      if (state is ClaimError) {
        expect(state.message, 'OTP検証に失敗しました');
      }
    });
  });
}

