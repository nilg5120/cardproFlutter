// lib/db/database.dart
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'card_effects.dart';
import 'card_instances.dart';
import 'container_card_locations.dart';
import 'containers.dart';
import 'mtg_cards.dart';

part 'database.g.dart';
part 'seed_data.dart';

@DriftDatabase(
  tables: [
    MtgCards,
    CardInstances,
    Containers,
    ContainerCardLocations,
    CardEffects,
  ],
)
class AppDatabase extends _$AppDatabase {
  final bool enableSeeding;
  AppDatabase({this.enableSeeding = true}) : super(_openConnection());

  // テスト用: メモリDBのエグゼキュータを差し込むための名前付きコンストラクタ
  AppDatabase.test(super.executor) : enableSeeding = false;

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // 初回作成時にベースラインの初期データを投入
          if (enableSeeding) {
            await ensureDefaultCardEffectsExist();
            await ensureInitialCardsAndDeckExist();
          }
        },
        onUpgrade: (m, from, to) async {
          if (from == 1) {
            await customStatement(
              'ALTER TABLE pokemon_cards RENAME TO mtg_cards',
            );
            from = 2; // fallthrough to next migration step
          }
          if (from == 2) {
            // v3: add isActive to containers
            await m.addColumn(containers, containers.isActive);
            from = 3; // fallthrough
          }
          if (from == 3) {
            // v4: add oracle_id to mtg_cards and a unique index
            await customStatement('ALTER TABLE mtg_cards ADD COLUMN oracle_id TEXT');
            // Create unique index (SQLite treats multiple NULLs as distinct)
            await customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS idx_mtg_cards_oracle_id ON mtg_cards(oracle_id)'
            );
          }
        },
      );
}

LazyDatabase _openConnection() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, 'cards.db');
    debugPrint('DB path: $dbPath');
    return SqfliteQueryExecutor(path: dbPath, logStatements: true);
  });
}

// 初期データ投入（Seed）関連の拡張は seed_data.dart に分離

extension CardQueries on AppDatabase {
  Future<List<(MtgCard, CardInstance)>> getCardWithMaster() {
    final query = select(cardInstances).join([
      innerJoin(mtgCards, mtgCards.id.equalsExp(cardInstances.cardId)),
    ]);

    return query
        .map((row) => (
              row.readTable(mtgCards),
              row.readTable(cardInstances),
            ))
        .get();
  }

  Future<List<CardEffect>> getAllCardEffects() {
    return select(cardEffects).get();
  }
}

extension DeckQueries on AppDatabase {
  Future<List<(MtgCard, CardInstance, ContainerCardLocation)>> getCardsInDeck(int containerId) {
    final query = select(containerCardLocations).join([
      innerJoin(cardInstances, cardInstances.id.equalsExp(containerCardLocations.cardInstanceId)),
      innerJoin(mtgCards, mtgCards.id.equalsExp(cardInstances.cardId)),
    ])
      ..where(containerCardLocations.containerId.equals(containerId));

    return query
        .map((row) => (
              row.readTable(mtgCards),
              row.readTable(cardInstances),
              row.readTable(containerCardLocations),
            ))
        .get();
  }

  Future<List<(MtgCard, CardInstance)>> getUnassignedCardInstances() {
    final query = select(cardInstances).join([
      innerJoin(mtgCards, mtgCards.id.equalsExp(cardInstances.cardId)),
      leftOuterJoin(
        containerCardLocations,
        containerCardLocations.cardInstanceId.equalsExp(cardInstances.id),
      ),
    ])
      ..where(containerCardLocations.cardInstanceId.isNull());

    return query
        .map((row) => (
              row.readTable(mtgCards),
              row.readTable(cardInstances),
            ))
        .get();
  }

  Future<void> addCardToDeck({
    required int containerId,
    required int cardInstanceId,
    String location = 'main',
  }) async {
    // 同一コンテナ内で同一インスタンスは board を1つに保つため、既存行をクリアしてから挿入
    await transaction(() async {
      await (delete(containerCardLocations)
            ..where((t) =>
                t.containerId.equals(containerId) &
                t.cardInstanceId.equals(cardInstanceId)))
          .go();

      await into(containerCardLocations).insert(
        ContainerCardLocationsCompanion.insert(
          containerId: containerId,
          cardInstanceId: cardInstanceId,
          location: location,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<void> removeCardFromDeck({
    required int containerId,
    required int cardInstanceId,
  }) async {
    await (delete(containerCardLocations)
          ..where((t) =>
              t.containerId.equals(containerId) &
              t.cardInstanceId.equals(cardInstanceId)))
        .go();
  }
}

extension ActiveDeckQueries on AppDatabase {
  Future<void> setActiveDeck(int deckId) async {
    await transaction(() async {
      // Reset all decks to inactive
      await (update(containers)
            ..where((t) => t.containerType.equals('deck')))
          .write(const ContainersCompanion(isActive: Value(false)));
      // Mark the selected deck active
      await (update(containers)
            ..where((t) => t.id.equals(deckId)))
          .write(const ContainersCompanion(isActive: Value(true)));
    });
  }

  Future<int?> getActiveDeckId() async {
    final row = await (select(containers)
          ..where((t) => t.containerType.equals('deck') & t.isActive.equals(true))
          ..limit(1))
        .getSingleOrNull();
    return row?.id;
  }
}
