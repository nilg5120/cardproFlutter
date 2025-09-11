import 'package:drift/drift.dart';

class CardInstances extends Table {
  IntColumn get id => integer().autoIncrement()();           // 例: UUIDなど
  IntColumn get cardId => integer()();         // MtgCards.id を参照

  // optional: カード個体の属性
  DateTimeColumn get updatedAt => dateTime().nullable()(); // カードの情報が更新された日
  TextColumn get description => text().nullable()(); // カードの説明や状態など


}
