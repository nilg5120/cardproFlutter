import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_event.dart';
import 'package:cardpro/features/cards/presentation/widgets/card_list_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Card instance list screen
class CardInstancesPage extends StatefulWidget {
  final String title;
  final List<CardWithInstance> instances;

  const CardInstancesPage({super.key, required this.title, required this.instances});

  @override
  State<CardInstancesPage> createState() => _CardInstancesPageState();
}

class _CardInstancesPageState extends State<CardInstancesPage> {
  late List<CardWithInstance> _instances;

  @override
  void initState() {
    super.initState();
    _instances = List<CardWithInstance>.from(widget.instances);
  }

  @override
  void didUpdateWidget(CardInstancesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.instances, widget.instances)) {
      _instances = List<CardWithInstance>.from(widget.instances);
    }
  }

  @override
  Widget build(BuildContext context) {
    final widgetBody = _instances.isEmpty
        ? const Center(child: Text('カードインスタンスはまだありません'))
        : _buildGroupedList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: widgetBody,
    );
  }

  Widget _buildGroupedList() {
    final Map<String, List<CardWithInstance>> bySet = {};
    for (final it in _instances) {
      final key = it.card.setName?.trim().isNotEmpty == true
          ? it.card.setName!.trim()
          : 'Unknown Set';
      bySet.putIfAbsent(key, () => []).add(it);
    }
    final setNames = bySet.keys.toList()..sort((a, b) => a.compareTo(b));

    return ListView.builder(
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
                // Hide card/set names in grouped view
                showCardName: false,
                showSetName: false,
                onDelete: () => _handleDelete(item),
                onEdit: (description, {String? rarity, String? setName, int? cardNumber}) {
                  context.read<CardBloc>().add(
                        EditCardEvent(
                          instance: item.instance,
                          description: description,
                        ),
                      );
                },
              ),
          ],
        );
      },
    );
  }

  void _handleDelete(CardWithInstance item) {
    context.read<CardBloc>().add(DeleteCardEvent(item.instance));
    setState(() {
      _instances.removeWhere((element) => element.instance.id == item.instance.id);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('削除が完了しました'),
          content: const Text('カードを削除しました。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}
