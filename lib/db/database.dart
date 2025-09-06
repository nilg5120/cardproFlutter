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

extension SeedData on AppDatabase {
  Future<void> ensureInitialCardsAndDeckExist() async {
    try {
      debugPrint('Seeding initial data...');

      // Ensure effects exist first
      await ensureDefaultCardEffectsExist();
      debugPrint('Card effects ensured.');

      // Seed cards and instances if none exist
      final existingCards = await select(mtgCards).get();
      debugPrint('Existing cards: ${existingCards.length}');

      if (existingCards.isEmpty) {
        debugPrint('Creating initial cards...');

        final effects = await select(cardEffects).get();
        if (effects.isEmpty) {
          throw Exception('No card effects found');
        }
        final effect = effects.first;
        debugPrint('Using effect: ${effect.name} (ID: ${effect.id})');

        final bolt = await into(mtgCards).insertReturning(
          MtgCardsCompanion.insert(
            name: 'Lightning Bolt',
            rarity: const Value('C'),
            setName: const Value('Alpha'),
            cardnumber: const Value(116),
            effectId: effect.id,
          ),
        );
        debugPrint('Created card: Lightning Bolt (ID: ${bolt.id})');

        final counterspell = await into(mtgCards).insertReturning(
          MtgCardsCompanion.insert(
            name: 'Counterspell',
            rarity: const Value('U'),
            setName: const Value('Alpha'),
            cardnumber: const Value(69),
            effectId: effect.id,
          ),
        );
        debugPrint('Created card: Counterspell (ID: ${counterspell.id})');

        final llanowar = await into(mtgCards).insertReturning(
          MtgCardsCompanion.insert(
            name: 'Llanowar Elves',
            rarity: const Value('C'),
            setName: const Value('Alpha'),
            cardnumber: const Value(213),
            effectId: effect.id,
          ),
        );
        debugPrint('Created card: Llanowar Elves (ID: ${llanowar.id})');

        final now = DateTime.now();
        await batch((b) {
          b.insertAll(cardInstances, [
            CardInstancesCompanion.insert(
              cardId: bolt.id,
              description: const Value('Initial card'),
              updatedAt: Value(now),
            ),
            CardInstancesCompanion.insert(
              cardId: counterspell.id,
              description: const Value('Initial card'),
              updatedAt: Value(now),
            ),
            CardInstancesCompanion.insert(
              cardId: llanowar.id,
              description: const Value('Initial card'),
              updatedAt: Value(now),
            ),
          ]);
        });
        debugPrint('Created initial card instances.');
      }

      // Seed a default deck if none exist
      final decks = await (select(containers)
            ..where((t) => t.containerType.equals('deck')))
          .get();
      debugPrint('Existing decks: ${decks.length}');

      if (decks.isEmpty) {
        debugPrint('Creating default deck...');

        final deck = await into(containers).insertReturning(
          ContainersCompanion.insert(
            name: const Value('Default Deck'),
            description: const Value('Auto-created deck'),
            containerType: 'deck',
          ),
        );
        debugPrint('Created deck (ID: ${deck.id})');

        final instances = await select(cardInstances).get();
        final selected = instances.take(3).toList();
        debugPrint('Adding ${selected.length} cards to the deck...');

        if (selected.isNotEmpty) {
          await batch((b) {
            b.insertAll(
              containerCardLocations,
              selected
                  .map((ci) => ContainerCardLocationsCompanion.insert(
                        containerId: deck.id,
                        cardInstanceId: ci.id,
                        location: 'main',
                      ))
                  .toList(),
            );
          });
          debugPrint('Added cards to the deck.');
        }
      }

      debugPrint('Seeding complete.');
    } catch (e, stackTrace) {
      debugPrint('Seeding error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

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

  Future<void> ensureDefaultCardEffectsExist() async {
    final effectsCount = await cardEffects.count().getSingle();
    if (effectsCount == 0) {
      await batch((batch) {
        batch.insertAll(cardEffects, [
          CardEffectsCompanion.insert(
            name: 'Basic',
            description: 'No special effect',
          ),
          CardEffectsCompanion.insert(
            name: 'Energy Boost',
            description: 'Gain additional energy',
          ),
          CardEffectsCompanion.insert(
            name: 'Damage Up',
            description: 'Increase dealt damage',
          ),
        ]);
      });
    }
  }
}
