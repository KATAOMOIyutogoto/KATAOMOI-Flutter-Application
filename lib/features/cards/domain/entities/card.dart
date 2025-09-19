import 'package:equatable/equatable.dart';

class Card extends Equatable {
  final String id;
  final String? ownerUserId;
  final String status; // 'preprovisioned' or 'claimed'
  final String currentUrl;
  final String defaultSource; // 'org_default' or 'custom'
  final DateTime createdAt;
  final DateTime updatedAt;

  const Card({
    required this.id,
    this.ownerUserId,
    required this.status,
    required this.currentUrl,
    required this.defaultSource,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        ownerUserId,
        status,
        currentUrl,
        defaultSource,
        createdAt,
        updatedAt,
      ];

  Card copyWith({
    String? id,
    String? ownerUserId,
    String? status,
    String? currentUrl,
    String? defaultSource,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Card(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      status: status ?? this.status,
      currentUrl: currentUrl ?? this.currentUrl,
      defaultSource: defaultSource ?? this.defaultSource,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


