import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart' as container_entity;
import 'package:dartz/dartz.dart';

abstract class ContainerRepository {
  Future<Either<Failure, List<container_entity.Container>>> getContainers();
  Future<Either<Failure, container_entity.Container>> addContainer({
    required String name,
    required String? description,
    required String containerType,
  });
  Future<Either<Failure, void>> deleteContainer({
    required int id,
  });
  Future<Either<Failure, container_entity.Container>> editContainer({
    required int id,
    required String name,
    required String? description,
    required String containerType,
  });
}

