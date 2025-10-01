import 'package:drift/drift.dart';

class CardInstances extends Table {
  // 主キー
  IntColumn get id => integer().autoIncrement()();
  // 参照: MtgCards.id へのカードマスタ
  IntColumn get cardId => integer()();
  // Scryfall の言語コード (例: en, ja)
  TextColumn get lang => text().nullable()();

  // 任意項目
  // 最終更新日時
  DateTimeColumn get updatedAt => dateTime().nullable()();
  // メモ/状態などの自由記述
  TextColumn get description => text().nullable()();
}
