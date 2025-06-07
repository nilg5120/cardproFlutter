import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart';
import 'package:cardpro/features/decks/domain/usecases/get_decks.dart';
import 'package:cardpro/features/decks/domain/usecases/add_deck.dart';
import 'package:cardpro/features/decks/domain/usecases/delete_deck.dart';
import 'package:cardpro/features/decks/domain/usecases/edit_deck.dart';
import 'package:cardpro/features/decks/presentation/bloc/deck_event.dart';

/// デッキ一覧管理に関する状態（State）のベースクラス
abstract class DeckState extends Equatable {
  const DeckState();

  @override
  List<Object?> get props => [];
}

/// 初期状態
class DeckInitial extends DeckState {}

/// 読み込み中状態（ローディングインジケータ表示用）
class DeckLoading extends DeckState {}

/// デッキ一覧の取得に成功した状態
class DeckLoaded extends DeckState {
  final List<Container> decks;

  const DeckLoaded(this.decks);

  @override
  List<Object> get props => [decks];
}

/// エラー発生時の状態
class DeckError extends DeckState {
  final String message;

  const DeckError(this.message);

  @override
  List<Object> get props => [message];
}

/// デッキ機能のビジネスロジックを管理する BLoC クラス
class DeckBloc extends Bloc<DeckEvent, DeckState> {
  final GetDecks getDecks;
  final AddDeck addDeck;
  final DeleteDeck deleteDeck;
  final EditDeck editDeck;

  /// コンストラクタ：ユースケースを注入
  DeckBloc({
    required this.getDecks,
    required this.addDeck,
    required this.deleteDeck,
    required this.editDeck,
  }) : super(DeckInitial()) {
    // イベントごとの処理を登録
    on<GetDecksEvent>(_onGetDecks);
    on<AddDeckEvent>(_onAddDeck);
    on<DeleteDeckEvent>(_onDeleteDeck);
    on<EditDeckEvent>(_onEditDeck);
  }

  /// デッキ一覧取得イベントの処理
  Future<void> _onGetDecks(GetDecksEvent event, Emitter<DeckState> emit) async {
    emit(DeckLoading()); // ローディング状態に
    final result = await getDecks(); // ユースケースを実行
    result.fold(
      (failure) => emit(DeckError(failure.message)), // 失敗時
      (decks) => emit(DeckLoaded(decks)),            // 成功時
    );
  }

  /// デッキ追加イベントの処理
  Future<void> _onAddDeck(AddDeckEvent event, Emitter<DeckState> emit) async {
    emit(DeckLoading());
    final params = AddDeckParams(
      name: event.name,
      description: event.description,
    );
    final result = await addDeck(params);
    result.fold(
      (failure) => emit(DeckError(failure.message)),
      (_) => add(GetDecksEvent()), // 成功後、一覧再取得
    );
  }

  /// デッキ削除イベントの処理
  Future<void> _onDeleteDeck(DeleteDeckEvent event, Emitter<DeckState> emit) async {
    emit(DeckLoading());
    final params = DeleteDeckParams(id: event.id);
    final result = await deleteDeck(params);
    result.fold(
      (failure) => emit(DeckError(failure.message)),
      (_) => add(GetDecksEvent()), // 成功後、一覧再取得
    );
  }

  /// デッキ編集イベントの処理
  Future<void> _onEditDeck(EditDeckEvent event, Emitter<DeckState> emit) async {
    emit(DeckLoading());
    final params = EditDeckParams(
      id: event.id,
      name: event.name,
      description: event.description,
    );
    final result = await editDeck(params);
    result.fold(
      (failure) => emit(DeckError(failure.message)),
      (_) => add(GetDecksEvent()), // 成功後、一覧再取得
    );
  }
}
