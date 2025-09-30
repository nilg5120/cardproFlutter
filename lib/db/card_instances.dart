import 'package:drift/drift.dart';

class CardInstances extends Table {
  // ��L�[
  IntColumn get id => integer().autoIncrement()();
  // �Q��: MtgCards.id �ւ̃J�[�h�}�X�^
  IntColumn get cardId => integer()();
  // Scryfall �̌���R�[�h (��: en, ja)
  TextColumn get lang => text().nullable()();

  // �C�Ӎ���
  // �ŏI�X�V����
  DateTimeColumn get updatedAt => dateTime().nullable()();
  // ����/��ԂȂǂ̎��R�L�q
  TextColumn get description => text().nullable()();
}
