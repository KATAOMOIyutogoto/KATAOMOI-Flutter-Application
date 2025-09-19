import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../domain/entities/card.dart';
import '../../domain/repositories/card_repository.dart';

// 状態クラス
abstract class CardState {}

class CardInitial extends CardState {}

class CardLoading extends CardState {}

class CardLoaded extends CardState {
  final Card card;
  CardLoaded(this.card);
}

class CardUpdated extends CardState {
  final Card card;
  CardUpdated(this.card);
}

class CardError extends CardState {
  final String message;
  CardError(this.message);
}

// プロバイダー
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return CardRepositoryImpl(dio: dio);
});

final cardProvider = StateNotifierProvider<CardNotifier, CardState>((ref) {
  final repository = ref.watch(cardRepositoryProvider);
  return CardNotifier(repository);
});

class CardNotifier extends StateNotifier<CardState> {
  final CardRepository _repository;

  CardNotifier(this._repository) : super(CardInitial());

  Future<void> getCard(String cardId) async {
    state = CardLoading();
    
    final result = await _repository.getCard(cardId);

    result.fold(
      (failure) => state = CardError(_getErrorMessage(failure)),
      (card) => state = CardLoaded(card),
    );
  }

  Future<void> updateCardUrl({
    required String cardId,
    required String currentUrl,
  }) async {
    state = CardLoading();
    
    final result = await _repository.updateCardUrl(
      cardId: cardId,
      currentUrl: currentUrl,
    );

    result.fold(
      (failure) => state = CardError(_getErrorMessage(failure)),
      (card) => state = CardUpdated(card),
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

