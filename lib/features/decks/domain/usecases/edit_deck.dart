import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart';
import 'package:cardpro/features/decks/domain/repositories/deck_repository.dart';

class EditDeck {
  final DeckRepository repository;

  EditDeck(this.repository);

  Future<Either<Failure, Container>> call(EditDeckParams params) async {
    return await repository.editDeck(
      id: params.id,
      name: params.name,
      description: params.description,
    );
  }
}

class EditDeckParams extends Equatable {
  final int id;
  final String name;
  final String? description;

  const EditDeckParams({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}
