import 'package:dartz/dartz.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart';
import 'package:cardpro/features/decks/domain/repositories/deck_repository.dart';

class GetDecks {
  final DeckRepository repository;

  GetDecks(this.repository);

  Future<Either<Failure, List<Container>>> call() async {
    return await repository.getDecks();
  }
}
