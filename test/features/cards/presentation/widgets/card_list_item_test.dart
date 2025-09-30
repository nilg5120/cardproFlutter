import 'package:cardpro/features/cards/data/models/card_instance_model.dart';
import 'package:cardpro/features/cards/data/models/card_model.dart';
import 'package:cardpro/features/cards/data/models/card_with_instance_model.dart';
import 'package:cardpro/features/cards/domain/entities/card_instance_location.dart';
import 'package:cardpro/features/cards/presentation/widgets/card_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('displays placement summary when placements exist', (tester) async {
    final card = CardModel(
      id: 1,
      name: 'Sample Card',
      effectId: 1,
      setName: 'Set A',
    );
    final instance = CardInstanceModel(
      id: 1,
      cardId: 1,
      updatedAt: DateTime(2024, 1, 1),
      description: 'Instance description',
    );
    final placements = const [
      CardInstanceLocation(
        containerId: 10,
        containerName: 'Deck Alpha',
        containerType: 'deck',
        location: 'main',
      ),
      CardInstanceLocation(
        containerId: 20,
        containerName: 'Binder Beta',
        containerType: 'binder',
        location: 'side',
      ),
    ];
    final cardWithInstance = CardWithInstanceModel(
      card: card,
      instance: instance,
      placements: placements,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CardListItem(
            card: cardWithInstance,
            onDelete: () {},
            onEdit: (_, {containerId, rarity, setName, cardNumber}) {},
          ),
        ),
      ),
    );

    expect(find.text('main, side'), findsOneWidget);
  });

  testWidgets('falls back to 未割り当て when there is no placement', (tester) async {
    final card = CardModel(
      id: 2,
      name: 'Another Card',
      effectId: 1,
    );
    final instance = CardInstanceModel(
      id: 2,
      cardId: 2,
      updatedAt: DateTime(2024, 2, 2),
    );
    final cardWithInstance = CardWithInstanceModel(
      card: card,
      instance: instance,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CardListItem(
            card: cardWithInstance,
            onDelete: () {},
            onEdit: (_, {containerId, rarity, setName, cardNumber}) {},
          ),
        ),
      ),
    );

    expect(find.text('未割り当て'), findsOneWidget);
  });
}
  testWidgets('shows language label when available', (tester) async {
    final card = CardModel(
      id: 3,
      name: 'Language Card',
      effectId: 1,
    );
    final instance = CardInstanceModel(
      id: 3,
      cardId: 3,
      lang: 'ja',
      updatedAt: DateTime(2024, 3, 3),
    );
    final cardWithInstance = CardWithInstanceModel(
      card: card,
      instance: instance,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CardListItem(
            card: cardWithInstance,
            onDelete: () {},
            onEdit: (_, {containerId, rarity, setName, cardNumber}) {},
          ),
        ),
      ),
    );

    expect(find.text('Language: Japanese (JA)'), findsOneWidget);
  });
