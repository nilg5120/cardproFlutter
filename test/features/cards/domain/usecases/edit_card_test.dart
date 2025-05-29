import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cardpro/features/cards/domain/usecases/edit_card.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:dartz/dartz.dart';

import 'get_cards_test.mocks.dart'; // 既存のモックを再利用

void main() {
  late EditCard usecase;
  late MockCardRepository mockRepository;

  setUp(() {
    mockRepository = MockCardRepository();
    usecase = EditCard(mockRepository);
  });

  final testCardInstance = CardInstance(
    id: 1,
    cardId: 1,
    updatedAt: DateTime(2025, 5, 29),
    description: 'テスト説明',
  );

  final testParams = EditCardParams(
    instance: testCardInstance,
    description: '新しい説明',
  );

  test('正常系：リポジトリを通じてカードを編集できる', () async {
    // arrange
    when(mockRepository.editCard(testCardInstance, '新しい説明'))
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await usecase(testParams);

    // assert
    expect(result, const Right<Failure, void>(null));
    verify(mockRepository.editCard(testCardInstance, '新しい説明'));
    verifyNoMoreInteractions(mockRepository);
  });

  test('異常系：リポジトリからエラーが返された場合はそのまま返す', () async {
    // arrange
    final failure = DatabaseFailure(message: 'データベースエラー');
    when(mockRepository.editCard(testCardInstance, '新しい説明'))
        .thenAnswer((_) async => Left(failure));

    // act
    final result = await usecase(testParams);

    // assert
    expect(result, Left<Failure, void>(failure));
    verify(mockRepository.editCard(testCardInstance, '新しい説明'));
    verifyNoMoreInteractions(mockRepository);
  });
}
