import 'package:cardpro/features/cards/data/models/card_model.dart';
import 'package:cardpro/features/cards/data/models/card_instance_model.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';

class CardWithInstanceModel extends CardWithInstance {
  const CardWithInstanceModel({
    required CardModel card,
    required CardInstanceModel instance,
  }) : super(card: card, instance: instance);

  factory CardWithInstanceModel.fromDrift(dynamic driftCard, dynamic driftInstance) {
    return CardWithInstanceModel(
      card: CardModel.fromDrift(driftCard),
      instance: CardInstanceModel.fromDrift(driftInstance),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card': (card as CardModel).toJson(),
      'instance': (instance as CardInstanceModel).toJson(),
    };
  }

  factory CardWithInstanceModel.fromJson(Map<String, dynamic> json) {
    return CardWithInstanceModel(
      card: CardModel.fromJson(json['card']),
      instance: CardInstanceModel.fromJson(json['instance']),
    );
  }
}
