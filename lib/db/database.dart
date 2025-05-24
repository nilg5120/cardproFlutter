import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'users.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Users])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> addUser(String name, int age) {
    return into(users).insert(UsersCompanion(
      name: Value(name),
      age: Value(age),
    ));
  }

  Future<List<User>> getAllUsers() {
    return select(users).get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'app.db'));
    return SqfliteQueryExecutor(path: dbFile.path, logStatements: true);
  });
}
