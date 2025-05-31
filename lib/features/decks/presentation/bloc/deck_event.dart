import 'package:equatable/equatable.dart';

abstract class DeckEvent extends Equatable {
  const DeckEvent();

  @override
  List<Object?> get props => [];
}

class GetDecksEvent extends DeckEvent {}

class AddDeckEvent extends DeckEvent {
  final String name;
  final String? description;

  const AddDeckEvent({
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [name, description];
}

class DeleteDeckEvent extends DeckEvent {
  final int id;

  const DeleteDeckEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class EditDeckEvent extends DeckEvent {
  final int id;
  final String name;
  final String? description;

  const EditDeckEvent({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}
