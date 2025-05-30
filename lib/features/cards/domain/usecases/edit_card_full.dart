import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/domain/entities/card.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/repositories/card_repository.dart';

class EditCardFull {
  final CardRepository repository;

  EditCardFull(this.repository);

  Future<Either<Failure, void>> call(EditCardFullParams params) async {
    return await repository.editCardFull(
      card: params.card,
      instance: params.instance,
      rarity: params.rarity,
      setName: params.setName,
      cardNumber: params.cardNumber,
      description: params.description,
    );
  }
}

class EditCardFullParams extends Equatable {
  final Card card;
  final CardInstance instance;
  final String? rarity;
  final String? setName;
  final int? cardNumber;
  final String? description;

  const EditCardFullParams({
    required this.card,
    required this.instance,
    required this.rarity,
    required this.setName,
    required this.cardNumber,
    required this.description,
  });

  @override
  List<Object?> get props => [card, instance, rarity, setName, cardNumber, description];
}
