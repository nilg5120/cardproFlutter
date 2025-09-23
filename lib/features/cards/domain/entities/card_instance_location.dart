import 'package:equatable/equatable.dart';

class CardInstanceLocation extends Equatable {
  final int containerId;
  final String? containerName;
  final String? containerDescription;
  final String? containerType;
  final bool? isActive;
  final String location;

  const CardInstanceLocation({
    required this.containerId,
    required this.location,
    this.containerName,
    this.containerDescription,
    this.containerType,
    this.isActive,
  });

  @override
  List<Object?> get props => [
        containerId,
        containerName,
        containerDescription,
        containerType,
        isActive,
        location,
      ];
}
