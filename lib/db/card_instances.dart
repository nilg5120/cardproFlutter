import 'package:drift/drift.dart';

class CardInstances extends Table {
  // 主キー
  IntColumn get id => integer().autoIncrement()();
  // 参照: MtgCards.id（カードマスタ）
  IntColumn get cardId => integer()();

  // 任意項目
  // 最終更新日時
  DateTimeColumn get updatedAt => dateTime().nullable()();
  // メモ/状態などの自由記述
  TextColumn get description => text().nullable()();
}

