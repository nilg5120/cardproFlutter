import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/decks/domain/repositories/deck_repository.dart';

class DeleteDeck {
  final DeckRepository repository;

  DeleteDeck(this.repository);

  Future<Either<Failure, void>> call(DeleteDeckParams params) async {
    return await repository.deleteDeck(id: params.id);
  }
}

class DeleteDeckParams extends Equatable {
  final int id;

  const DeleteDeckParams({required this.id});

  @override
  List<Object> get props => [id];
}
