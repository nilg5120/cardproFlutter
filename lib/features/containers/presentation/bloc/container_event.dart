import 'package:equatable/equatable.dart';

abstract class ContainerEvent extends Equatable {
  const ContainerEvent();

  @override
  List<Object?> get props => [];
}

class GetContainersEvent extends ContainerEvent {}

class AddContainerEvent extends ContainerEvent {
  final String name;
  final String? description;
  final String containerType;

  const AddContainerEvent({
    required this.name,
    this.description,
    required this.containerType,
  });

  @override
  List<Object?> get props => [name, description, containerType];
}

class DeleteContainerEvent extends ContainerEvent {
  final int id;

  const DeleteContainerEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class EditContainerEvent extends ContainerEvent {
  final int id;
  final String name;
  final String? description;
  final String containerType;

  const EditContainerEvent({
    required this.id,
    required this.name,
    this.description,
    required this.containerType,
  });

  @override
  List<Object?> get props => [id, name, description, containerType];
}

