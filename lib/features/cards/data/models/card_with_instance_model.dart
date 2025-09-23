import 'package:cardpro/features/cards/data/models/card_model.dart';
import 'package:cardpro/features/cards/data/models/card_instance_model.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance_location.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';

class CardWithInstanceModel extends CardWithInstance {
  CardWithInstanceModel({
    required CardModel card,
    required CardInstanceModel instance,
    List<CardInstanceLocation> placements = const [],
  }) : super(
          card: card,
          instance: instance,
          placements: List<CardInstanceLocation>.unmodifiable(placements),
        );

  factory CardWithInstanceModel.fromDrift(
    dynamic driftCard,
    dynamic driftInstance, {
    List<CardInstanceLocation> placements = const [],
  }) {
    return CardWithInstanceModel(
      card: CardModel.fromDrift(driftCard),
      instance: CardInstanceModel.fromDrift(driftInstance),
      placements: placements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card': (card as CardModel).toJson(),
      'instance': (instance as CardInstanceModel).toJson(),
      'placements': placements
          .map((placement) => {
                'containerId': placement.containerId,
                'containerName': placement.containerName,
                'containerDescription': placement.containerDescription,
                'containerType': placement.containerType,
                'isActive': placement.isActive,
                'location': placement.location,
              })
          .toList(),
    };
  }

  factory CardWithInstanceModel.fromJson(Map<String, dynamic> json) {
    return CardWithInstanceModel(
      card: CardModel.fromJson(json['card']),
      instance: CardInstanceModel.fromJson(json['instance']),
      placements: (json['placements'] as List<dynamic>? ?? [])
          .map(
            (entry) => CardInstanceLocation(
              containerId: entry['containerId'] as int,
              containerName: entry['containerName'] as String?,
              containerDescription: entry['containerDescription'] as String?,
              containerType: entry['containerType'] as String?,
              isActive: entry['isActive'] as bool?,
              location: entry['location'] as String,
            ),
          )
          .toList(),
    );
  }
}
