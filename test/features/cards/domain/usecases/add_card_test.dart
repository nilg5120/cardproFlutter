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
    // 蜷・ユ繧ｹ繝亥燕縺ｫ繝｢繝・け縺ｨUseCase繧貞・譛溷喧
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
    lang: 'en',
    updatedAt: DateTime(2025, 5, 29),
    description: 'Test description',
  );

  final testCardWithInstance = CardWithInstance(
    card: testCard,
    instance: testCardInstance,
  );

  final testParams = AddCardParams(
    name: 'Test Card',
    oracleId: '0000-ORACLE-TEST',
    rarity: 'R',
    setName: 'Sample',
    cardNumber: 123,
    lang: 'en',
    effectId: 1,
    description: 'Test description',
    quantity: 1,
  );

  test('繝ｪ繝昴ず繝医Μ邨檎罰縺ｧ繧ｫ繝ｼ繝峨ｒ霑ｽ蜉縺ｧ縺阪ｋ', () async {
    when(mockRepository.addCard(
      name: 'Test Card',
      oracleId: '0000-ORACLE-TEST',
      rarity: 'R',
      setName: 'Sample',
      cardNumber: 123,
      lang: 'en',
      effectId: 1,
      description: 'Test description',
      quantity: 1,
    )).thenAnswer((_) async => Right(testCardWithInstance));

    final result = await usecase(testParams);

    expect(result, Right<Failure, CardWithInstance>(testCardWithInstance));
    verify(mockRepository.addCard(
      name: 'Test Card',
      oracleId: '0000-ORACLE-TEST',
      rarity: 'R',
      setName: 'Sample',
      cardNumber: 123,
      lang: 'en',
      effectId: 1,
      description: 'Test description',
      quantity: 1,
    ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('繝ｪ繝昴ず繝医Μ縺ｮ螟ｱ謨励ｒ縺昴・縺ｾ縺ｾ莨晄眺縺吶ｋ', () async {
    final failure = DatabaseFailure(message: 'DB error');
    when(mockRepository.addCard(
      name: 'Test Card',
      oracleId: '0000-ORACLE-TEST',
      rarity: 'R',
      setName: 'Sample',
      cardNumber: 123,
      lang: 'en',
      effectId: 1,
      description: 'Test description',
      quantity: 1,
    )).thenAnswer((_) async => Left(failure));

    final result = await usecase(testParams);

    expect(result, Left<Failure, CardWithInstance>(failure));
    verify(mockRepository.addCard(
      name: 'Test Card',
      oracleId: '0000-ORACLE-TEST',
      rarity: 'R',
      setName: 'Sample',
      cardNumber: 123,
      lang: 'en',
      effectId: 1,
      description: 'Test description',
      quantity: 1,
    ));
    verifyNoMoreInteractions(mockRepository);
  });
}
