import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart';
import 'package:cardpro/features/decks/domain/usecases/get_decks.dart';
import 'package:cardpro/features/decks/domain/usecases/add_deck.dart';

// Events
abstract class DeckEvent extends Equatable {
  const DeckEvent();

  @override
  List<Object?> get props => [];
}

class GetDecksEvent extends DeckEvent {}

class AddDeckEvent extends DeckEvent {
  final String name;
  final String? description;

  const AddDeckEvent({
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [name, description];
}

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

  DeckBloc({
    required this.getDecks,
    required this.addDeck,
  }) : super(DeckInitial()) {
    on<GetDecksEvent>(_onGetDecks);
    on<AddDeckEvent>(_onAddDeck);
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
}
