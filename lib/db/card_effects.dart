import 'package:drift/drift.dart';

class CardEffects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // 効果の名称（例：エネルギー加速）
  TextColumn get description => text()(); // 効果の詳細な説明
}
