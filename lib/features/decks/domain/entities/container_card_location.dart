import 'package:equatable/equatable.dart';

class ContainerCardLocation extends Equatable {
  final int containerId;
  final String cardInstanceId;
  final String location;

  const ContainerCardLocation({
    required this.containerId,
    required this.cardInstanceId,
    required this.location,
  });

  @override
  List<Object> get props => [containerId, cardInstanceId, location];
}
