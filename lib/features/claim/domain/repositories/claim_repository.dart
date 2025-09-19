import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/claim_token.dart';

abstract class ClaimRepository {
  /// メールOTP送信を開始
  Future<Either<Failure, void>> startClaim({
    required String email,
    required String cardId,
  });

  /// OTP検証してClaimTokenを取得
  Future<Either<Failure, ClaimToken>> verifyOtp({
    required String email,
    required String otp,
    required String cardId,
  });

  /// ClaimTokenを使ってカードをClaim
  Future<Either<Failure, void>> claimCard({
    required String cardId,
    required String claimToken,
  });
}


