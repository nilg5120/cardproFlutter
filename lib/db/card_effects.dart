import 'package:drift/drift.dart';

class CardEffects extends Table {
  // 主キー
  IntColumn get id => integer().autoIncrement()();
  // 効果名（例: マナ加速）
  TextColumn get name => text()();
  // 効果の説明
  TextColumn get description => text()();
}

