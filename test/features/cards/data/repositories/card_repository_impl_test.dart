import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/data/datasources/card_local_data_source.dart';
import 'package:cardpro/features/cards/data/models/card_instance_model.dart';
import 'package:cardpro/features/cards/data/models/card_model.dart';
import 'package:cardpro/features/cards/data/models/card_with_instance_model.dart';
import 'package:cardpro/features/cards/data/repositories/card_repository_impl.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'card_repository_impl_test.mocks.dart';

@GenerateMocks([CardLocalDataSource])
void main() {
  late CardRepositoryImpl repository;
  late MockCardLocalDataSource mockLocalDataSource;

  setUp(() {
    // 吁E��スト前にモチE��とリポジトリを�E期化
    mockLocalDataSource = MockCardLocalDataSource();
    repository = CardRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  final testCardModel = CardModel(
    id: 1,
    name: 'Test Card',
    rarity: 'R',
    setName: 'Sample',
    cardNumber: 123,
    effectId: 1,
  );

  final testCardInstanceModel = CardInstanceModel(
    id: 1,
    cardId: 1,
    lang: 'en',
    updatedAt: DateTime(2025, 5, 29),
    description: 'Test description',
  );

  final testCardWithInstanceModel = CardWithInstanceModel(
    card: testCardModel,
    instance: testCardInstanceModel,
  );

  group('getCards�E�取得！E, () {
    test('ローカルチE�Eタソースからカード一覧を返す', () async {
      when(mockLocalDataSource.getCards())
          .thenAnswer((_) async => [testCardWithInstanceModel]);

      final result = await repository.getCards();

      expect(result, isA<Right<Failure, List<CardWithInstance>>>());
      expect(result.getOrElse(() => []), contains(testCardWithInstanceModel));
      verify(mockLocalDataSource.getCards());
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('チE�Eタソース例外時はDatabaseFailureを返す', () async {
      when(mockLocalDataSource.getCards()).thenThrow(Exception('DB error'));

      final result = await repository.getCards();

      expect(
        result,
        Left<Failure, List<CardWithInstance>>(
          DatabaseFailure(message: 'Exception: DB error'),
        ),
      );
      verify(mockLocalDataSource.getCards());
      verifyNoMoreInteractions(mockLocalDataSource);
    });
  });

  group('addCard�E�追加�E�E, () {
    test('カードを追加できる', () async {
      when(mockLocalDataSource.addCard(
        name: 'Test Card',
        oracleId: '0000-ORACLE-TEST',
        rarity: 'R',
        setName: 'Sample',
        cardNumber: 123,
        lang: 'en',
        effectId: 1,
        description: 'Test description',
        quantity: 1,
      )).thenAnswer((_) async => testCardWithInstanceModel);

      final result = await repository.addCard(
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

      expect(result, Right<Failure, CardWithInstance>(testCardWithInstanceModel));
      verify(mockLocalDataSource.addCard(
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
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('チE�Eタソース例外時はDatabaseFailureを返す', () async {
      when(mockLocalDataSource.addCard(
        name: 'Test Card',
        oracleId: '0000-ORACLE-TEST',
        rarity: 'R',
        setName: 'Sample',
        cardNumber: 123,
        lang: 'en',
        effectId: 1,
        description: 'Test description',
        quantity: 1,
      )).thenThrow(Exception('DB error'));

      final result = await repository.addCard(
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

      expect(
        result,
        Left<Failure, CardWithInstance>(
          DatabaseFailure(message: 'Exception: DB error'),
        ),
      );
      verify(mockLocalDataSource.addCard(
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
      verifyNoMoreInteractions(mockLocalDataSource);
    });
  });

  group('deleteCard�E�削除�E�E, () {
    test('カード個体を削除できる', () async {
      when(mockLocalDataSource.deleteCard(testCardInstanceModel))
          .thenAnswer((_) async => {});

      final result = await repository.deleteCard(testCardInstanceModel);

      expect(result, const Right<Failure, void>(null));
      verify(mockLocalDataSource.deleteCard(testCardInstanceModel));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('チE�Eタソース例外時はDatabaseFailureを返す', () async {
      when(mockLocalDataSource.deleteCard(testCardInstanceModel))
          .thenThrow(Exception('DB error'));

      final result = await repository.deleteCard(testCardInstanceModel);

      expect(
        result,
        Left<Failure, void>(DatabaseFailure(message: 'Exception: DB error')),
      );
      verify(mockLocalDataSource.deleteCard(testCardInstanceModel));
      verifyNoMoreInteractions(mockLocalDataSource);
    });
  });

  group('editCard�E�編雁E��E, () {
    test('カード個体�E説明文を編雁E��きる', () async {
      when(mockLocalDataSource.editCard(testCardInstanceModel, 'New description'))
          .thenAnswer((_) async => {});

      final result = await repository.editCard(testCardInstanceModel, 'New description');

      expect(result, const Right<Failure, void>(null));
      verify(mockLocalDataSource.editCard(testCardInstanceModel, 'New description'));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('チE�Eタソース例外時はDatabaseFailureを返す', () async {
      when(mockLocalDataSource.editCard(testCardInstanceModel, 'New description'))
          .thenThrow(Exception('DB error'));

      final result = await repository.editCard(testCardInstanceModel, 'New description');

      expect(
        result,
        Left<Failure, void>(DatabaseFailure(message: 'Exception: DB error')),
      );
      verify(mockLocalDataSource.editCard(testCardInstanceModel, 'New description'));
      verifyNoMoreInteractions(mockLocalDataSource);
    });
  });
}
