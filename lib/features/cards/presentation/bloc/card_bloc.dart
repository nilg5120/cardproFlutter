import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cardpro/features/cards/domain/entities/card.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/domain/usecases/get_cards.dart';
import 'package:cardpro/features/cards/domain/usecases/add_card.dart';
import 'package:cardpro/features/cards/domain/usecases/delete_card.dart';
import 'package:cardpro/features/cards/domain/usecases/edit_card.dart';
import 'package:cardpro/features/cards/domain/usecases/edit_card_full.dart';

// Events
abstract class CardEvent extends Equatable {
  const CardEvent();

  @override
  List<Object?> get props => [];
}

class GetCardsEvent extends CardEvent {}

class AddCardEvent extends CardEvent {
  final String name;
  final String? rarity;
  final String? setName;
  final int? cardNumber;
  final int effectId;
  final String? description;

  const AddCardEvent({
    required this.name,
    this.rarity,
    this.setName,
    this.cardNumber,
    required this.effectId,
    this.description,
  });

  @override
  List<Object?> get props => [name, rarity, setName, cardNumber, effectId, description];
}

class DeleteCardEvent extends CardEvent {
  final CardInstance instance;

  const DeleteCardEvent(this.instance);

  @override
  List<Object> get props => [instance];
}

class EditCardEvent extends CardEvent {
  final CardInstance instance;
  final String description;

  const EditCardEvent({
    required this.instance,
    required this.description,
  });

  @override
  List<Object> get props => [instance, description];
}

class EditCardFullEvent extends CardEvent {
  final Card card;
  final CardInstance instance;
  final String? rarity;
  final String? setName;
  final int? cardNumber;
  final String? description;

  const EditCardFullEvent({
    required this.card,
    required this.instance,
    required this.rarity,
    required this.setName,
    required this.cardNumber,
    required this.description,
  });

  @override
  List<Object?> get props => [card, instance, rarity, setName, cardNumber, description];
}

// States
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

// BLoC
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
    emit(CardLoading());
    final result = await getCards();
    result.fold(
      (failure) => emit(CardError(failure.message)),
      (cards) => emit(CardLoaded(cards)),
    );
  }

  Future<void> _onAddCard(AddCardEvent event, Emitter<CardState> emit) async {
    emit(CardLoading());
    final params = AddCardParams(
      name: event.name,
      rarity: event.rarity,
      setName: event.setName,
      cardNumber: event.cardNumber,
      effectId: event.effectId,
      description: event.description,
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
