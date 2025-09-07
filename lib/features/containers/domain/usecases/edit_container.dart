import 'package:cardpro/features/containers/domain/repositories/container_repository.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart' as container_entity;

class EditContainerParams {
  final int id;
  final String name;
  final String? description;
  final String containerType;

  EditContainerParams({
    required this.id,
    required this.name,
    this.description,
    required this.containerType,
  });
}

class EditContainer {
  final ContainerRepository repository;

  EditContainer(this.repository);

  Future<container_entity.Container?> call(EditContainerParams params) async {
    final result = await repository.editContainer(
      id: params.id,
      name: params.name,
      description: params.description,
      containerType: params.containerType,
    );
    return result.fold((_) => null, (c) => c);
  }
}

