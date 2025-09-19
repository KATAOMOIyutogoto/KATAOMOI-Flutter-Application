// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claim_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClaimTokenModel _$ClaimTokenModelFromJson(Map<String, dynamic> json) =>
    ClaimTokenModel(
      token: json['token'] as String,
      cardId: json['cardId'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$ClaimTokenModelToJson(ClaimTokenModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'cardId': instance.cardId,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
