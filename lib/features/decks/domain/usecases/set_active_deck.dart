import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/decks/domain/repositories/deck_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class SetActiveDeck {
  final DeckRepository repository;

  SetActiveDeck(this.repository);

  Future<Either<Failure, void>> call(SetActiveDeckParams params) async {
    return await repository.setActiveDeck(id: params.id);
  }
}

class SetActiveDeckParams extends Equatable {
  final int id;

  const SetActiveDeckParams({required this.id});

  @override
  List<Object?> get props => [id];
}

