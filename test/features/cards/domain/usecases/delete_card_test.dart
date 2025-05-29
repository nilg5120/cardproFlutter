import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cardpro/features/cards/domain/usecases/delete_card.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:dartz/dartz.dart';

import 'get_cards_test.mocks.dart'; // 既存のモックを再利用

void main() {
  late DeleteCard usecase;
  late MockCardRepository mockRepository;

  setUp(() {
    mockRepository = MockCardRepository();
    usecase = DeleteCard(mockRepository);
  });

  final testCardInstance = CardInstance(
    id: 1,
    cardId: 1,
    updatedAt: DateTime(2025, 5, 29),
    description: 'テスト説明',
  );

  test('正常系：リポジトリを通じてカードを削除できる', () async {
    // arrange
    when(mockRepository.deleteCard(testCardInstance))
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(testCardInstance);

    // assert
    expect(result, const Right<Failure, void>(null));
    verify(mockRepository.deleteCard(testCardInstance));
    verifyNoMoreInteractions(mockRepository);
  });

  test('異常系：リポジトリからエラーが返された場合はそのまま返す', () async {
    // arrange
    final failure = DatabaseFailure(message: 'データベースエラー');
    when(mockRepository.deleteCard(testCardInstance))
        .thenAnswer((_) async => Left(failure));

    // act
    final result = await usecase(testCardInstance);

    // assert
    expect(result, Left<Failure, void>(failure));
    verify(mockRepository.deleteCard(testCardInstance));
    verifyNoMoreInteractions(mockRepository);
  });
}
