import 'package:get_it/get_it.dart';
import 'package:cardpro/features/cards/data/datasources/card_local_data_source.dart';
import 'package:cardpro/features/cards/data/repositories/card_repository_impl.dart';
import 'package:cardpro/features/cards/domain/repositories/card_repository.dart';
import 'package:cardpro/features/cards/domain/usecases/get_cards.dart';
import 'package:cardpro/features/cards/domain/usecases/add_card.dart';
import 'package:cardpro/features/cards/domain/usecases/delete_card.dart';
import 'package:cardpro/features/cards/domain/usecases/edit_card.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/decks/data/datasources/deck_local_data_source.dart';
import 'package:cardpro/features/decks/data/repositories/deck_repository_impl.dart';
import 'package:cardpro/features/decks/domain/repositories/deck_repository.dart';
import 'package:cardpro/features/decks/domain/usecases/get_decks.dart';
import 'package:cardpro/features/decks/domain/usecases/add_deck.dart';
import 'package:cardpro/features/decks/presentation/bloc/deck_bloc.dart';
import 'package:cardpro/db/database.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Database
  final database = AppDatabase();
  // デフォルトのカード効果を追加
  await database.ensureDefaultCardEffectsExist();
  sl.registerLazySingleton<AppDatabase>(() => database);

  // Features - Cards
  // BLoC
  sl.registerFactory(
    () => CardBloc(
      getCards: sl(),
      addCard: sl(),
      deleteCard: sl(),
      editCard: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCards(sl()));
  sl.registerLazySingleton(() => AddCard(sl()));
  sl.registerLazySingleton(() => DeleteCard(sl()));
  sl.registerLazySingleton(() => EditCard(sl()));

  // Repository
  sl.registerLazySingleton<CardRepository>(
    () => CardRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CardLocalDataSource>(
    () => CardLocalDataSourceImpl(database: sl()),
  );

  // Features - Decks
  // BLoC
  sl.registerFactory(
    () => DeckBloc(
      getDecks: sl(),
      addDeck: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDecks(sl()));
  sl.registerLazySingleton(() => AddDeck(sl()));

  // Repository
  sl.registerLazySingleton<DeckRepository>(
    () => DeckRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<DeckLocalDataSource>(
    () => DeckLocalDataSourceImpl(database: sl()),
  );
}
