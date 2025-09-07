import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/decks/data/datasources/deck_local_data_source.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart';
import 'package:cardpro/features/decks/domain/repositories/deck_repository.dart';
import 'package:dartz/dartz.dart';

class DeckRepositoryImpl implements DeckRepository {
  final DeckLocalDataSource localDataSource;

  DeckRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Container>>> getDecks() async {
    try {
      final decks = await localDataSource.getDecks();
      return Right(decks);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Container>> addDeck({
    required String name,
    required String? description,
  }) async {
    try {
      final deck = await localDataSource.addDeck(
        name: name,
        description: description,
      );
      return Right(deck);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeck({required int id}) async {
    try {
      await localDataSource.deleteDeck(id: id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Container>> editDeck({
    required int id,
    required String name,
    required String? description,
  }) async {
    try {
      final deck = await localDataSource.editDeck(
        id: id,
        name: name,
        description: description,
      );
      return Right(deck);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setActiveDeck({required int id}) async {
    try {
      await localDataSource.setActiveDeck(id: id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
