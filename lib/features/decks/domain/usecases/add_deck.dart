import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart';
import 'package:cardpro/features/decks/domain/repositories/deck_repository.dart';

class AddDeck {
  final DeckRepository repository;

  AddDeck(this.repository);

  Future<Either<Failure, Container>> call(AddDeckParams params) async {
    return await repository.addDeck(
      name: params.name,
      description: params.description,
    );
  }
}

class AddDeckParams extends Equatable {
  final String name;
  final String? description;

  const AddDeckParams({
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [name, description];
}
