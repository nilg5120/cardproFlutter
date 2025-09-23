import 'package:equatable/equatable.dart';
import 'package:cardpro/features/cards/domain/entities/card.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance_location.dart';

class CardWithInstance extends Equatable {
  final Card card;
  final CardInstance instance;
  final List<CardInstanceLocation> placements;

  const CardWithInstance({
    required this.card,
    required this.instance,
    this.placements = const [],
  });

  @override
  List<Object> get props => [card, instance, placements];
}
