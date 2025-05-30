// lib/db/database.dart
import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'pokemon_cards.dart';
import 'card_instances.dart';
import 'containers.dart';
import 'container_card_locations.dart';
import 'dart:io'; // ← Platform 判定用
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // ← 追加
import 'package:flutter/foundation.dart'; // これを追加！


import 'card_effects.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [PokemonCards, CardInstances, Containers, ContainerCardLocations,
           CardEffects],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

    // ✅ テスト用（メモリDBを渡す用）
  AppDatabase.test(super.executor);

  @override
  int get schemaVersion => 1;
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


extension CardQueries on AppDatabase {
  Future<List<(PokemonCard, CardInstance)>> getCardWithMaster() {
    final query = select(cardInstances).join([
      innerJoin(pokemonCards, pokemonCards.id.equalsExp(cardInstances.cardId)),
    ]);

    return query.map((row) => (
          row.readTable(pokemonCards),
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
