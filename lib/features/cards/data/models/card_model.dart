import 'package:cardpro/features/cards/domain/entities/card.dart';

class CardModel extends Card {
  const CardModel({
    required super.id,
    required super.name,
    super.rarity,
    super.setName,
    super.cardNumber,
    required super.effectId,
  });

  factory CardModel.fromDrift(dynamic driftCard) {
    return CardModel(
      id: driftCard.id,
      name: driftCard.name,
      rarity: driftCard.rarity,
      setName: driftCard.setName,
      cardNumber: driftCard.cardnumber,
      effectId: driftCard.effectId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rarity': rarity,
      'setName': setName,
      'cardNumber': cardNumber,
      'effectId': effectId,
    };
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      name: json['name'],
      rarity: json['rarity'],
      setName: json['setName'],
      cardNumber: json['cardNumber'],
      effectId: json['effectId'],
    );
  }
}
