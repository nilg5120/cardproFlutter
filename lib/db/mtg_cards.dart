import 'package:drift/drift.dart';
import 'card_effects.dart';

class MtgCards extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Basic fields
  TextColumn get oracleId => text().unique()();
  TextColumn get name => text()();
  TextColumn get rarity => text().nullable()();
  TextColumn get setName => text().nullable()();
  IntColumn get cardnumber => integer().nullable()();

  // Relation to card effects
  IntColumn get effectId => integer().references(CardEffects, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

