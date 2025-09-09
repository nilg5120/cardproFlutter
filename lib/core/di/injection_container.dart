import 'package:get_it/get_it.dart';

import 'package:cardpro/db/database.dart';

// カード関連
import 'package:cardpro/features/cards/data/datasources/card_local_data_source.dart';
import 'package:cardpro/features/cards/data/repositories/card_repository_impl.dart';
import 'package:cardpro/features/cards/domain/repositories/card_repository.dart';
import 'package:cardpro/features/cards/domain/usecases/add_card.dart';
import 'package:cardpro/features/cards/domain/usecases/delete_card.dart';
import 'package:cardpro/features/cards/domain/usecases/edit_card.dart';
import 'package:cardpro/features/cards/domain/usecases/edit_card_full.dart';
import 'package:cardpro/features/cards/domain/usecases/get_cards.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/data/datasources/scryfall_api.dart';

// デッキ関連
import 'package:cardpro/features/decks/data/datasources/deck_local_data_source.dart';
import 'package:cardpro/features/decks/data/repositories/deck_repository_impl.dart';
import 'package:cardpro/features/decks/domain/repositories/deck_repository.dart';
import 'package:cardpro/features/decks/domain/usecases/add_deck.dart';
import 'package:cardpro/features/decks/domain/usecases/delete_deck.dart';
import 'package:cardpro/features/decks/domain/usecases/edit_deck.dart';
import 'package:cardpro/features/decks/domain/usecases/get_decks.dart';
import 'package:cardpro/features/decks/domain/usecases/set_active_deck.dart';
import 'package:cardpro/features/decks/presentation/bloc/deck_bloc.dart';

// コンテナ（保管場所）関連
import 'package:cardpro/features/containers/data/datasources/container_local_data_source.dart';
import 'package:cardpro/features/containers/data/repositories/container_repository_impl.dart';
import 'package:cardpro/features/containers/domain/repositories/container_repository.dart';
import 'package:cardpro/features/containers/domain/usecases/get_containers.dart';
import 'package:cardpro/features/containers/domain/usecases/add_container.dart';
import 'package:cardpro/features/containers/domain/usecases/delete_container.dart';
import 'package:cardpro/features/containers/domain/usecases/edit_container.dart';
import 'package:cardpro/features/containers/presentation/bloc/container_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // データベース
  final database = AppDatabase();
  // 初期データ投入
  // 補足: 一部のシェル環境ではエンコーディング問題を避けるため、print文は英数字中心にしています（動作へ影響なし）。
  // デフォルトのカード効果と初期カード/デッキを作成
  await database.ensureDefaultCardEffectsExist();
  await database.ensureInitialCardsAndDeckExist();
  await database.ensureInitialContainersExist();

  // 簡易的な件数確認用ログ
  final cardsCount = await (database.select(database.mtgCards)..limit(1000))
      .get()
      .then((l) => l.length);
  final instancesCount =
      await (database.select(database.cardInstances)..limit(1000))
          .get()
          .then((l) => l.length);
  // ignore: avoid_print
  final nonDeckContainerCount = await (database.select(database.containers)
          ..where((t) => t.containerType.isNotValue('deck')))
      .get()
      .then((l) => l.length);
  print('DB seeded: cards=$cardsCount, instances=$instancesCount, containers=$nonDeckContainerCount');

  sl.registerLazySingleton<AppDatabase>(() => database);

  // 機能 - カード
  // BLoC
  sl.registerFactory(
    () => CardBloc(
      getCards: sl(),
      addCard: sl(),
      deleteCard: sl(),
      editCard: sl(),
      editCardFull: sl(),
    ),
  );

  // ユースケース
  sl.registerLazySingleton(() => GetCards(sl()));
  sl.registerLazySingleton(() => AddCard(sl()));
  sl.registerLazySingleton(() => DeleteCard(sl()));
  sl.registerLazySingleton(() => EditCard(sl()));
  sl.registerLazySingleton(() => EditCardFull(sl()));

  // リポジトリ
  sl.registerLazySingleton<CardRepository>(
    () => CardRepositoryImpl(localDataSource: sl()),
  );

  // データソース
  sl.registerLazySingleton<CardLocalDataSource>(
    () => CardLocalDataSourceImpl(database: sl()),
  );

  // Remote API clients
  sl.registerLazySingleton<ScryfallApi>(() => ScryfallApi());

  // 機能 - デッキ
  // BLoC
  sl.registerFactory(
    () => DeckBloc(
      getDecks: sl(),
      addDeck: sl(),
      deleteDeck: sl(),
      editDeck: sl(),
      setActiveDeck: sl(),
    ),
  );

  // ユースケース
  sl.registerLazySingleton(() => GetDecks(sl()));
  sl.registerLazySingleton(() => AddDeck(sl()));
  sl.registerLazySingleton(() => DeleteDeck(sl()));
  sl.registerLazySingleton(() => EditDeck(sl()));
  sl.registerLazySingleton(() => SetActiveDeck(sl()));

  // リポジトリ
  sl.registerLazySingleton<DeckRepository>(
    () => DeckRepositoryImpl(localDataSource: sl()),
  );

  // データソース
  sl.registerLazySingleton<DeckLocalDataSource>(
    () => DeckLocalDataSourceImpl(database: sl()),
  );

  // 機能 - コンテナ（保管場所）
  // BLoC
  sl.registerFactory(
    () => ContainerBloc(
      getContainers: sl(),
      addContainer: sl(),
      deleteContainer: sl(),
      editContainer: sl(),
    ),
  );

  // ユースケース
  sl.registerLazySingleton(() => GetContainers(sl()));
  sl.registerLazySingleton(() => AddContainer(sl()));
  sl.registerLazySingleton(() => DeleteContainer(sl()));
  sl.registerLazySingleton(() => EditContainer(sl()));

  // リポジトリ
  sl.registerLazySingleton<ContainerRepository>(
    () => ContainerRepositoryImpl(localDataSource: sl()),
  );

  // データソース
  sl.registerLazySingleton<ContainerLocalDataSource>(
    () => ContainerLocalDataSourceImpl(database: sl()),
  );
}
