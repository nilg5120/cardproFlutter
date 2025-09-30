import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/usecases/edit_card.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'get_cards_test.mocks.dart';

void main() {
  late EditCard usecase;
  late MockCardRepository mockRepository;

  setUp(() {
    // 吁E��スト前にモチE��とUseCaseを�E期化
    mockRepository = MockCardRepository();
    usecase = EditCard(mockRepository);
  });

  final testCardInstance = CardInstance(
    id: 1,
    cardId: 1,
    lang: 'en',
    updatedAt: DateTime(2025, 5, 29),
    description: 'Test description',
  );

  final testParams = EditCardParams(
    instance: testCardInstance,
    description: 'New description',
  );

  test('リポジトリ経由でカード個体を編雁E��きる', () async {
    when(mockRepository.editCard(testCardInstance, 'New description'))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase(testParams);

    expect(result, const Right<Failure, void>(null));
    verify(mockRepository.editCard(testCardInstance, 'New description'));
    verifyNoMoreInteractions(mockRepository);
  });

  test('リポジトリの失敗をそ�Eまま伝播する', () async {
    final failure = DatabaseFailure(message: 'DB error');
    when(mockRepository.editCard(testCardInstance, 'New description'))
        .thenAnswer((_) async => Left(failure));

    final result = await usecase(testParams);

    expect(result, Left<Failure, void>(failure));
    verify(mockRepository.editCard(testCardInstance, 'New description'));
    verifyNoMoreInteractions(mockRepository);
  });
}
