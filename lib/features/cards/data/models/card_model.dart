import 'package:cardpro/features/cards/domain/entities/card.dart';

class CardModel extends Card {
  const CardModel({
    required super.id,
    required super.name,
    super.nameEn,
    super.nameJa,
    super.oracleId,
    super.rarity,
    super.setName,
    super.cardNumber,
    required super.effectId,
  });

  factory CardModel.fromDrift(dynamic driftCard) {
    return CardModel(
      id: driftCard.id,
      name: driftCard.name,
      nameEn: driftCard.nameEn,
      nameJa: driftCard.nameJa,
      oracleId: driftCard.oracleId,
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
      'nameEn': nameEn,
      'nameJa': nameJa,
      'oracleId': oracleId,
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
      nameEn: json['nameEn'],
      nameJa: json['nameJa'],
      oracleId: json['oracleId'],
      rarity: json['rarity'],
      setName: json['setName'],
      cardNumber: json['cardNumber'],
      effectId: json['effectId'],
    );
  }
}
