import 'package:drift/drift.dart';

class ContainerCardLocations extends Table {
  // 参照: Containers.id（配置先コンテナ）
  IntColumn get containerId => integer()();
  // 参照: CardInstances.id（カード個体）
  IntColumn get cardInstanceId => integer()();
  // 位置（'main' / 'side' など）
  TextColumn get location => text()();

  // 複合主キー: 同一インスタンスは同一コンテナの1つの場所にのみ所属
  @override
  Set<Column> get primaryKey => {containerId, cardInstanceId, location};
}

