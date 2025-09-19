import 'package:equatable/equatable.dart';

class ClaimToken extends Equatable {
  final String token;
  final String cardId;
  final DateTime expiresAt;

  const ClaimToken({
    required this.token,
    required this.cardId,
    required this.expiresAt,
  });

  @override
  List<Object> get props => [token, cardId, expiresAt];

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}


