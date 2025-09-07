import 'package:drift/drift.dart';

class Containers extends Table {
  IntColumn get id => integer().autoIncrement()();    // 一意のID
  TextColumn get name => text().nullable()();         // 表示名（引き出し1、草デッキなど）
  TextColumn get description => text().nullable()();  // 補足説明
  TextColumn get containerType => text()();           // 'deck', 'drawer', 'binder' など

  BoolColumn get isActive => boolean().withDefault(const Constant(false))(); // 使用中フラグ
  @override
  Set<Column> get primaryKey => {id};
}
