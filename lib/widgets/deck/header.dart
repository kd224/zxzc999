import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class DeckHeader extends StatelessWidget {
  final String title;
  final int cardsAmount;
  final bool areCardsEmpty;

  const DeckHeader({
    required this.title,
    required this.cardsAmount,
    required this.areCardsEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FaIcon(FontAwesomeIcons.folder, size: 30),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '$cardsAmount cards in this deck',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[500],
              ),
            ),
            //SearchBar(),
            Visibility(
              visible: areCardsEmpty && true,
              child: const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(
                  child: Text('You have no cards yet'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}