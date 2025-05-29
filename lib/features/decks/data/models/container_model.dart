import 'package:cardpro/features/decks/domain/entities/container.dart';

class ContainerModel extends Container {
  const ContainerModel({
    required super.id,
    super.name,
    super.description,
    required super.containerType,
  });

  factory ContainerModel.fromDrift(dynamic driftContainer) {
    return ContainerModel(
      id: driftContainer.id,
      name: driftContainer.name,
      description: driftContainer.description,
      containerType: driftContainer.containerType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'containerType': containerType,
    };
  }

  factory ContainerModel.fromJson(Map<String, dynamic> json) {
    return ContainerModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      containerType: json['containerType'],
    );
  }
}
