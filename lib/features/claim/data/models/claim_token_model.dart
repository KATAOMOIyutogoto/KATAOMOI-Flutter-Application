import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/claim_token.dart';

part 'claim_token_model.g.dart';

@JsonSerializable()
class ClaimTokenModel extends ClaimToken {
  const ClaimTokenModel({
    required super.token,
    required super.cardId,
    required super.expiresAt,
  });

  factory ClaimTokenModel.fromJson(Map<String, dynamic> json) => _$ClaimTokenModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClaimTokenModelToJson(this);

  factory ClaimTokenModel.fromEntity(ClaimToken claimToken) {
    return ClaimTokenModel(
      token: claimToken.token,
      cardId: claimToken.cardId,
      expiresAt: claimToken.expiresAt,
    );
  }

  ClaimToken toEntity() {
    return ClaimToken(
      token: token,
      cardId: cardId,
      expiresAt: expiresAt,
    );
  }
}


