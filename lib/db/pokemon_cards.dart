import 'package:drift/drift.dart';

class PokemonCards extends Table {
  IntColumn get id => integer().autoIncrement()();            // 一意のID（UUIDなど）
  TextColumn get name => text()();                           // カード名
  TextColumn get rarity => text().nullable()();              // レアリティ（コモン、レアなど）
  TextColumn get setName => text().nullable()();             // 拡張パック名
  IntColumn get cardnumber => integer().nullable()();        // カード番号

  @override
  Set<Column> get primaryKey => {id};
}
