import 'package:equatable/equatable.dart';
import 'package:cardpro/features/cards/domain/entities/card.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance.dart';

class CardWithInstance extends Equatable {
  final Card card;
  final CardInstance instance;

  const CardWithInstance({
    required this.card,
    required this.instance,
  });

  @override
  List<Object> get props => [card, instance];
}
