import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_event.dart';
import 'package:cardpro/features/cards/presentation/widgets/card_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardInstancesPage extends StatelessWidget {
  final String title;
  final List<CardWithInstance> instances;

  const CardInstancesPage({super.key, required this.title, required this.instances});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: instances.length,
        itemBuilder: (context, index) {
          final item = instances[index];
          return CardListItem(
            card: item,
            onDelete: () {
              context.read<CardBloc>().add(DeleteCardEvent(item.instance));
            },
            onEdit: (description, {String? rarity, String? setName, int? cardNumber}) {
              if (rarity != null || setName != null || cardNumber != null) {
                context.read<CardBloc>().add(
                      EditCardFullEvent(
                        card: item.card,
                        instance: item.instance,
                        rarity: rarity ?? item.card.rarity,
                        setName: setName ?? item.card.setName,
                        cardNumber: cardNumber ?? item.card.cardNumber,
                        description: description,
                      ),
                    );
              } else {
                context.read<CardBloc>().add(
                      EditCardEvent(
                        instance: item.instance,
                        description: description,
                      ),
                    );
              }
            },
          );
        },
      ),
    );
  }
}
