import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zxzc9992/providers/cards_provider.dart';
import 'package:zxzc9992/providers/decks_provider.dart';
import 'package:zxzc9992/screens/add_card_screen.dart';
import 'package:zxzc9992/screens/add_deck_screen.dart';
import 'package:zxzc9992/flashcards/screens/flashcards_screen.dart';
import 'package:zxzc9992/widgets/deck/body.dart';

enum PopupMenuAction { edit, resetProgress, delete }

class DeckScreen extends StatefulWidget {
  static const routeName = '/deck-screen';

  @override
  _DeckScreenState createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  bool _isLoading = false;
  bool _isInit = true;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    if (_isInit) {
      setState(() => _isLoading = true);

      await _initCards();

      setState(() => _isLoading = false);
    }
    _isInit = false;
  }

  Future<void> _initCards() async {
    final deckId = ModalRoute.of(context)!.settings.arguments as String?;

    Provider.of<DecksProvider>(context, listen: false).getDeck(deckId!);
    await Provider.of<CardsProvider>(context, listen: false).getCards(deckId);
  }

  @override
  Widget build(BuildContext context) {
    final deckId = ModalRoute.of(context)!.settings.arguments as String?;
    final cardsProvider = Provider.of<CardsProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 28),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              onPressed: () async {
                await Navigator.of(context)
                    .pushNamed(FlashcardsScreen.routeName);

                cardsProvider.sortCards(true);
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_rounded, size: 28),
              onPressed: () {
                Navigator.of(context).pushNamed(AddCardScreen.routeName);
              },
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded, size: 28),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  child: Text('Edit deck'),
                  value: PopupMenuAction.edit,
                ),
                PopupMenuItem(
                  child: Text('Delete deck'),
                  value: PopupMenuAction.delete,
                ),
                PopupMenuItem(
                  child: Text('Reset progress'),
                  value: PopupMenuAction.resetProgress,
                ),
              ],
              onSelected: (PopupMenuAction action) async {
                if (action == PopupMenuAction.edit) {
                  Navigator.of(context).pushNamed(
                    AddDeckScreen.routeName,
                    arguments: deckId,
                  );
                  return;
                }

                if (action == PopupMenuAction.delete) {
                  final dialogResponse = await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Are you sure?'),
                      content: const Text('Do you want to remove this deck?'),
                      elevation: 0,
                      actions: <Widget>[
                        TextButton(
                          child: const Text('CANCEL'),
                          onPressed: () {
                            Navigator.of(ctx).pop(false);
                          },
                        ),
                        TextButton(
                          child: const Text('DELETE'),
                          onPressed: () async {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    ),
                  );

                  if (dialogResponse == true) {
                    setState(() => _isLoading = true);

                    await Provider.of<DecksProvider>(context, listen: false)
                        .deleteDeck(deckId!);

                    setState(() => _isLoading = false);

                    Navigator.of(context).pop();
                  }

                  return;
                }

                if (action == PopupMenuAction.resetProgress) {
                  final dialogResponse = await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Are you sure?'),
                      content: const Text(
                          'Do you want to reset progress of this deck?'),
                      elevation: 0,
                      actions: <Widget>[
                        TextButton(
                          child: const Text('NO'),
                          onPressed: () {
                            Navigator.of(ctx).pop(false);
                          },
                        ),
                        TextButton(
                          child: const Text('YES'),
                          onPressed: () async {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    ),
                  );

                  if (dialogResponse == true) {
                    setState(() => _isLoading = true);

                    await cardsProvider.resetProgress();

                    setState(() => _isLoading = false);
                  }
                  return;
                }
              },
            )
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await cardsProvider.syncCards();
                  setState(() {});
                },
                child: DeckBody(),
              ));
  }
}
