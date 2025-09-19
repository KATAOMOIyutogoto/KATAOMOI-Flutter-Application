import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/card.dart';

abstract class CardRepository {
  /// カード情報を取得
  Future<Either<Failure, Card>> getCard(String cardId);

  /// カードのURLを更新
  Future<Either<Failure, Card>> updateCardUrl({
    required String cardId,
    required String currentUrl,
  });
}


