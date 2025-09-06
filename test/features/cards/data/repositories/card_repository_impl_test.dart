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
    updatedAt: DateTime(2025, 5, 29),
    description: 'Test description',
  );

  final testCardWithInstanceModel = CardWithInstanceModel(
    card: testCardModel,
    instance: testCardInstanceModel,
  );

  group('getCards', () {
    test('returns cards from local datasource', () async {
      when(mockLocalDataSource.getCards())
          .thenAnswer((_) async => [testCardWithInstanceModel]);

      final result = await repository.getCards();

      expect(result, isA<Right<Failure, List<CardWithInstance>>>());
      expect(result.getOrElse(() => []), contains(testCardWithInstanceModel));
      verify(mockLocalDataSource.getCards());
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('returns DatabaseFailure when datasource throws', () async {
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

  group('addCard', () {
    test('adds a card', () async {
      when(mockLocalDataSource.addCard(
        name: 'Test Card',
        rarity: 'R',
        setName: 'Sample',
        cardNumber: 123,
        effectId: 1,
        description: 'Test description',
      )).thenAnswer((_) async => testCardWithInstanceModel);

      final result = await repository.addCard(
        name: 'Test Card',
        rarity: 'R',
        setName: 'Sample',
        cardNumber: 123,
        effectId: 1,
        description: 'Test description',
      );

      expect(result, Right<Failure, CardWithInstance>(testCardWithInstanceModel));
      verify(mockLocalDataSource.addCard(
        name: 'Test Card',
        rarity: 'R',
        setName: 'Sample',
        cardNumber: 123,
        effectId: 1,
        description: 'Test description',
      ));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('returns DatabaseFailure when datasource throws', () async {
      when(mockLocalDataSource.addCard(
        name: 'Test Card',
        rarity: 'R',
        setName: 'Sample',
        cardNumber: 123,
        effectId: 1,
        description: 'Test description',
      )).thenThrow(Exception('DB error'));

      final result = await repository.addCard(
        name: 'Test Card',
        rarity: 'R',
        setName: 'Sample',
        cardNumber: 123,
        effectId: 1,
        description: 'Test description',
      );

      expect(
        result,
        Left<Failure, CardWithInstance>(
          DatabaseFailure(message: 'Exception: DB error'),
        ),
      );
      verify(mockLocalDataSource.addCard(
        name: 'Test Card',
        rarity: 'R',
        setName: 'Sample',
        cardNumber: 123,
        effectId: 1,
        description: 'Test description',
      ));
      verifyNoMoreInteractions(mockLocalDataSource);
    });
  });

  group('deleteCard', () {
    test('deletes a card instance', () async {
      when(mockLocalDataSource.deleteCard(testCardInstanceModel))
          .thenAnswer((_) async => {});

      final result = await repository.deleteCard(testCardInstanceModel);

      expect(result, const Right<Failure, void>(null));
      verify(mockLocalDataSource.deleteCard(testCardInstanceModel));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('returns DatabaseFailure when datasource throws', () async {
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

  group('editCard', () {
    test('edits card instance description', () async {
      when(mockLocalDataSource.editCard(testCardInstanceModel, 'New description'))
          .thenAnswer((_) async => {});

      final result = await repository.editCard(testCardInstanceModel, 'New description');

      expect(result, const Right<Failure, void>(null));
      verify(mockLocalDataSource.editCard(testCardInstanceModel, 'New description'));
      verifyNoMoreInteractions(mockLocalDataSource);
    });

    test('returns DatabaseFailure when datasource throws', () async {
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

