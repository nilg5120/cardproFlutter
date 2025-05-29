import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cardpro/features/cards/data/datasources/card_local_data_source.dart';
import 'package:cardpro/features/cards/data/repositories/card_repository_impl.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/data/models/card_with_instance_model.dart';
import 'package:cardpro/features/cards/data/models/card_model.dart';
import 'package:cardpro/features/cards/data/models/card_instance_model.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:dartz/dartz.dart';

import 'card_repository_impl_test.mocks.dart';

@GenerateMocks([CardLocalDataSource])
void main() {
  late CardRepositoryImpl repository;
  late MockCardLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockCardLocalDataSource();
    repository = CardRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  final testCardModel = CardModel(
    id: 1,
    name: 'テストカード',
    rarity: 'R',
    setName: 'テストセット',
    cardNumber: 123,
    effectId: 1,
  );

  final testCardInstanceModel = CardInstanceModel(
    id: 1,
    cardId: 1,
    updatedAt: DateTime(2025, 5, 29),
    description: 'テスト説明',
  );

  final testCardWithInstanceModel = CardWithInstanceModel(
    card: testCardModel,
    instance: testCardInstanceModel,
  );

  group('getCards', () {
    test('正常系：ローカルデータソースからカード一覧を取得できる', () async {
      // arrange
      when(mockLocalDataSource.getCards())
          .thenAnswer((_) async => [testCardWithInstanceModel]);

      // act
      final result = await repository.getCards();

      // assert
      expect(result, Right<Failure, List<CardWithInstance>>([testCardWithInstanceModel]));
      verify(mockLocalDataSource.getCards());
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('異常系：例外が発生した場合はDatabaseFailureを返す', () async {
      // arrange
      when(mockLocalDataSource.getCards())
          .thenThrow(Exception('データベースエラー'));

      // act
      final result = await repository.getCards();

      // assert
      expect(result, Left<Failure, List<CardWithInstance>>(
          DatabaseFailure(message: 'Exception: データベースエラー')));
      verify(mockLocalDataSource.getCards());
      verifyNoMoreInteractions(mockLocalDataSource);
    });
  });

  group('addCard', () {
    test('正常系：カードを追加できる', () async {
      // arrange
      when(mockLocalDataSource.addCard(
        name: 'テストカード',
        rarity: 'R',
        setName: 'テストセット',
        cardNumber: 123,
        effectId: 1,
        description: 'テスト説明',
      )).thenAnswer((_) async => testCardWithInstanceModel);

      // act
      final result = await repository.addCard(
        name: 'テストカード',
        rarity: 'R',
        setName: 'テストセット',
        cardNumber: 123,
        effectId: 1,
        description: 'テスト説明',
      );

      // assert
      expect(result, Right<Failure, CardWithInstance>(testCardWithInstanceModel));
      verify(mockLocalDataSource.addCard(
        name: 'テストカード',
        rarity: 'R',
        setName: 'テストセット',
        cardNumber: 123,
        effectId: 1,
        description: 'テスト説明',
      ));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('異常系：例外が発生した場合はDatabaseFailureを返す', () async {
      // arrange
      when(mockLocalDataSource.addCard(
        name: 'テストカード',
        rarity: 'R',
        setName: 'テストセット',
        cardNumber: 123,
        effectId: 1,
        description: 'テスト説明',
      )).thenThrow(Exception('データベースエラー'));

      // act
      final result = await repository.addCard(
        name: 'テストカード',
        rarity: 'R',
        setName: 'テストセット',
        cardNumber: 123,
        effectId: 1,
        description: 'テスト説明',
      );

      // assert
      expect(result, Left<Failure, CardWithInstance>(
          DatabaseFailure(message: 'Exception: データベースエラー')));
      verify(mockLocalDataSource.addCard(
        name: 'テストカード',
        rarity: 'R',
        setName: 'テストセット',
        cardNumber: 123,
        effectId: 1,
        description: 'テスト説明',
      ));
      verifyNoMoreInteractions(mockLocalDataSource);
    });
  });

  group('deleteCard', () {
    test('正常系：カードを削除できる', () async {
      // arrange
      when(mockLocalDataSource.deleteCard(testCardInstanceModel))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.deleteCard(testCardInstanceModel);

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(mockLocalDataSource.deleteCard(testCardInstanceModel));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('異常系：例外が発生した場合はDatabaseFailureを返す', () async {
      // arrange
      when(mockLocalDataSource.deleteCard(testCardInstanceModel))
          .thenThrow(Exception('データベースエラー'));

      // act
      final result = await repository.deleteCard(testCardInstanceModel);

      // assert
      expect(result, Left<Failure, void>(
          DatabaseFailure(message: 'Exception: データベースエラー')));
      verify(mockLocalDataSource.deleteCard(testCardInstanceModel));
      verifyNoMoreInteractions(mockLocalDataSource);
    });
  });

  group('editCard', () {
    test('正常系：カードを編集できる', () async {
      // arrange
      when(mockLocalDataSource.editCard(testCardInstanceModel, '新しい説明'))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.editCard(testCardInstanceModel, '新しい説明');

      // assert
      expect(result, const Right<Failure, void>(null));
      verify(mockLocalDataSource.editCard(testCardInstanceModel, '新しい説明'));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('異常系：例外が発生した場合はDatabaseFailureを返す', () async {
      // arrange
      when(mockLocalDataSource.editCard(testCardInstanceModel, '新しい説明'))
          .thenThrow(Exception('データベースエラー'));

      // act
      final result = await repository.editCard(testCardInstanceModel, '新しい説明');

      // assert
      expect(result, Left<Failure, void>(
          DatabaseFailure(message: 'Exception: データベースエラー')));
      verify(mockLocalDataSource.editCard(testCardInstanceModel, '新しい説明'));
      verifyNoMoreInteractions(mockLocalDataSource);
    });
  });
}
