import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cardpro/features/cards/domain/repositories/card_repository.dart';
import 'package:cardpro/features/cards/domain/usecases/get_cards.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/domain/entities/card.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:dartz/dartz.dart';

import 'get_cards_test.mocks.dart';

@GenerateMocks([CardRepository])
void main() {
  late GetCards usecase;
  late MockCardRepository mockRepository;

  setUp(() {
    mockRepository = MockCardRepository();
    usecase = GetCards(mockRepository);
  });

  final testCard = Card(
    id: 1,
    name: 'テストカード',
    rarity: 'R',
    setName: 'テストセット',
    cardNumber: 123,
    effectId: 1,
  );

  final testCardInstance = CardInstance(
    id: 1,
    cardId: 1,
    updatedAt: DateTime(2025, 5, 29),
    description: 'テスト説明',
  );

  final testCardWithInstance = CardWithInstance(
    card: testCard,
    instance: testCardInstance,
  );

  test('正常系：リポジトリからカード一覧を取得できる', () async {
    // arrange
    when(mockRepository.getCards())
        .thenAnswer((_) async => Right([testCardWithInstance]));

    // act
    final result = await usecase();

    // assert
    expect(result, Right<Failure, List<CardWithInstance>>([testCardWithInstance]));
    verify(mockRepository.getCards());
    verifyNoMoreInteractions(mockRepository);
  });

  test('異常系：リポジトリからエラーが返された場合はそのまま返す', () async {
    // arrange
    final failure = DatabaseFailure(message: 'データベースエラー');
    when(mockRepository.getCards())
        .thenAnswer((_) async => Left(failure));

    // act
    final result = await usecase();

    // assert
    expect(result, Left<Failure, List<CardWithInstance>>(failure));
    verify(mockRepository.getCards());
    verifyNoMoreInteractions(mockRepository);
  });
}
