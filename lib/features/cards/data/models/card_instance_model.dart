import 'package:cardpro/features/cards/domain/entities/card_instance.dart';

class CardInstanceModel extends CardInstance {
  const CardInstanceModel({
    required super.id,
    required super.cardId,
    super.lang,
    super.updatedAt,
    super.description,
  });

  factory CardInstanceModel.fromDrift(dynamic driftInstance) {
    return CardInstanceModel(
      id: driftInstance.id,
      cardId: driftInstance.cardId,
      lang: driftInstance.lang,
      updatedAt: driftInstance.updatedAt,
      description: driftInstance.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardId': cardId,
      'lang': lang,
      'updatedAt': updatedAt?.toIso8601String(),
      'description': description,
    };
  }

  factory CardInstanceModel.fromJson(Map<String, dynamic> json) {
    return CardInstanceModel(
      id: json['id'],
      cardId: json['cardId'],
      lang: json['lang'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      description: json['description'] as String?,
    );
  }
}
