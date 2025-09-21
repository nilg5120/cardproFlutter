import 'package:cardpro/core/di/injection_container.dart';
import 'package:cardpro/features/cards/domain/entities/card_with_instance.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_event.dart';
import 'package:cardpro/features/cards/presentation/widgets/add_card_dialog.dart';
import 'package:cardpro/features/cards/presentation/widgets/card_list_item.dart';
import 'package:cardpro/features/cards/presentation/pages/card_instances_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardListPage extends StatelessWidget {
  const CardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 上位ツリーに既存の BlocProvider があればそれを利用する
    try {
      BlocProvider.of<CardBloc>(context, listen: false);
      return _buildScaffold(context);
    } catch (_) {
      // なければローカルに BlocProvider を作成する
      return BlocProvider(
        create: (_) => sl<CardBloc>()..add(GetCardsEvent()),
        child: _buildScaffold(context),
      );
    }
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards'),
      ),
      body: BlocBuilder<CardBloc, CardState>(
        builder: (context, state) {
          if (state is CardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CardLoaded) {
            return _buildCardList(context, state.cards);
          } else if (state is CardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CardBloc>().add(GetCardsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is CardInitial) {
            // 初回フレーム描画後に読み込みをトリガーする
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<CardBloc>().add(GetCardsEvent());
            });
            return const Center(child: CircularProgressIndicator());
          }

          return const Center(child: Text('カードを読み込んでください'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'cards_fab',
        onPressed: () => _showAddCardDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCardList(BuildContext context, List<CardWithInstance> items) {
    if (items.isEmpty) {
      return const Center(child: Text('カードがありません'));
    }

    // oracleId ごとにグルーピング（NULL/空は個別IDで分離）
    final Map<String, List<CardWithInstance>> byOracle = {};
    for (final e in items) {
      final key = (e.card.oracleId != null && e.card.oracleId!.isNotEmpty)
          ? e.card.oracleId!
          : 'no-oracle:${e.card.id}';
      byOracle.putIfAbsent(key, () => []).add(e);
    }
    final grouped = byOracle.values.toList();

    return ListView.builder(
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final group = grouped[index];
        final representative = group.first; // 表示には先頭のインスタンスを代表として使う
        // タイトルは代表カードの名前
        final titleWidget = _LocalizedCardTitle(
          fallback: representative.card.name,
          nameEn: representative.card.nameEn,
          nameJa: representative.card.nameJa,
        );

        final displayTitle = _LocalizedCardTitle.computeDisplay(
          fallback: representative.card.name,
          nameEn: representative.card.nameEn,
          nameJa: representative.card.nameJa,
        );

        return CardListItem(
          card: representative,
          title: titleWidget,
          count: group.length,
          // タップでインスタンス一覧へ遷移
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<CardBloc>(),
                  child: CardInstancesPage(
                    title: displayTitle,
                    instances: group,
                  ),
                ),
              ),
            );
          },
          // グループ表示では削除ボタンを隠す
          showDelete: false,
          // セット名は一覧では非表示（セットが混在するため）
          showSetName: false,
          // コンストラクタ要件を満たすためのハンドラーで、表示も使用もされない
          onDelete: () {},
          onEdit: (_, {String? rarity, String? setName, int? cardNumber}) {},
        );
      },
    );
  }

  void _showAddCardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CardBloc>(),
        child: const AddCardDialog(),
      ),
    );
  }
}

class _LocalizedCardTitle extends StatelessWidget {
  final String fallback;
  final String? nameEn;
  final String? nameJa;

  const _LocalizedCardTitle({
    required this.fallback,
    this.nameEn,
    this.nameJa,
  });

  static String computeDisplay({
    required String fallback,
    String? nameEn,
    String? nameJa,
  }) {
    // 利用可能であれば DB に保存された名称を優先し、ここではネットワーク取得は行わない。
    final en = nameEn?.trim();
    final ja = nameJa?.trim();
    String display = fallback;
    if ((ja != null && ja.isNotEmpty) || (en != null && en.isNotEmpty)) {
      if (ja != null && ja.isNotEmpty) {
        if (en != null && en.isNotEmpty && ja != en) {
          display = '$ja/$en';
        } else {
          display = ja;
        }
      } else {
        display = en!;
      }
    }
    return display;
  }

  @override
  Widget build(BuildContext context) {
    final display = computeDisplay(
      fallback: fallback,
      nameEn: nameEn,
      nameJa: nameJa,
    );
    return Text(
      display,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
