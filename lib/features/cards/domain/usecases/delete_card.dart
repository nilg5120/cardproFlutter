import 'package:dartz/dartz.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/repositories/card_repository.dart';

class DeleteCard {
  final CardRepository repository;

  DeleteCard(this.repository);

  Future<Either<Failure, void>> call(CardInstance instance) async {
    return await repository.deleteCard(instance);
  }
}
