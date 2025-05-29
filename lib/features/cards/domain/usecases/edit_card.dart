import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/repositories/card_repository.dart';

class EditCard {
  final CardRepository repository;

  EditCard(this.repository);

  Future<Either<Failure, void>> call(EditCardParams params) async {
    return await repository.editCard(params.instance, params.description);
  }
}

class EditCardParams extends Equatable {
  final CardInstance instance;
  final String description;

  const EditCardParams({
    required this.instance,
    required this.description,
  });

  @override
  List<Object> get props => [instance, description];
}
