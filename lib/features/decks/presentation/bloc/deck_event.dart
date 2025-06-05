import 'package:equatable/equatable.dart';

/// デッキに関するイベントの抽象クラス
abstract class DeckEvent extends Equatable {
  const DeckEvent();

  @override
  List<Object?> get props => [];
}

/// デッキ一覧を取得するイベント
class GetDecksEvent extends DeckEvent {}

/// デッキを追加するイベント
class AddDeckEvent extends DeckEvent {
  final String name; // デッキ名
  final String? description; // 説明（任意）

  const AddDeckEvent({
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [name, description];
}

/// デッキを削除するイベント
class DeleteDeckEvent extends DeckEvent {
  final int id; // 削除対象のデッキID

  const DeleteDeckEvent({required this.id});

  @override
  List<Object> get props => [id];
}

/// デッキを編集するイベント
class EditDeckEvent extends DeckEvent {
  final int id; // 編集対象のデッキID
  final String name; // 新しいデッキ名
  final String? description; // 新しい説明（任意）

  const EditDeckEvent({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}
