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
    // 蜷・ユ繧ｹ繝亥燕縺ｫ繝｢繝・け縺ｨUseCase繧貞・譛溷喧
    mockRepository = MockCardRepository();
    usecase = DeleteCard(mockRepository);
  });

  final testCardInstance = CardInstance(
    id: 1,
    cardId: 1,
    lang: 'en',
    updatedAt: DateTime(2025, 5, 29),
    description: 'Test description',
  );

  test('繝ｪ繝昴ず繝医Μ邨檎罰縺ｧ繧ｫ繝ｼ繝牙倶ｽ薙ｒ蜑企勁縺ｧ縺阪ｋ', () async {
    when(mockRepository.deleteCard(testCardInstance))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase(testCardInstance);

    expect(result, const Right<Failure, void>(null));
    verify(mockRepository.deleteCard(testCardInstance));
    verifyNoMoreInteractions(mockRepository);
  });

  test('繝ｪ繝昴ず繝医Μ縺ｮ螟ｱ謨励ｒ縺昴・縺ｾ縺ｾ莨晄眺縺吶ｋ', () async {
    final failure = DatabaseFailure(message: 'DB error');
    when(mockRepository.deleteCard(testCardInstance))
        .thenAnswer((_) async => Left(failure));

    final result = await usecase(testCardInstance);

    expect(result, Left<Failure, void>(failure));
    verify(mockRepository.deleteCard(testCardInstance));
    verifyNoMoreInteractions(mockRepository);
  });
}
