import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zxzc9992/flashcards/widgets/flashcards_main.dart';
import 'package:zxzc9992/providers/cards_provider.dart';
import 'package:zxzc9992/providers/flashcards_provider.dart';
import 'package:zxzc9992/flashcards/widgets/flashcards_appbar.dart';
import 'package:zxzc9992/flashcards/widgets/flashcards_button.dart';

class FlashcardsScreen extends StatefulWidget {
  static const routeName = '/flashcards';

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    final cardsProvider = Provider.of<CardsProvider>(context, listen: false);
    final flashcardsProvider =
        Provider.of<FlashcardsProvider>(context, listen: false);

    final deckId = cardsProvider.currentDeckId;

    final flashcardsOptions = _initOptions(deckId);

    final cards = cardsProvider.prepareCards(flashcardsOptions);
    flashcardsProvider.initFlashcards(cards);
  }

  dynamic _initOptions(String deckId) {
    final box = Hive.box('flashcards_options');

    dynamic data;

    data = box.get(deckId);
    if (data != null) {
      return data;
    }

    data = box.get('default');
    if (data != null) {
      return data;
    }
  }

  //Future<void> _saveLastReviewedTime() async {}

  @override
  Widget build(BuildContext context) {
    final cardsProvider = Provider.of<CardsProvider>(context, listen: false);
    final flashcards = Provider.of<FlashcardsProvider>(context, listen: false);

    return Scaffold(
      body: Column(
        children: [
          FlashcardsAppBar(
            onOptionsChanged: (int cardsPerGame, bool isFrontFirst) {
              setState(() {
                flashcards.cardsPerGame = cardsPerGame;
                flashcards.isFrontFirst = isFrontFirst;
              });
              final options = {'cards_per_game': cardsPerGame};
              final cards = cardsProvider.prepareCards(options);
              flashcards.initFlashcards(cards);
            },
          ),
          FlashcardsMain(isVisible: isVisible),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 69),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FlashcardsButton(
                    isVisible: !isVisible && true,
                    title: 'n',
                    icon: const Icon(Icons.clear_rounded, size: 30),
                    onTap: () {
                      setState(() => isVisible = true);
                      flashcards.rand(false);
                    },
                  ),
                  FlashcardsButton(
                    isVisible: isVisible && true,
                    title: '?',
                    onTap: () {
                      setState(() => isVisible = false);
                    },
                  ),
                  FlashcardsButton(
                    isVisible: !isVisible && true,
                    title: 'y',
                    icon: const Icon(Icons.done_rounded, size: 30),
                    onTap: () {

                      flashcards.rand(true);
                      setState(() => isVisible = true);
                      if (flashcards.counter() == 0) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
