import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/repositories/claim_repository_impl.dart';
import '../../domain/entities/claim_token.dart';
import '../../domain/repositories/claim_repository.dart';

// 状態クラス
abstract class ClaimState {}

class ClaimInitial extends ClaimState {}

class ClaimLoading extends ClaimState {}

class ClaimSuccess extends ClaimState {}

class ClaimError extends ClaimState {
  final String message;
  ClaimError(this.message);
}

// プロバイダー
final claimRepositoryProvider = Provider<ClaimRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ClaimRepositoryImpl(dio: dio);
});

final claimProvider = StateNotifierProvider<ClaimNotifier, ClaimState>((ref) {
  final repository = ref.watch(claimRepositoryProvider);
  return ClaimNotifier(repository);
});

class ClaimNotifier extends StateNotifier<ClaimState> {
  final ClaimRepository _repository;

  ClaimNotifier(this._repository) : super(ClaimInitial());

  Future<void> startClaim({
    required String email,
    required String cardId,
  }) async {
    state = ClaimLoading();
    
    final result = await _repository.startClaim(
      email: email,
      cardId: cardId,
    );

    result.fold(
      (failure) => state = ClaimError(_getErrorMessage(failure)),
      (_) => state = ClaimInitial(),
    );
  }

  Future<void> verifyOtpAndClaim({
    required String email,
    required String otp,
    required String cardId,
  }) async {
    state = ClaimLoading();

    // OTP検証
    final verifyResult = await _repository.verifyOtp(
      email: email,
      otp: otp,
      cardId: cardId,
    );

    verifyResult.fold(
      (failure) {
        state = ClaimError(_getErrorMessage(failure));
      },
      (claimToken) async {
        // カードをClaim
        final claimResult = await _repository.claimCard(
          cardId: cardId,
          claimToken: claimToken.token,
        );

        claimResult.fold(
          (failure) => state = ClaimError(_getErrorMessage(failure)),
          (_) => state = ClaimSuccess(),
        );
      },
    );
  }

  String _getErrorMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    } else {
      return '予期しないエラーが発生しました';
    }
  }
}

