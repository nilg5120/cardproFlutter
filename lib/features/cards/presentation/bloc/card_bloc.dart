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

/// --- Events ---

/// カード関連イベントの基底クラス
abstract class CardEvent extends Equatable {
  const CardEvent();
  @override
  List<Object?> get props => [];
}

/// カード一覧を取得するイベント
class GetCardsEvent extends CardEvent {}

/// 新しいカードを追加するイベント
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

/// カード個体を削除するイベント
class DeleteCardEvent extends CardEvent {
  final CardInstance instance;

  const DeleteCardEvent(this.instance);

  @override
  List<Object> get props => [instance];
}

/// カード個体の説明を更新するイベント
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

/// カードマスター情報も含めて編集するイベント
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

/// --- States ---

/// カード状態の基底クラス
abstract class CardState extends Equatable {
  const CardState();
  @override
  List<Object?> get props => [];
}

/// 初期状態
class CardInitial extends CardState {}

/// 読み込み中
class CardLoading extends CardState {}

/// カード一覧の取得に成功した状態
class CardLoaded extends CardState {
  final List<CardWithInstance> cards;

  const CardLoaded(this.cards);

  @override
  List<Object> get props => [cards];
}

/// エラーが発生した状態
class CardError extends CardState {
  final String message;

  const CardError(this.message);

  @override
  List<Object> get props => [message];
}

/// --- BLoC本体 ---

/// カードに関するビジネスロジックを処理するBLoC
class CardBloc extends Bloc<CardEvent, CardState> {
  final GetCards getCards;
  final AddCard addCard;
  final DeleteCard deleteCard;
  final EditCard editCard;
  final EditCardFull editCardFull;

  /// コンストラクタ：ユースケースを注入
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

  /// カード一覧取得イベントの処理
  Future<void> _onGetCards(GetCardsEvent event, Emitter<CardState> emit) async {
    emit(CardLoading());
    final result = await getCards();
    result.fold(
      (failure) => emit(CardError(failure.message)),
      (cards) => emit(CardLoaded(cards)),
    );
  }

  /// カード追加イベントの処理
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
      (_) => add(GetCardsEvent()), // 成功後は再取得
    );
  }

  /// カード削除イベントの処理
  Future<void> _onDeleteCard(DeleteCardEvent event, Emitter<CardState> emit) async {
    emit(CardLoading());
    final result = await deleteCard(event.instance);
    result.fold(
      (failure) => emit(CardError(failure.message)),
      (_) => add(GetCardsEvent()),
    );
  }

  /// カード個体の説明のみ更新
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

  /// カードマスター情報を含めた更新
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
