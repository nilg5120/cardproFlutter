import 'package:equatable/equatable.dart';

class Container extends Equatable {
  final int id;
  final String? name;
  final String? description;
  final String containerType;

  const Container({
    required this.id,
    this.name,
    this.description,
    required this.containerType,
  });

  @override
  List<Object?> get props => [id, name, description, containerType];
}
