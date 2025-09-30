import 'package:equatable/equatable.dart';

class CardInstance extends Equatable {
  final int id;
  final int cardId;
  final String? lang;
  final DateTime? updatedAt;
  final String? description;

  const CardInstance({
    required this.id,
    required this.cardId,
    this.lang,
    this.updatedAt,
    this.description,
  });

  @override
  List<Object?> get props => [id, cardId, lang, updatedAt, description];
}
