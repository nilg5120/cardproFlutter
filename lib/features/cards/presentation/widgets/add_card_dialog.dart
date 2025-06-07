// カード追加用のダイアログを表示するウィジェット
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_event.dart';
import 'package:cardpro/db/database.dart';
import 'package:cardpro/core/di/injection_container.dart';

/// StatefulWidget を使ってユーザー入力と選択状態を保持
class AddCardDialog extends StatefulWidget {
  const AddCardDialog({super.key});

  @override
  State<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  // テキスト入力用のコントローラ
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final rarityController = TextEditingController();
  final setNameController = TextEditingController();
  final cardNumberController = TextEditingController();

  // 選択されたカード効果のID
  int selectedEffectId = 1;

  // カード効果のリストを取得する Future
  late Future<List<CardEffect>> cardEffectsFuture;

  @override
  void initState() {
    super.initState();
    // 依存性注入を使ってデータベースから効果を取得
    final database = sl<AppDatabase>();
    cardEffectsFuture = database.getAllCardEffects();
  }

  @override
  void dispose() {
    // 不要になったコントローラを破棄してメモリリークを防ぐ
    nameController.dispose();
    descriptionController.dispose();
    rarityController.dispose();
    setNameController.dispose();
    cardNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 非同期でカード効果一覧を読み込む
    return FutureBuilder<List<CardEffect>>(
      future: cardEffectsFuture,
      builder: (context, snapshot) {
        // ローディング中はインジケーターを表示
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AlertDialog(
            content: Center(child: CircularProgressIndicator()),
          );
        }

        // データ取得後に効果リストを格納
        final cardEffects = snapshot.data ?? [];

        // 初期選択値が不正なら先頭のIDにする
        if (cardEffects.isNotEmpty && !cardEffects.any((e) => e.id == selectedEffectId)) {
          selectedEffectId = cardEffects.first.id;
        }

        // StatefulBuilder で setState を使って選択状態を更新可能にする
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('カードを追加'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 各種入力フィールド
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'カード名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: rarityController,
                      decoration: const InputDecoration(
                        labelText: 'レアリティ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: setNameController,
                      decoration: const InputDecoration(
                        labelText: '拡張パック名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'カード番号',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    // ドロップダウンでカード効果を選択
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'カード効果',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedEffectId,
                      items: cardEffects.map((effect) {
                        return DropdownMenuItem<int>(
                          value: effect.id,
                          child: Text('${effect.name} - ${effect.description}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedEffectId = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: '説明',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              // アクションボタン
              actions: [
                // キャンセルボタン
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),

                // 追加ボタン（バリデーション後にBLoCへイベント送信）
                TextButton(
                  onPressed: () {
                    final name = nameController.text;
                    if (name.isNotEmpty) {
                      // カード追加イベントをBLoCに送信
                      context.read<CardBloc>().add(
                            AddCardEvent(
                              name: name,
                              rarity: rarityController.text.isNotEmpty ? rarityController.text : null,
                              setName: setNameController.text.isNotEmpty ? setNameController.text : null,
                              cardNumber: int.tryParse(cardNumberController.text),
                              effectId: selectedEffectId,
                              description: descriptionController.text.isNotEmpty
                                  ? descriptionController.text
                                  : null,
                            ),
                          );
                      // ダイアログを閉じる
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('追加'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
