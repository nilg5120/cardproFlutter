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
  AppDatabase() : super(_openConnection());

  // Named constructor for tests to inject an in-memory executor
  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Seed baseline data on first creation
          await ensureDefaultCardEffectsExist();
          await ensureInitialCardsAndDeckExist();
        },
        onUpgrade: (m, from, to) async {
          if (from == 1) {
            await customStatement(
              'ALTER TABLE pokemon_cards RENAME TO mtg_cards',
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

// Seeding-related extension moved to part file: seed_data.dart

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
