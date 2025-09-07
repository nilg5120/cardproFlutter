import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/domain/entities/card.dart' as card_entity;
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/domain/repositories/card_repository.dart';
import 'package:cardpro/features/cards/domain/usecases/get_cards.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_cards_test.mocks.dart';

@GenerateMocks([CardRepository])
void main() {
  late GetCards usecase;
  late MockCardRepository mockRepository;

  setUp(() {
    // 各テスト前にモックとUseCaseを初期化
    mockRepository = MockCardRepository();
    usecase = GetCards(mockRepository);
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

  test('リポジトリからカード一覧を取得できる', () async {
    when(mockRepository.getCards())
        .thenAnswer((_) async => Right([testCardWithInstance]));

    final result = await usecase();

    expect(result, isA<Right<Failure, List<CardWithInstance>>>());
    expect(result.getOrElse(() => []), contains(testCardWithInstance));
    verify(mockRepository.getCards());
    verifyNoMoreInteractions(mockRepository);
  });

  test('リポジトリの失敗をそのまま伝播する', () async {
    final failure = DatabaseFailure(message: 'DB error');
    when(mockRepository.getCards()).thenAnswer((_) async => Left(failure));

    final result = await usecase();

    expect(result, Left<Failure, List<CardWithInstance>>(failure));
    verify(mockRepository.getCards());
    verifyNoMoreInteractions(mockRepository);
  });
}
