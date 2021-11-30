import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zxzc9992/flashcards/screens/flashcards_screen.dart';
import 'package:zxzc9992/providers/cards_provider.dart';
import 'package:zxzc9992/providers/decks_provider.dart';
import 'package:zxzc9992/services/crud_helper.dart';
import 'package:zxzc9992/widgets/deck/cards_list.dart';
import 'package:zxzc9992/widgets/deck/header.dart';
import 'package:zxzc9992/widgets/deck/study_button.dart';

class DeckBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final decksProvider = Provider.of<DecksProvider>(context);
    final cardsProvider = Provider.of<CardsProvider>(context);

    final currentDeck = decksProvider.currentDeck;
    final currentCards = cardsProvider.currentCards;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            DeckHeader(
              title: currentDeck.title,
              cardsAmount: currentCards.length,
              areCardsEmpty: currentCards.isEmpty,
            ),
            CardsList(),
            SliverToBoxAdapter(
              child: Container(height: 69),
            ),
          ],
        ),
        StudyButton(
          onPress: () async {
            if (cardsProvider.currentCards.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("You can't play without cards"),
              ));
              return;
            }

            final now = DateTime.now().millisecondsSinceEpoch;

            //currentDeck.lastPlayed = now;
            CrudHelper().updateLocalDeck(currentDeck.id, {'lastPlayed': now});

            await Navigator.of(context).pushNamed(
              FlashcardsScreen.routeName,
            );

            cardsProvider.sortCards(true);
          },
        ),
      ],
    );
  }
}
