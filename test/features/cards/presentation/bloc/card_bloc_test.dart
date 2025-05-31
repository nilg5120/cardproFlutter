import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cardpro/features/cards/domain/usecases/get_cards.dart';
import 'package:cardpro/features/cards/domain/usecases/add_card.dart';
import 'package:cardpro/features/cards/domain/usecases/delete_card.dart';
import 'package:cardpro/features/cards/domain/usecases/edit_card.dart';
import 'package:cardpro/features/cards/domain/usecases/edit_card_full.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/domain/entities/card.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';

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


  final testCardInstance = CardInstance(
    id: 1,
    cardId: 1,
    updatedAt: DateTime(2025, 5, 29),
    description: 'テスト説明',
  );

  final testCardWithInstance = CardWithInstance(
    card: Card(
      id: 1,
      name: 'テストカード',
      rarity: 'R',
      setName: 'テストセット',
      cardNumber: 123,
      effectId: 1,
    ),
    instance: CardInstance(
      id: 1,
      cardId: 1,
      updatedAt: DateTime(2025, 5, 29),
      description: 'テスト説明',
    ),
  );

  group('GetCardsEvent', () {
    test('初期状態はCardInitial', () {
      expect(bloc.state, CardInitial());
    });

    blocTest<CardBloc, CardState>(
      '正常系：カード一覧を取得できる',
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
      verify: (_) {
        verify(mockGetCards());
      },
    );

    blocTest<CardBloc, CardState>(
      '異常系：エラーが発生した場合はCardErrorを返す',
      build: () {
        when(mockGetCards())
            .thenAnswer((_) async => Left(DatabaseFailure(message: 'エラー')));
        return bloc;
      },
      act: (bloc) => bloc.add(GetCardsEvent()),
      expect: () => [
        CardLoading(),
        CardError('エラー'),
      ],
      verify: (_) {
        verify(mockGetCards());
      },
    );
  });

  group('AddCardEvent', () {
    final addCardEvent = AddCardEvent(
      name: 'テストカード',
      rarity: 'R',
      setName: 'テストセット',
      cardNumber: 123,
      effectId: 1,
      description: 'テスト説明',
    );

    blocTest<CardBloc, CardState>(
      '正常系：カードを追加できる',
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
      '異常系：エラーが発生した場合はCardErrorを返す',
      build: () {
        when(mockAddCard(any))
            .thenAnswer((_) async => Left(DatabaseFailure(message: 'エラー')));
        return bloc;
      },
      act: (bloc) => bloc.add(addCardEvent),
      expect: () => [
        CardLoading(),
        CardError('エラー'),
      ],
      verify: (_) {
        verify(mockAddCard(any));
      },
    );
  });

  group('DeleteCardEvent', () {
    final deleteCardEvent = DeleteCardEvent(testCardInstance);

    blocTest<CardBloc, CardState>(
      '正常系：カードを削除できる',
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
      '異常系：エラーが発生した場合はCardErrorを返す',
      build: () {
        when(mockDeleteCard(any))
            .thenAnswer((_) async => Left(DatabaseFailure(message: 'エラー')));
        return bloc;
      },
      act: (bloc) => bloc.add(deleteCardEvent),
      expect: () => [
        CardLoading(),
        CardError('エラー'),
      ],
      verify: (_) {
        verify(mockDeleteCard(any));
      },
    );
  });

  group('EditCardEvent', () {
    final editCardEvent = EditCardEvent(
      instance: testCardInstance,
      description: '新しい説明',
    );

    blocTest<CardBloc, CardState>(
      '正常系：カードを編集できる',
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
      '異常系：エラーが発生した場合はCardErrorを返す',
      build: () {
        when(mockEditCard(any))
            .thenAnswer((_) async => Left(DatabaseFailure(message: 'エラー')));
        return bloc;
      },
      act: (bloc) => bloc.add(editCardEvent),
      expect: () => [
        CardLoading(),
        CardError('エラー'),
      ],
      verify: (_) {
        verify(mockEditCard(any));
      },
    );
  });
}
