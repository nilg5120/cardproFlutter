import 'package:dartz/dartz.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/domain/repositories/card_repository.dart';

class GetCards {
  final CardRepository repository;

  GetCards(this.repository);

  Future<Either<Failure, List<CardWithInstance>>> call() async {
    return await repository.getCards();
  }
}
