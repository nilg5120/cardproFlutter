import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/repositories/card_repository.dart';

class EditCard {
  final CardRepository repository;

  EditCard(this.repository);

  Future<Either<Failure, void>> call(EditCardParams params) async {
    return await repository.editCard(
      params.instance,
      params.description,
      containerId: params.containerId,
    );
  }
}

class EditCardParams extends Equatable {
  final CardInstance instance;
  final String description;
  final int? containerId;

  const EditCardParams({
    required this.instance,
    required this.description,
    this.containerId,
  });

  @override
  List<Object?> get props => [instance, description, containerId];
}
