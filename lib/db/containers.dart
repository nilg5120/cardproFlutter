import 'package:drift/drift.dart';

class Containers extends Table {
  // 主キー
  IntColumn get id => integer().autoIncrement()();
  // 表示名（例: 引き出しA、草案デッキ）
  TextColumn get name => text().nullable()();
  // 補足説明
  TextColumn get description => text().nullable()();
  // 種類（'deck' / 'drawer' / 'binder' など）
  TextColumn get containerType => text()();

  // 使用中フラグ
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
}

