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
    // 各テスト前にモックとUseCaseを初期化
    mockRepository = MockCardRepository();
    usecase = DeleteCard(mockRepository);
  });

  final testCardInstance = CardInstance(
    id: 1,
    cardId: 1,
    updatedAt: DateTime(2025, 5, 29),
    description: 'Test description',
  );

  test('リポジトリ経由でカード個体を削除できる', () async {
    when(mockRepository.deleteCard(testCardInstance))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase(testCardInstance);

    expect(result, const Right<Failure, void>(null));
    verify(mockRepository.deleteCard(testCardInstance));
    verifyNoMoreInteractions(mockRepository);
  });

  test('リポジトリの失敗をそのまま伝播する', () async {
    final failure = DatabaseFailure(message: 'DB error');
    when(mockRepository.deleteCard(testCardInstance))
        .thenAnswer((_) async => Left(failure));

    final result = await usecase(testCardInstance);

    expect(result, Left<Failure, void>(failure));
    verify(mockRepository.deleteCard(testCardInstance));
    verifyNoMoreInteractions(mockRepository);
  });
}
