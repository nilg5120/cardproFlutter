import 'package:equatable/equatable.dart';

class Container extends Equatable {
  final int id;
  final String? name;
  final String? description;
  final String containerType;
  final bool isActive;

  const Container({
    required this.id,
    this.name,
    this.description,
    required this.containerType,
    this.isActive = false,
  });

  @override
  List<Object?> get props => [id, name, description, containerType, isActive];
}
