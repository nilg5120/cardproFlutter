import 'package:cardpro/features/cards/domain/entities/card_instance.dart';

class CardInstanceModel extends CardInstance {
  const CardInstanceModel({
    required super.id,
    required super.cardId,
    super.updatedAt,
    super.description,
  });

  factory CardInstanceModel.fromDrift(dynamic driftInstance) {
    return CardInstanceModel(
      id: driftInstance.id,
      cardId: driftInstance.cardId,
      updatedAt: driftInstance.updatedAt,
      description: driftInstance.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardId': cardId,
      'updatedAt': updatedAt?.toIso8601String(),
      'description': description,
    };
  }

  factory CardInstanceModel.fromJson(Map<String, dynamic> json) {
    return CardInstanceModel(
      id: json['id'],
      cardId: json['cardId'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      description: json['description'],
    );
  }
}
