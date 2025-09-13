import 'package:equatable/equatable.dart';
import 'package:cardpro/features/cards/domain/entities/card.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';

/// カード関連イベントの基底クラス
abstract class CardEvent extends Equatable {
  const CardEvent();
  @override
  List<Object?> get props => [];
}

/// カード一覧を取得するイベント
class GetCardsEvent extends CardEvent {}

/// 新しいカードを追加するイベント
class AddCardEvent extends CardEvent {
  final String name;
  final String? nameEn;
  final String? nameJa;
  final String oracleId;
  final String? rarity;
  final String? setName;
  final int? cardNumber;
  final int effectId;
  final String? description;
  final int quantity;

  const AddCardEvent({
    required this.name,
    this.nameEn,
    this.nameJa,
    required this.oracleId,
    this.rarity,
    this.setName,
    this.cardNumber,
    required this.effectId,
    this.description,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [name, nameEn, nameJa, oracleId, rarity, setName, cardNumber, effectId, description, quantity];
}

/// カード個体を削除するイベント
class DeleteCardEvent extends CardEvent {
  final CardInstance instance;

  const DeleteCardEvent(this.instance);

  @override
  List<Object> get props => [instance];
}

/// カード個体の説明を更新するイベント
class EditCardEvent extends CardEvent {
  final CardInstance instance;
  final String description;

  const EditCardEvent({
    required this.instance,
    required this.description,
  });

  @override
  List<Object> get props => [instance, description];
}

/// カードマスター情報も含めて編集するイベント
class EditCardFullEvent extends CardEvent {
  final Card card;
  final CardInstance instance;
  final String? rarity;
  final String? setName;
  final int? cardNumber;
  final String? description;

  const EditCardFullEvent({
    required this.card,
    required this.instance,
    required this.rarity,
    required this.setName,
    required this.cardNumber,
    required this.description,
  });

  @override
  List<Object?> get props => [card, instance, rarity, setName, cardNumber, description];
}
