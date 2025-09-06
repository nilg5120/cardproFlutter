import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/domain/entities/card.dart' as card_entity;
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/domain/usecases/add_card.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'get_cards_test.mocks.dart';

void main() {
  late AddCard usecase;
  late MockCardRepository mockRepository;

  setUp(() {
    mockRepository = MockCardRepository();
    usecase = AddCard(mockRepository);
  });

  final testCard = card_entity.Card(
    id: 1,
    name: 'Test Card',
    rarity: 'R',
    setName: 'Sample',
    cardNumber: 123,
    effectId: 1,
  );

  final testCardInstance = CardInstance(
    id: 1,
    cardId: 1,
    updatedAt: DateTime(2025, 5, 29),
    description: 'Test description',
  );

  final testCardWithInstance = CardWithInstance(
    card: testCard,
    instance: testCardInstance,
  );

  final testParams = AddCardParams(
    name: 'Test Card',
    rarity: 'R',
    setName: 'Sample',
    cardNumber: 123,
    effectId: 1,
    description: 'Test description',
  );

  test('adds a card via repository', () async {
    when(mockRepository.addCard(
      name: 'Test Card',
      rarity: 'R',
      setName: 'Sample',
      cardNumber: 123,
      effectId: 1,
      description: 'Test description',
    )).thenAnswer((_) async => Right(testCardWithInstance));

    final result = await usecase(testParams);

    expect(result, Right<Failure, CardWithInstance>(testCardWithInstance));
    verify(mockRepository.addCard(
      name: 'Test Card',
      rarity: 'R',
      setName: 'Sample',
      cardNumber: 123,
      effectId: 1,
      description: 'Test description',
    ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('propagates repository failure', () async {
    final failure = DatabaseFailure(message: 'DB error');
    when(mockRepository.addCard(
      name: 'Test Card',
      rarity: 'R',
      setName: 'Sample',
      cardNumber: 123,
      effectId: 1,
      description: 'Test description',
    )).thenAnswer((_) async => Left(failure));

    final result = await usecase(testParams);

    expect(result, Left<Failure, CardWithInstance>(failure));
    verify(mockRepository.addCard(
      name: 'Test Card',
      rarity: 'R',
      setName: 'Sample',
      cardNumber: 123,
      effectId: 1,
      description: 'Test description',
    ));
    verifyNoMoreInteractions(mockRepository);
  });
}

