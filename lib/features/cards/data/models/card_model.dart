import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/card.dart';

part 'card_model.g.dart';

@JsonSerializable()
class CardModel extends Card {
  const CardModel({
    required super.id,
    @JsonKey(name: 'owner_user_id') super.ownerUserId,
    required super.status,
    @JsonKey(name: 'current_url') required super.currentUrl,
    @JsonKey(name: 'default_source') required super.defaultSource,
    @JsonKey(name: 'created_at') required super.createdAt,
    @JsonKey(name: 'updated_at') required super.updatedAt,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => _$CardModelFromJson(json);

  Map<String, dynamic> toJson() => _$CardModelToJson(this);

  factory CardModel.fromEntity(Card card) {
    return CardModel(
      id: card.id,
      ownerUserId: card.ownerUserId,
      status: card.status,
      currentUrl: card.currentUrl,
      defaultSource: card.defaultSource,
      createdAt: card.createdAt,
      updatedAt: card.updatedAt,
    );
  }

  Card toEntity() {
    return Card(
      id: id,
      ownerUserId: ownerUserId,
      status: status,
      currentUrl: currentUrl,
      defaultSource: defaultSource,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

