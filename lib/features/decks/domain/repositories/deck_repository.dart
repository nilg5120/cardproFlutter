import 'package:dartz/dartz.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart';

abstract class DeckRepository {
  Future<Either<Failure, List<Container>>> getDecks();
  Future<Either<Failure, Container>> addDeck({
    required String name,
    required String? description,
  });
}
