// lib/db/database.dart
import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'mtg_cards.dart';
import 'card_instances.dart';
import 'containers.dart';
import 'container_card_locations.dart';
import 'dart:io'; // ← Platform 判定用
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // ← 追加
import 'package:flutter/foundation.dart'; // これを追加！


import 'card_effects.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [MtgCards, CardInstances, Containers, ContainerCardLocations,
           CardEffects],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

    // ✅ テスト用（メモリDBを渡す用）
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
            await customStatement('ALTER TABLE pokemon_cards RENAME TO mtg_cards');
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

    // 👇 パスの確認用に出力
    debugPrint('📁 DBパス: $dbPath');

    return SqfliteQueryExecutor(path: dbPath, logStatements: true);
  });
}


extension SeedData on AppDatabase {
  Future<void> ensureInitialCardsAndDeckExist() async {
    // Ensure effects exist first
    await ensureDefaultCardEffectsExist();

    // Seed cards and instances if none exist
    final cardsCount = await mtgCards.count().getSingle();
    if (cardsCount == 0) {
      // Use the first available effect as a default
      final effect = await (select(cardEffects)..limit(1)).getSingle();

      final bolt = await into(mtgCards).insertReturning(
        MtgCardsCompanion.insert(
          name: '稲妻', // Lightning Bolt
          rarity: const Value('C'),
          setName: const Value('Alpha'),
          cardnumber: const Value(116),
          effectId: effect.id,
        ),
      );

      final counterspell = await into(mtgCards).insertReturning(
        MtgCardsCompanion.insert(
          name: '対抗呪文', // Counterspell
          rarity: const Value('U'),
          setName: const Value('Alpha'),
          cardnumber: const Value(69),
          effectId: effect.id,
        ),
      );

      final llanowar = await into(mtgCards).insertReturning(
        MtgCardsCompanion.insert(
          name: 'ラノワールのエルフ', // Llanowar Elves
          rarity: const Value('C'),
          setName: const Value('Alpha'),
          cardnumber: const Value(213),
          effectId: effect.id,
        ),
      );

      final now = DateTime.now();
      await batch((b) {
        b.insertAll(cardInstances, [
          CardInstancesCompanion.insert(
            cardId: bolt.id,
            description: const Value('初期カード'),
            updatedAt: Value(now),
          ),
          CardInstancesCompanion.insert(
            cardId: counterspell.id,
            description: const Value('初期カード'),
            updatedAt: Value(now),
          ),
          CardInstancesCompanion.insert(
            cardId: llanowar.id,
            description: const Value('初期カード'),
            updatedAt: Value(now),
          ),
        ]);
      });
    }

    // Seed a default deck and put some cards in it if no decks exist
    final decks = await (select(containers)
          ..where((t) => t.containerType.equals('deck')))
        .get();
    if (decks.isEmpty) {
      final deck = await into(containers).insertReturning(
        ContainersCompanion.insert(
          name: const Value('初期デッキ'),
          description: const Value('自動作成されたデッキ'),
          containerType: 'deck',
        ),
      );

      final instances = await select(cardInstances).get();
      final selected = instances.take(3).toList();
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
      }
    }
  }
}

extension CardQueries on AppDatabase {
  Future<List<(MtgCard, CardInstance)>> getCardWithMaster() {
    final query = select(cardInstances).join([
      innerJoin(mtgCards, mtgCards.id.equalsExp(cardInstances.cardId)),
    ]);

    return query.map((row) => (
          row.readTable(mtgCards),
          row.readTable(cardInstances),
        )).get();
  }

  // カード効果を取得するメソッド
  Future<List<CardEffect>> getAllCardEffects() {
    return select(cardEffects).get();
  }

  // デフォルトのカード効果を追加するメソッド
  Future<void> ensureDefaultCardEffectsExist() async {
    final effectsCount = await cardEffects.count().getSingle();
    if (effectsCount == 0) {
      // デフォルトのカード効果を追加
      await batch((batch) {
        batch.insertAll(cardEffects, [
          CardEffectsCompanion.insert(
            name: '基本効果',
            description: '特別な効果はありません',
          ),
          CardEffectsCompanion.insert(
            name: 'エネルギー加速',
            description: 'エネルギーカードを追加で付けることができます',
          ),
          CardEffectsCompanion.insert(
            name: 'ダメージ増加',
            description: '与えるダメージが増加します',
          ),
        ]);
      });
    }
  }
}
