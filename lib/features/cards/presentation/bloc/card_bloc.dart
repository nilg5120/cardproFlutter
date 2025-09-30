import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/domain/usecases/get_cards.dart';
import 'package:cardpro/features/cards/domain/usecases/add_card.dart';
import 'package:cardpro/features/cards/domain/usecases/delete_card.dart';
import 'package:cardpro/features/cards/domain/usecases/edit_card.dart';
import 'package:cardpro/features/cards/domain/usecases/edit_card_full.dart';
// ignore_for_file: avoid_print
import 'package:cardpro/features/cards/presentation/bloc/card_event.dart';

/// --- スチE�Eト定義 ---

abstract class CardState extends Equatable {
  const CardState();
  @override
  List<Object?> get props => [];
}

class CardInitial extends CardState {}

class CardLoading extends CardState {}

class CardLoaded extends CardState {
  final List<CardWithInstance> cards;

  const CardLoaded(this.cards);

  @override
  List<Object> get props => [cards];
}

class CardError extends CardState {
  final String message;

  const CardError(this.message);

  @override
  List<Object> get props => [message];
}

/// --- BLoC本佁E---

class CardBloc extends Bloc<CardEvent, CardState> {
  final GetCards getCards;
  final AddCard addCard;
  final DeleteCard deleteCard;
  final EditCard editCard;
  final EditCardFull editCardFull;

  CardBloc({
    required this.getCards,
    required this.addCard,
    required this.deleteCard,
    required this.editCard,
    required this.editCardFull,
  }) : super(CardInitial()) {
    on<GetCardsEvent>(_onGetCards);
    on<AddCardEvent>(_onAddCard);
    on<DeleteCardEvent>(_onDeleteCard);
    on<EditCardEvent>(_onEditCard);
    on<EditCardFullEvent>(_onEditCardFull);
  }

  Future<void> _onGetCards(GetCardsEvent event, Emitter<CardState> emit) async {
    print('🎯 CardBloc: GetCardsEvent受信');
    emit(CardLoading());
    
    final result = await getCards();
    result.fold(
      (failure) {
        print('❁ECardBloc: エラー発甁E- ${failure.message}');
        emit(CardError(failure.message));
      },
      (cards) {
        print('✁ECardBloc: カード取得�E劁E- ${cards.length}件');
        emit(CardLoaded(cards));
      },
    );
  }

  Future<void> _onAddCard(AddCardEvent event, Emitter<CardState> emit) async {
    emit(CardLoading());
    final params = AddCardParams(
      name: event.name,
      nameEn: event.nameEn,
      nameJa: event.nameJa,
      oracleId: event.oracleId,
      rarity: event.rarity,
      setName: event.setName,
      cardNumber: event.cardNumber,
      lang: event.lang,
      effectId: event.effectId,
      description: event.description,
      quantity: event.quantity,
    );
    final result = await addCard(params);
    result.fold(
      (failure) => emit(CardError(failure.message)),
      (_) => add(GetCardsEvent()),
    );
  }

  Future<void> _onDeleteCard(DeleteCardEvent event, Emitter<CardState> emit) async {
    emit(CardLoading());
    final result = await deleteCard(event.instance);
    result.fold(
      (failure) => emit(CardError(failure.message)),
      (_) => add(GetCardsEvent()),
    );
  }

  Future<void> _onEditCard(EditCardEvent event, Emitter<CardState> emit) async {
    emit(CardLoading());
    final params = EditCardParams(
      instance: event.instance,
      description: event.description,
      containerId: event.containerId,
    );
    final result = await editCard(params);
    result.fold(
      (failure) => emit(CardError(failure.message)),
      (_) => add(GetCardsEvent()),
    );
  }

  Future<void> _onEditCardFull(EditCardFullEvent event, Emitter<CardState> emit) async {
    emit(CardLoading());
    final params = EditCardFullParams(
      card: event.card,
      instance: event.instance,
      rarity: event.rarity,
      setName: event.setName,
      cardNumber: event.cardNumber,
      description: event.description,
    );
    final result = await editCardFull(params);
    result.fold(
      (failure) => emit(CardError(failure.message)),
      (_) => add(GetCardsEvent()),
    );
  }
}
