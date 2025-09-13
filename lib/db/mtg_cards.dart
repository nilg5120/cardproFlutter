import 'package:drift/drift.dart';
import 'card_effects.dart';

class MtgCards extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Names
  // Legacy display name (kept for backward-compat)
  TextColumn get name => text()();
  // Stored English/Japanese names
  TextColumn get nameEn => text().nullable()();
  TextColumn get nameJa => text().nullable()();

  // Printing metadata
  TextColumn get rarity => text().nullable()();
  TextColumn get setName => text().nullable()();
  IntColumn get cardnumber => integer().nullable()();

  // Scryfall oracle_id (unique across languages/prints)
  TextColumn get oracleId => text().nullable()();

  // Relation to card effects
  IntColumn get effectId => integer().references(CardEffects, #id)();

  // Unique index on oracleId (SQLite allows multiple NULLs)
  @override
  List<Set<Column>> get uniqueKeys => [
        {oracleId},
      ];
}

