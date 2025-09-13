import 'package:drift/drift.dart';
import 'card_effects.dart';

class MtgCards extends Table {
  // 主キー
  IntColumn get id => integer().autoIncrement()();

  // 名前
  // 従来の表示名（後方互換のため保持）
  TextColumn get name => text()();
  // 英語名／日本語名（保存用）
  TextColumn get nameEn => text().nullable()();
  TextColumn get nameJa => text().nullable()();

  // 印刷に関するメタデータ
  TextColumn get rarity => text().nullable()();
  TextColumn get setName => text().nullable()();
  IntColumn get cardnumber => integer().nullable()();

  // Scryfall の oracle_id（言語・版をまたいで一意）
  TextColumn get oracleId => text().nullable()();

  // カード効果への参照
  IntColumn get effectId => integer().references(CardEffects, #id)();

  // oracleId のユニーク制約（SQLite は複数の NULL を許容）
  @override
  List<Set<Column>> get uniqueKeys => [
        {oracleId},
      ];
}
