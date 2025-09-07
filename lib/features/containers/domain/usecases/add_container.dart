import 'package:cardpro/features/containers/domain/repositories/container_repository.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart' as container_entity;

class AddContainerParams {
  final String name;
  final String? description;
  final String containerType;

  AddContainerParams({
    required this.name,
    this.description,
    required this.containerType,
  });
}

class AddContainer {
  final ContainerRepository repository;

  AddContainer(this.repository);

  Future<container_entity.Container?> call(AddContainerParams params) async {
    final result = await repository.addContainer(
      name: params.name,
      description: params.description,
      containerType: params.containerType,
    );
    return result.fold((_) => null, (c) => c);
  }
}

