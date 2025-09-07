import 'package:cardpro/features/containers/domain/repositories/container_repository.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart' as container_entity;

class GetContainers {
  final ContainerRepository repository;

  GetContainers(this.repository);

  Future<List<container_entity.Container>> call() async {
    final result = await repository.getContainers();
    return result.fold((_) => <container_entity.Container>[], (list) => list);
  }
}

