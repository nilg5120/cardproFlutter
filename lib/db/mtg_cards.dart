import 'package:drift/drift.dart';
import 'card_effects.dart';

class MtgCards extends Table {
  // Primary key
  IntColumn get id => integer().autoIncrement()();

  // Basic fields
  TextColumn get name => text()();
  TextColumn get rarity => text().nullable()();
  TextColumn get setName => text().nullable()();
  IntColumn get cardnumber => integer().nullable()();
  // Scryfall oracle id (unique across languages/prints)
  TextColumn get oracleId => text().nullable()();

  // Relation to card effects
  IntColumn get effectId => integer().references(CardEffects, #id)();

  // Unique constraint on oracleId (allows multiple NULLs)
  @override
  List<Set<Column>> get uniqueKeys => [
        {oracleId},
      ];
}
