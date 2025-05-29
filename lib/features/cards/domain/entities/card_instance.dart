import 'package:equatable/equatable.dart';

class CardInstance extends Equatable {
  final int id;
  final int cardId;
  final DateTime? updatedAt;
  final String? description;

  const CardInstance({
    required this.id,
    required this.cardId,
    this.updatedAt,
    this.description,
  });

  @override
  List<Object?> get props => [id, cardId, updatedAt, description];
}
