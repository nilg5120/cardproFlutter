import 'package:equatable/equatable.dart';
import 'package:cardpro/features/cards/domain/entities/card.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';

/// カード関連イベント�E基底クラス
abstract class CardEvent extends Equatable {
  const CardEvent();
  @override
  List<Object?> get props => [];
}

/// カード一覧を取得するイベンチE
class GetCardsEvent extends CardEvent {}

/// 新しいカードを追加するイベンチE
class AddCardEvent extends CardEvent {
  final String name;
  final String? nameEn;
  final String? nameJa;
  final String oracleId;
  final String? rarity;
  final String? setName;
  final int? cardNumber;
  final String? lang;
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
    this.lang,
    required this.effectId,
    this.description,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [name, nameEn, nameJa, oracleId, rarity, setName, cardNumber, lang, effectId, description, quantity];
}

/// カード個体を削除するイベンチE
class DeleteCardEvent extends CardEvent {
  final CardInstance instance;

  const DeleteCardEvent(this.instance);

  @override
  List<Object> get props => [instance];
}

/// カード個体�E説明を更新するイベンチE
class EditCardEvent extends CardEvent {
  final CardInstance instance;
  final String description;
  final int? containerId;

  const EditCardEvent({
    required this.instance,
    required this.description,
    this.containerId,
  });

  @override
  List<Object?> get props => [instance, description, containerId];
}

/// カード�Eスター惁E��も含めて編雁E��るイベンチE
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

