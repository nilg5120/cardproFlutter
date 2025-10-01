import 'package:bloc_test/bloc_test.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:cardpro/features/cards/domain/entities/card.dart' as card_entity;
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/domain/usecases/add_card.dart';
import 'package:cardpro/features/cards/domain/usecases/delete_card.dart';
import 'package:cardpro/features/cards/domain/usecases/edit_card.dart';
import 'package:cardpro/features/cards/domain/usecases/edit_card_full.dart';
import 'package:cardpro/features/cards/domain/usecases/get_cards.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_event.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'card_bloc_test.mocks.dart';

@GenerateMocks([GetCards, AddCard, DeleteCard, EditCard, EditCardFull])
void main() {
  late CardBloc bloc;
  late MockGetCards mockGetCards;
  late MockAddCard mockAddCard;
  late MockDeleteCard mockDeleteCard;
  late MockEditCard mockEditCard;
  late MockEditCardFull mockEditCardFull;

  setUp(() {
    mockGetCards = MockGetCards();
    mockAddCard = MockAddCard();
    mockDeleteCard = MockDeleteCard();
    mockEditCard = MockEditCard();
    mockEditCardFull = MockEditCardFull();
    bloc = CardBloc(
      getCards: mockGetCards,
      addCard: mockAddCard,
      deleteCard: mockDeleteCard,
      editCard: mockEditCard,
      editCardFull: mockEditCardFull,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final testCardWithInstance = CardWithInstance(
    card: card_entity.Card(
      id: 1,
      name: 'Test Card',
      rarity: 'R',
      setName: 'Sample',
      cardNumber: 123,
      lang: 'en',
      lang: 'en',
      effectId: 1,
    ),
    instance: CardInstance(
      id: 1,
      cardId: 1,
      updatedAt: DateTime(2025, 5, 29),
      description: 'Test description',
    ),
  );

  group('GetCardsEvent・井ｸ隕ｧ蜿門ｾ暦ｼ・, () {
    test('蛻晄悄迥ｶ諷九・ CardInitial', () {
      expect(bloc.state, CardInitial());
    });

    blocTest<CardBloc, CardState>(
      '謌仙粥譎ゅ・ CardLoaded 繧貞・縺・,
      build: () {
        when(mockGetCards())
            .thenAnswer((_) async => Right([testCardWithInstance]));
        return bloc;
      },
      act: (bloc) => bloc.add(GetCardsEvent()),
      expect: () => [
        CardLoading(),
        CardLoaded([testCardWithInstance]),
      ],
      verify: (_) => verify(mockGetCards()),
    );

    blocTest<CardBloc, CardState>(
      '螟ｱ謨玲凾縺ｯ CardError 繧貞・縺・,
      build: () {
        when(mockGetCards())
            .thenAnswer((_) async => Left(DatabaseFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(GetCardsEvent()),
      expect: () => [
        CardLoading(),
        const CardError('Error'),
      ],
      verify: (_) => verify(mockGetCards()),
    );
  });

  group('AddCardEvent・郁ｿｽ蜉・・, () {
    final addCardEvent = AddCardEvent(
      name: 'Test Card',
      oracleId: '0000-ORACLE-TEST',
      rarity: 'R',
      setName: 'Sample',
      cardNumber: 123,
      lang: 'en',
      effectId: 1,
      description: 'Test description',
    );

    blocTest<CardBloc, CardState>(
      '謌仙粥縺励◆繧芽ｪｭ縺ｿ霎ｼ縺ｿ蠕後↓荳隕ｧ譖ｴ譁ｰ',
      build: () {
        when(mockAddCard(any))
            .thenAnswer((_) async => Right(testCardWithInstance));
        when(mockGetCards())
            .thenAnswer((_) async => Right([testCardWithInstance]));
        return bloc;
      },
      act: (bloc) => bloc.add(addCardEvent),
      expect: () => [
        CardLoading(),
        CardLoaded([testCardWithInstance]),
      ],
      verify: (_) {
        verify(mockAddCard(any));
        verify(mockGetCards());
      },
    );

    blocTest<CardBloc, CardState>(
      '螟ｱ謨玲凾縺ｯ CardError 繧貞・縺・,
      build: () {
        when(mockAddCard(any))
            .thenAnswer((_) async => Left(DatabaseFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(addCardEvent),
      expect: () => [
        CardLoading(),
        const CardError('Error'),
      ],
      verify: (_) => verify(mockAddCard(any)),
    );
  });

  group('DeleteCardEvent・亥炎髯､・・, () {
    final deleteCardEvent = DeleteCardEvent(testCardWithInstance.instance);

    blocTest<CardBloc, CardState>(
      '謌仙粥縺励◆繧芽ｪｭ縺ｿ霎ｼ縺ｿ蠕後↓荳隕ｧ譖ｴ譁ｰ',
      build: () {
        when(mockDeleteCard(any))
            .thenAnswer((_) async => const Right(null));
        when(mockGetCards())
            .thenAnswer((_) async => Right([testCardWithInstance]));
        return bloc;
      },
      act: (bloc) => bloc.add(deleteCardEvent),
      expect: () => [
        CardLoading(),
        CardLoaded([testCardWithInstance]),
      ],
      verify: (_) {
        verify(mockDeleteCard(any));
        verify(mockGetCards());
      },
    );

    blocTest<CardBloc, CardState>(
      '螟ｱ謨玲凾縺ｯ CardError 繧貞・縺・,
      build: () {
        when(mockDeleteCard(any))
            .thenAnswer((_) async => Left(DatabaseFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(deleteCardEvent),
      expect: () => [
        CardLoading(),
        const CardError('Error'),
      ],
      verify: (_) => verify(mockDeleteCard(any)),
    );
  });

  group('EditCardEvent・亥､画峩・・, () {
    final editCardEvent = EditCardEvent(
      instance: testCardWithInstance.instance,
      description: 'New description',
      containerId: 42,
    );

    blocTest<CardBloc, CardState>(
      '謌仙粥縺励◆繧芽ｪｭ縺ｿ霎ｼ縺ｿ蠕後↓荳隕ｧ譖ｴ譁ｰ',
      build: () {
        when(mockEditCard(any))
            .thenAnswer((_) async => const Right(null));
        when(mockGetCards())
            .thenAnswer((_) async => Right([testCardWithInstance]));
        return bloc;
      },
      act: (bloc) => bloc.add(editCardEvent),
      expect: () => [
        CardLoading(),
        CardLoaded([testCardWithInstance]),
      ],
      verify: (_) {
        verify(mockEditCard(EditCardParams(
          instance: testCardWithInstance.instance,
          description: 'New description',
          containerId: 42,
        )));
        verify(mockGetCards());
      },
    );

    blocTest<CardBloc, CardState>(
      '螟ｱ謨玲凾縺ｯ CardError 繧貞・縺・,
      build: () {
        when(mockEditCard(any))
            .thenAnswer((_) async => Left(DatabaseFailure(message: 'Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(editCardEvent),
      expect: () => [
        CardLoading(),
        const CardError('Error'),
      ],
      verify: (_) => verify(mockEditCard(any)),
    );
  });
}
