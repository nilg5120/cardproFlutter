import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart';
import 'package:cardpro/features/decks/domain/usecases/get_decks.dart';
import 'package:cardpro/features/decks/domain/usecases/add_deck.dart';
import 'package:cardpro/features/decks/domain/usecases/delete_deck.dart';
import 'package:cardpro/features/decks/domain/usecases/edit_deck.dart';
import 'package:cardpro/features/decks/presentation/bloc/deck_event.dart';


// States
abstract class DeckState extends Equatable {
  const DeckState();

  @override
  List<Object?> get props => [];
}

class DeckInitial extends DeckState {}

class DeckLoading extends DeckState {}

class DeckLoaded extends DeckState {
  final List<Container> decks;

  const DeckLoaded(this.decks);

  @override
  List<Object> get props => [decks];
}

class DeckError extends DeckState {
  final String message;

  const DeckError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class DeckBloc extends Bloc<DeckEvent, DeckState> {
  final GetDecks getDecks;
  final AddDeck addDeck;
  final DeleteDeck deleteDeck;
  final EditDeck editDeck;

  DeckBloc({
    required this.getDecks,
    required this.addDeck,
    required this.deleteDeck,
    required this.editDeck,
  }) : super(DeckInitial()) {
    on<GetDecksEvent>(_onGetDecks);
    on<AddDeckEvent>(_onAddDeck);
    on<DeleteDeckEvent>(_onDeleteDeck);
    on<EditDeckEvent>(_onEditDeck);
  }

  Future<void> _onGetDecks(GetDecksEvent event, Emitter<DeckState> emit) async {
    emit(DeckLoading());
    final result = await getDecks();
    result.fold(
      (failure) => emit(DeckError(failure.message)),
      (decks) => emit(DeckLoaded(decks)),
    );
  }

  Future<void> _onAddDeck(AddDeckEvent event, Emitter<DeckState> emit) async {
    emit(DeckLoading());
    final params = AddDeckParams(
      name: event.name,
      description: event.description,
    );
    final result = await addDeck(params);
    result.fold(
      (failure) => emit(DeckError(failure.message)),
      (_) => add(GetDecksEvent()),
    );
  }

  Future<void> _onDeleteDeck(DeleteDeckEvent event, Emitter<DeckState> emit) async {
    emit(DeckLoading());
    final params = DeleteDeckParams(id: event.id);
    final result = await deleteDeck(params);
    result.fold(
      (failure) => emit(DeckError(failure.message)),
      (_) => add(GetDecksEvent()),
    );
  }

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
      (_) => add(GetDecksEvent()),
    );
  }
}
