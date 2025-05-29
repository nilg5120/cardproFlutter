import 'package:equatable/equatable.dart';

class Card extends Equatable {
  final int id;
  final String name;
  final String? rarity;
  final String? setName;
  final int? cardNumber;
  final int effectId;

  const Card({
    required this.id,
    required this.name,
    this.rarity,
    this.setName,
    this.cardNumber,
    required this.effectId,
  });

  @override
  List<Object?> get props => [id, name, rarity, setName, cardNumber, effectId];
}
