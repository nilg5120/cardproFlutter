import 'package:cardpro/features/containers/domain/repositories/container_repository.dart';

class DeleteContainerParams {
  final int id;

  DeleteContainerParams({required this.id});
}

class DeleteContainer {
  final ContainerRepository repository;

  DeleteContainer(this.repository);

  Future<bool> call(DeleteContainerParams params) async {
    final result = await repository.deleteContainer(id: params.id);
    return result.isRight();
  }
}

