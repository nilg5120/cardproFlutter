import 'package:dartz/dartz.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';

abstract class CardRepository {
  Future<Either<Failure, List<CardWithInstance>>> getCards();
  Future<Either<Failure, CardWithInstance>> addCard({
    required String name,
    required String? rarity,
    required String? setName,
    required int? cardNumber,
    required int effectId,
    required String? description,
  });
  Future<Either<Failure, void>> deleteCard(CardInstance instance);
  Future<Either<Failure, void>> editCard(CardInstance instance, String description);
}
