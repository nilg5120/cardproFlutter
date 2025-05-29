import 'package:cardpro/features/decks/domain/entities/container_card_location.dart';

class ContainerCardLocationModel extends ContainerCardLocation {
  const ContainerCardLocationModel({
    required super.containerId,
    required super.cardInstanceId,
    required super.location,
  });

  factory ContainerCardLocationModel.fromDrift(dynamic driftLocation) {
    return ContainerCardLocationModel(
      containerId: driftLocation.containerId,
      cardInstanceId: driftLocation.cardInstanceId,
      location: driftLocation.location,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'containerId': containerId,
      'cardInstanceId': cardInstanceId,
      'location': location,
    };
  }

  factory ContainerCardLocationModel.fromJson(Map<String, dynamic> json) {
    return ContainerCardLocationModel(
      containerId: json['containerId'],
      cardInstanceId: json['cardInstanceId'],
      location: json['location'],
    );
  }
}
