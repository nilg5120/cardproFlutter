import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/domain/repositories/card_repository.dart';

class AddCard {
  final CardRepository repository;

  AddCard(this.repository);

  Future<Either<Failure, CardWithInstance>> call(AddCardParams params) async {
    return await repository.addCard(
      name: params.name,
      oracleId: params.oracleId,
      rarity: params.rarity,
      setName: params.setName,
      cardNumber: params.cardNumber,
      effectId: params.effectId,
      description: params.description,
      quantity: params.quantity,
    );
  }
}

class AddCardParams extends Equatable {
  final String name;
  final String oracleId;
  final String? rarity;
  final String? setName;
  final int? cardNumber;
  final int effectId;
  final String? description;
  final int quantity;

  const AddCardParams({
    required this.name,
    required this.oracleId,
    this.rarity,
    this.setName,
    this.cardNumber,
    required this.effectId,
    this.description,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [name, oracleId, rarity, setName, cardNumber, effectId, description, quantity];
}
