import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/data/datasources/card_local_data_source.dart';
import 'package:cardpro/features/cards/data/models/card_instance_model.dart';
import 'package:cardpro/features/cards/data/models/card_model.dart';
import 'package:cardpro/features/cards/domain/entities/card.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/domain/repositories/card_repository.dart';
import 'package:dartz/dartz.dart';

class CardRepositoryImpl implements CardRepository {
  final CardLocalDataSource localDataSource;

  CardRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CardWithInstance>>> getCards() async {
    try {
      final cards = await localDataSource.getCards();
      return Right(cards);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CardWithInstance>> addCard({
    required String name,
    String? nameEn,
    String? nameJa,
    required String oracleId,
    required String? rarity,
    required String? setName,
    required int? cardNumber,
    String? lang,
    required int effectId,
    required String? description,
    required int quantity,
  }) async {
    try {
      final card = await localDataSource.addCard(
        name: name,
        nameEn: nameEn,
        nameJa: nameJa,
        oracleId: oracleId,
        rarity: rarity,
        setName: setName,
        cardNumber: cardNumber,
        lang: lang,
        effectId: effectId,
        description: description,
        quantity: quantity,
      );
      return Right(card);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCard(CardInstance instance) async {
    try {
      await localDataSource.deleteCard(instance as CardInstanceModel);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> editCard(
    CardInstance instance,
    String description, {
    int? containerId,
  }) async {
    try {
      await localDataSource.editCard(
        instance as CardInstanceModel,
        description,
        containerId: containerId,
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> editCardFull({
    required Card card,
    required CardInstance instance,
    required String? rarity,
    required String? setName,
    required int? cardNumber,
    required String? description,
  }) async {
    try {
      await localDataSource.editCardFull(
        card: card as CardModel,
        instance: instance as CardInstanceModel,
        rarity: rarity,
        setName: setName,
        cardNumber: cardNumber,
        description: description,
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
