import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/containers/data/datasources/container_local_data_source.dart';
import 'package:cardpro/features/containers/domain/repositories/container_repository.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart' as container_entity;
import 'package:dartz/dartz.dart';

class ContainerRepositoryImpl implements ContainerRepository {
  final ContainerLocalDataSource localDataSource;

  ContainerRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<container_entity.Container>>> getContainers() async {
    try {
      final containers = await localDataSource.getContainers();
      return Right(containers);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, container_entity.Container>> addContainer({
    required String name,
    required String? description,
    required String containerType,
  }) async {
    try {
      final container = await localDataSource.addContainer(
        name: name,
        description: description,
        containerType: containerType,
      );
      return Right(container);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContainer({required int id}) async {
    try {
      await localDataSource.deleteContainer(id: id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, container_entity.Container>> editContainer({
    required int id,
    required String name,
    required String? description,
    required String containerType,
  }) async {
    try {
      final container = await localDataSource.editContainer(
        id: id,
        name: name,
        description: description,
        containerType: containerType,
      );
      return Right(container);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}

