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
  // Text controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final rarityController = TextEditingController();
  final setNameController = TextEditingController();
  final cardNumberController = TextEditingController();

  // Selected card effect id
  int selectedEffectId = 1;

  late Future<List<CardEffect>> cardEffectsFuture;

  // Scryfall
  final _scryfall = sl<ScryfallApi>();
  Timer? _debounce;
  List<String> _nameOptions = [];
  bool _isSuggestLoading = false;
  String? _suggestError;
  TextEditingController? _acController; // Autocomplete's internal controller

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
    _debounce?.cancel();
    super.dispose();
  }

  void _onNameChanged(String value) {
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
        // Force Autocomplete to re-evaluate options by nudging the controller
        final c = _acController;
        if (c != null && c.text.isNotEmpty) {
          final t = c.text;
          // Append zero-width space then remove to trigger listeners without visual change
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
        // Keep the selected name
        rarityController.text = c.rarityShort ?? (c.rarity ?? '');
        setNameController.text = c.setName ?? '';
        final n = c.collectorNumberInt;
        cardNumberController.text = n != null ? '$n' : '';
      });
    } catch (_) {
      // ignore failures silently in UI
    }
  }

  Future<void> _choosePrintingAndFill(String name) async {
    try {
      final prints = await _scryfall.listPrintings(name);
      if (prints.isEmpty) {
        // fallback to single fetch
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
          builder: (context, setState) {
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
                              width: MediaQuery.of(context).size.width - 96, // approximate within dialog
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameController.text;
                    if (name.isNotEmpty) {
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
                      Navigator.of(context).pop();
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
