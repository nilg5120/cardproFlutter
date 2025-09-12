import 'package:drift/drift.dart';
import 'card_effects.dart';

class MtgCards extends Table {
  // 主キー
  IntColumn get id => integer().autoIncrement()();

  // 基本項目
  TextColumn get name => text()();
  TextColumn get rarity => text().nullable()();
  TextColumn get setName => text().nullable()();
  IntColumn get cardnumber => integer().nullable()();
  // Scryfall の oracle_id（言語や印刷を跨いで一意）
  TextColumn get oracleId => text().nullable()();

  // カード効果との関連
  IntColumn get effectId => integer().references(CardEffects, #id)();

  // oracleId への一意制約（NULL は複数可）
  @override
  List<Set<Column>> get uniqueKeys => [
        {oracleId},
      ];
}
