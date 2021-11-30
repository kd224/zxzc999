import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zxzc9992/providers/decks_provider.dart';
import 'package:zxzc9992/settings/models/flashcards_options.dart';
import 'package:zxzc9992/settings/widgets/cards_per_game_dialog.dart';

class FlashcardsOptionsScreen extends StatefulWidget {
  @override
  State<FlashcardsOptionsScreen> createState() =>
      _FlashcardsOptionsScreenState();
}

class _FlashcardsOptionsScreenState extends State<FlashcardsOptionsScreen> {
  late String deckId;

  bool _isDataChanged = false;

  bool frontToBack = true;
  int cardsPerGame = 25;

  final box = Hive.box('flashcards_options');

  @override
  void initState() {
    super.initState();
    final decksProvider = Provider.of<DecksProvider>(context, listen: false);
    deckId = decksProvider.currentDeck.id;

    _loadOptions();
  }

  void _loadOptions() {
    final deckData = box.get(deckId);

    if (deckData != null) {
      frontToBack = deckData['cards_orientation'] as bool;
      cardsPerGame = deckData['cards_per_game'] as int;
      return;
    }

    final defaultData = box.get('default');

    if (defaultData != null) {
      frontToBack = defaultData['cards_orientation'] as bool;
      cardsPerGame = defaultData['cards_per_game'] as int;
      return;
    }
  }

  void _persistOptions(bool cardsOrientation, int cardsPerGame) {
    box.put(deckId, {
      'cards_orientation': cardsOrientation,
      'cards_per_game': cardsPerGame,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Cards orientation'),
            trailing: Text(frontToBack ? 'front to back' : 'back to front'),
            onTap: () async {
              setState(() => frontToBack = !frontToBack);

              _isDataChanged = true;

              _persistOptions(frontToBack, cardsPerGame);
            },
          ),
          ListTile(
            title: const Text('Max. cards per game'),
            trailing: Text(cardsPerGame.toString()),
            onTap: () async {
              final data = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CardsPerGameDialog(cardsPerGame);
                  });

              if (data == null) return;

              _persistOptions(frontToBack, data as int);

              _isDataChanged = true;

              setState(() => cardsPerGame = data);
            },
          ),
          TextButton(
            child: const Text('Restart flashcards'),
            onPressed: () {
              final options = FlashcardsOptions(
                cardsPerGame: cardsPerGame,
                isFrontFirst: frontToBack,
              );
              
              Navigator.of(context).pop(_isDataChanged ? options : null);
            },
          )
        ],
      ),
    );
  }
}
