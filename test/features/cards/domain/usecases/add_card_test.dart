import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cardpro/features/cards/domain/repositories/card_repository.dart';
import 'package:cardpro/features/cards/domain/usecases/add_card.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/domain/entities/card.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:dartz/dartz.dart';

import 'get_cards_test.mocks.dart'; // 既存のモックを再利用

void main() {
  late AddCard usecase;
  late MockCardRepository mockRepository;

  setUp(() {
    mockRepository = MockCardRepository();
    usecase = AddCard(mockRepository);
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

  final testParams = AddCardParams(
    name: 'テストカード',
    rarity: 'R',
    setName: 'テストセット',
    cardNumber: 123,
    effectId: 1,
    description: 'テスト説明',
  );

  test('正常系：リポジトリを通じてカードを追加できる', () async {
    // arrange
    when(mockRepository.addCard(
      name: 'テストカード',
      rarity: 'R',
      setName: 'テストセット',
      cardNumber: 123,
      effectId: 1,
      description: 'テスト説明',
    )).thenAnswer((_) async => Right(testCardWithInstance));

    // act
    final result = await usecase(testParams);

    // assert
    expect(result, Right<Failure, CardWithInstance>(testCardWithInstance));
    verify(mockRepository.addCard(
      name: 'テストカード',
      rarity: 'R',
      setName: 'テストセット',
      cardNumber: 123,
      effectId: 1,
      description: 'テスト説明',
    ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('異常系：リポジトリからエラーが返された場合はそのまま返す', () async {
    // arrange
    final failure = DatabaseFailure(message: 'データベースエラー');
    when(mockRepository.addCard(
      name: 'テストカード',
      rarity: 'R',
      setName: 'テストセット',
      cardNumber: 123,
      effectId: 1,
      description: 'テスト説明',
    )).thenAnswer((_) async => Left(failure));

    // act
    final result = await usecase(testParams);

    // assert
    expect(result, Left<Failure, CardWithInstance>(failure));
    verify(mockRepository.addCard(
      name: 'テストカード',
      rarity: 'R',
      setName: 'テストセット',
      cardNumber: 123,
      effectId: 1,
      description: 'テスト説明',
    ));
    verifyNoMoreInteractions(mockRepository);
  });
}
