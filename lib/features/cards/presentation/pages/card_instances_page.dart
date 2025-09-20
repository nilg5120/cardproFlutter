import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_event.dart';
import 'package:cardpro/features/cards/presentation/widgets/card_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//カード個体一覧画面
class CardInstancesPage extends StatelessWidget {
  final String title;
  final List<CardWithInstance> instances;

  const CardInstancesPage({super.key, required this.title, required this.instances});

  @override
  Widget build(BuildContext context) {
    //「セット名ごとに個体をグルーピング（null は『不明なセット』扱い）
    final Map<String, List<CardWithInstance>> bySet = {};
    for (final it in instances) {
      final key = it.card.setName?.trim().isNotEmpty == true
          ? it.card.setName!.trim()
          : 'Unknown Set';
      bySet.putIfAbsent(key, () => []).add(it);
    }
    final setNames = bySet.keys.toList()..sort((a, b) => a.compareTo(b));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: setNames.length,
        itemBuilder: (context, sectionIndex) {
          final setName = setNames[sectionIndex];
          final group = bySet[setName]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  setName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final item in group)
                CardListItem(
                  card: item,
                  // 「グループ表示ではカード名とセット名を非表示にする」
                  showCardName: false,
                  showSetName: false,
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
                ),
            ],
          );
        },
      ),
    );
  }
}
