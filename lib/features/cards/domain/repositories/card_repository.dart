import 'package:dartz/dartz.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/entities/card.dart';

abstract class CardRepository {
  Future<Either<Failure, List<CardWithInstance>>> getCards();
  Future<Either<Failure, CardWithInstance>> addCard({
    required String name,
    required String oracleId,
    required String? rarity,
    required String? setName,
    required int? cardNumber,
    required int effectId,
    required String? description,
    required int quantity,
  });
  Future<Either<Failure, void>> deleteCard(CardInstance instance);
  Future<Either<Failure, void>> editCard(CardInstance instance, String description);
  Future<Either<Failure, void>> editCardFull({
    required Card card,
    required CardInstance instance,
    required String? rarity,
    required String? setName,
    required int? cardNumber,
    required String? description,
  });
}
