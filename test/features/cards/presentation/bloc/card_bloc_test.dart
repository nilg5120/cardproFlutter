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
      effectId: 1,
    ),
    instance: CardInstance(
      id: 1,
      cardId: 1,
      updatedAt: DateTime(2025, 5, 29),
      description: 'Test description',
    ),
  );

  group('GetCardsEvent�i�ꗗ�擾�j', () {
    test('������Ԃ� CardInitial', () {
      expect(bloc.state, CardInitial());
    });

    blocTest<CardBloc, CardState>(
      '�������� CardLoaded ���o��',
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
      '���s���� CardError ���o��',
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

  group('AddCardEvent�i�ǉ��j', () {
    final addCardEvent = AddCardEvent(
      name: 'Test Card',
      rarity: 'R',
      setName: 'Sample',
      cardNumber: 123,
      effectId: 1,
      description: 'Test description',
    );

    blocTest<CardBloc, CardState>(
      '�������͓ǂݍ��݌�Ɉꗗ�X�V',
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
      '���s���� CardError ���o��',
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

  group('DeleteCardEvent�i�폜�j', () {
    final deleteCardEvent = DeleteCardEvent(testCardWithInstance.instance);

    blocTest<CardBloc, CardState>(
      '�������͓ǂݍ��݌�Ɉꗗ�X�V',
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
      '���s���� CardError ���o��',
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

  group('EditCardEvent�i�ҏW�j', () {
    final editCardEvent = EditCardEvent(
      instance: testCardWithInstance.instance,
      description: 'New description',
    );

    blocTest<CardBloc, CardState>(
      '�������͓ǂݍ��݌�Ɉꗗ�X�V',
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
        verify(mockEditCard(any));
        verify(mockGetCards());
      },
    );

    blocTest<CardBloc, CardState>(
      '���s���� CardError ���o��',
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


