import 'package:cardpro/db/database.dart';
import 'package:cardpro/features/decks/data/models/container_model.dart';
import 'package:drift/drift.dart';

abstract class ContainerLocalDataSource {
  /// デッキ以外のコンテナ一覧を取得
  Future<List<ContainerModel>> getContainers();

  /// コンテナを追加
  Future<ContainerModel> addContainer({
    required String name,
    required String? description,
    required String containerType,
  });

  /// コンテナを削除
  Future<void> deleteContainer({
    required int id,
  });

  /// コンテナ情報を更新
  Future<ContainerModel> editContainer({
    required int id,
    required String name,
    required String? description,
    required String containerType,
  });
}

class ContainerLocalDataSourceImpl implements ContainerLocalDataSource {
  final AppDatabase database;

  ContainerLocalDataSourceImpl({required this.database});

  @override
  Future<List<ContainerModel>> getContainers() async {
    final rows = await (database.select(database.containers)
          ..where((tbl) => tbl.containerType.isNotValue('deck')))
        .get();
    return rows.map(ContainerModel.fromDrift).toList();
  }

  @override
  Future<ContainerModel> addContainer({
    required String name,
    required String? description,
    required String containerType,
  }) async {
    final inserted = await database.into(database.containers).insertReturning(
          ContainersCompanion.insert(
            name: Value(name),
            description: Value(description),
            containerType: containerType,
          ),
        );
    return ContainerModel.fromDrift(inserted);
  }

  @override
  Future<void> deleteContainer({required int id}) async {
    await (database.delete(database.containers)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<ContainerModel> editContainer({
    required int id,
    required String name,
    required String? description,
    required String containerType,
  }) async {
    await (database.update(database.containers)..where((t) => t.id.equals(id))).write(
      ContainersCompanion(
        name: Value(name),
        description: Value(description),
        containerType: Value(containerType),
      ),
    );
    final updated = await (database.select(database.containers)..where((t) => t.id.equals(id))).getSingle();
    return ContainerModel.fromDrift(updated);
  }
}
