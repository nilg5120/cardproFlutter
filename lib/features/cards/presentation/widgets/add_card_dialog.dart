import 'package:cardpro/core/di/injection_container.dart';
import 'package:cardpro/db/database.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_bloc.dart';
import 'package:cardpro/features/cards/presentation/bloc/card_event.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cardpro/features/cards/data/datasources/scryfall_api.dart';
import 'package:cardpro/features/cards/data/models/scryfall_card.dart';

class AddCardDialog extends StatefulWidget {
  const AddCardDialog({super.key});

  @override
  State<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  // テキストコントローラー
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final rarityController = TextEditingController();
  final setNameController = TextEditingController();
  final cardNumberController = TextEditingController();
  final quantityController = TextEditingController(text: '1');

  // 選択中のカード効果ID
  int selectedEffectId = 1;

  late Future<List<CardEffect>> cardEffectsFuture;

  // Scryfall関連の設定
  final _scryfall = sl<ScryfallApi>();
  Timer? _debounce;
  List<String> _nameOptions = [];
  bool _isSuggestLoading = false;
  String? _suggestError;
  TextEditingController? _acController; // Autocompleteウィジェット内部のコントローラー
  String? _selectedOracleId; // 選択済みのScryfall oracle ID
  String? _selectedNameEn; // Scryfallから取得した英語名
  String? _selectedNameJa; // Scryfallから取得した日本語表記名

  @override
  void initState() {
    super.initState();
    final database = sl<AppDatabase>();
    cardEffectsFuture = database.getAllCardEffects();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    rarityController.dispose();
    setNameController.dispose();
    cardNumberController.dispose();
    quantityController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onNameChanged(String value) {
    // 名前が手動で変更された場合は選択済みoracle IDをリセット
    _selectedOracleId = null;
    _debounce?.cancel();
    final q = value.trim();
    if (q.length < 2) {
      setState(() {
        _nameOptions = [];
        _suggestError = null;
        _isSuggestLoading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      setState(() {
        _isSuggestLoading = true;
        _suggestError = null;
      });
      try {
        final list = await _scryfall.autocomplete(q);
        setState(() {
          _nameOptions = list;
          _isSuggestLoading = false;
        });
        // コントローラーを操作してAutocompleteに候補の再評価を促す
        final c = _acController;
        if (c != null && c.text.isNotEmpty) {
          final t = c.text;
          // 文字を変えずにリスナーを動かすため零幅スペースを一度追加してから削除する
          c.text = '$t\u200b';
          c.selection = TextSelection.collapsed(offset: c.text.length);
          Future.microtask(() {
            c.text = t;
            c.selection = TextSelection.collapsed(offset: t.length);
          });
        }
      } catch (e) {
        setState(() {
          _nameOptions = [];
          _suggestError = '候補の取得に失敗しました';
          _isSuggestLoading = false;
        });
      }
    });
  }

  Future<void> _fillDetailsFromScryfall(String exactName) async {
    try {
      final ScryfallCard? c = await _scryfall.getCardByExactName(exactName);
      if (c == null) return;
      setState(() {
        // 選択済みの名前は保持する
        rarityController.text = c.rarityShort ?? (c.rarity ?? '');
        setNameController.text = c.setName ?? '';
        final n = c.collectorNumberInt;
        cardNumberController.text = n != null ? '$n' : '';
        _selectedOracleId = c.oracleId;
        _selectedNameEn = c.name.isNotEmpty ? c.name : null;
        _selectedNameJa = (c.printedName != null && c.printedName!.isNotEmpty) ? c.printedName : null;
      });
    } catch (_) {
      // UI上では失敗を通知せずに無視する
    }
  }

  Future<void> _choosePrintingAndFill(String name) async {
    try {
      final prints = await _scryfall.listPrintings(name);
      if (prints.isEmpty) {
        // プリントがなければ単体取得にフォールバックする
        await _fillDetailsFromScryfall(name);
        return;
      }

      if (!mounted) return;
      final selected = await showDialog<ScryfallCard>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Select Printing'),
            content: SizedBox(
              width: 480,
              height: 360,
              child: ListView.builder(
                itemCount: prints.length,
                itemBuilder: (context, index) {
                  final p = prints[index];
                  final subtitleParts = <String>[];
                  if (p.setName != null) subtitleParts.add(p.setName!);
                  if (p.collectorNumber != null) subtitleParts.add('#${p.collectorNumber}');
                  if (p.lang != null && p.lang != 'en') subtitleParts.add(p.lang!.toUpperCase());
                  if (p.releasedAt != null) subtitleParts.add(p.releasedAt!);
                  return ListTile(
                    title: Text(p.printedName?.isNotEmpty == true ? p.printedName! : p.name),
                    subtitle: Text(subtitleParts.join(' • ')),
                    onTap: () => Navigator.of(context).pop(p),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (selected != null) {
        setState(() {
          rarityController.text = selected.rarityShort ?? (selected.rarity ?? '');
          setNameController.text = selected.setName ?? '';
          final n = selected.collectorNumberInt;
          cardNumberController.text = n != null ? '$n' : '';
          _selectedOracleId = selected.oracleId;
        });
      }
    } catch (_) {
      await _fillDetailsFromScryfall(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CardEffect>>(
      future: cardEffectsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AlertDialog(
            content: Center(child: CircularProgressIndicator()),
          );
        }

        final cardEffects = snapshot.data ?? [];
        if (cardEffects.isNotEmpty && !cardEffects.any((e) => e.id == selectedEffectId)) {
          selectedEffectId = cardEffects.first.id;
        }

        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Add Card'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue tev) {
                        final text = tev.text.trim();
                        if (text.length < 2) return const Iterable<String>.empty();
                        // ここでは現在のリストを返す（非同期で更新）
                        return _nameOptions.where((o) => o.toLowerCase().contains(text.toLowerCase()));
                      },
                      displayStringForOption: (s) => s,
                      onSelected: (value) async {
                        nameController.text = value;
                        await _choosePrintingAndFill(value);
                      },
                      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                        _acController = textController;
                        // nameController と同期
                        if (nameController.text != textController.text) {
                          textController.text = nameController.text;
                          textController.selection = nameController.selection;
                        }
                        nameController.addListener(() {
                          if (textController.text != nameController.text) {
                            textController.text = nameController.text;
                            textController.selection = nameController.selection;
                          }
                        });
                        textController.addListener(() {
                          if (nameController.text != textController.text) {
                            nameController.text = textController.text;
                            nameController.selection = textController.selection;
                          }
                        });
                        return TextField(
                          controller: textController,
                          focusNode: focusNode,
                          onChanged: _onNameChanged,
                          decoration: InputDecoration(
                            labelText: 'Name (Scryfall)',
                            border: const OutlineInputBorder(),
                            suffixIcon: _isSuggestLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : (_suggestError != null
                                    ? const Icon(Icons.error_outline, color: Colors.redAccent)
                                    : null),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 96, // ダイアログ内での想定幅
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final opt = options.elementAt(index);
                                  return ListTile(
                                    title: Text(opt),
                                    onTap: () => onSelected(opt),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: rarityController,
                      decoration: const InputDecoration(
                        labelText: 'Rarity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: setNameController,
                      decoration: const InputDecoration(
                        labelText: 'Set Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  TextField(
                    controller: cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                        hintText: '1',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Effect',
                        border: OutlineInputBorder(),
                      ),
                      // ignore: deprecated_member_use
                      value: selectedEffectId,
                      items: cardEffects
                          .map((effect) => DropdownMenuItem<int>(
                                value: effect.id,
                                child: Text('${effect.name} - ${effect.description}'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedEffectId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameController.text;
                    if (name.isNotEmpty) {
                      // oracleIdが存在するか確認し、無い場合は取得を試みる
                      if (_selectedOracleId == null || _selectedOracleId!.isEmpty) {
                        // 正確な名前で取得し、だめなら検索にフォールバックする
                        // UI応答性を保つためここではawaitせず非同期処理として実行する
                      }
                      () async {
                        String? oracleId = _selectedOracleId;
                        String? nameEn = _selectedNameEn;
                        String? nameJa = _selectedNameJa;
                        if (oracleId == null || oracleId.isEmpty) {
                          final c = await _scryfall.getCardByExactName(name);
                          if (c != null) {
                            oracleId = c.oracleId;
                            nameEn ??= c.name.isNotEmpty ? c.name : null;
                            nameJa ??= (c.printedName != null && c.printedName!.isNotEmpty) ? c.printedName : null;
                          }
                        }
                        if (!dialogContext.mounted) return;
                        if (oracleId == null || oracleId.isEmpty) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(content: Text('カードの識別子(oracle_id)を取得できません。候補から選択してください。')),
                            );
                          }
                          return;
                        }
                      final q = int.tryParse(quantityController.text.trim());
                      final qty = (q == null || q <= 0) ? 1 : q;
                      dialogContext.read<CardBloc>().add(
                        AddCardEvent(
                          name: name,
                          nameEn: nameEn,
                          nameJa: nameJa,
                          oracleId: oracleId,
                          rarity: rarityController.text.isNotEmpty ? rarityController.text : null,
                          setName: setNameController.text.isNotEmpty ? setNameController.text : null,
                          cardNumber: int.tryParse(cardNumberController.text),
                          effectId: selectedEffectId,
                          description: descriptionController.text.isNotEmpty
                              ? descriptionController.text
                              : null,
                          quantity: qty,
                        ),
                      );
                      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                      }();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
