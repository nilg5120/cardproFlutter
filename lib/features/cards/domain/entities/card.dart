import 'package:equatable/equatable.dart';

class Card extends Equatable {
  final int id;
  final String name;
  final String? nameEn;
  final String? nameJa;
  final String? oracleId;
  final String? rarity;
  final String? setName;
  final int? cardNumber;
  final int effectId;

  const Card({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameJa,
    this.oracleId,
    this.rarity,
    this.setName,
    this.cardNumber,
    required this.effectId,
  });

  @override
  List<Object?> get props => [id, name, nameEn, nameJa, oracleId, rarity, setName, cardNumber, effectId];
}
