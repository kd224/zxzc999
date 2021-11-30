import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zxzc9992/providers/cards_provider.dart';
import 'package:zxzc9992/widgets/card_tile.dart';

class CardsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cardsProvider = Provider.of<CardsProvider>(context);
    final cards = cardsProvider.currentCards;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => CardTile(
          id: cards[i].id,
          front: cards[i].front,
          back: cards[i].back,
          frontImg: cards[i].frontImg,
          repetitions: cards[i].repetitions,
          grade: cards[i].grade,
          ef: cards[i].easeFactor,
          interval: cards[i].interval,
        ),
        childCount: cards.length,
      ),
    );
  }
}
