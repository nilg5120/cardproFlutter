import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/usecases/delete_card.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'get_cards_test.mocks.dart';

void main() {
  late DeleteCard usecase;
  late MockCardRepository mockRepository;

  setUp(() {
    mockRepository = MockCardRepository();
    usecase = DeleteCard(mockRepository);
  });

  final testCardInstance = CardInstance(
    id: 1,
    cardId: 1,
    updatedAt: DateTime(2025, 5, 29),
    description: 'Test description',
  );

  test('deletes a card via repository', () async {
    when(mockRepository.deleteCard(testCardInstance))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase(testCardInstance);

    expect(result, const Right<Failure, void>(null));
    verify(mockRepository.deleteCard(testCardInstance));
    verifyNoMoreInteractions(mockRepository);
  });

  test('propagates repository failure', () async {
    final failure = DatabaseFailure(message: 'DB error');
    when(mockRepository.deleteCard(testCardInstance))
        .thenAnswer((_) async => Left(failure));

    final result = await usecase(testCardInstance);

    expect(result, Left<Failure, void>(failure));
    verify(mockRepository.deleteCard(testCardInstance));
    verifyNoMoreInteractions(mockRepository);
  });
}

