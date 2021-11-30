import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:zxzc9992/screens/deck_screen.dart';

class DeckTile extends StatelessWidget {
  final String title;
  final int cardsAmount;
  final String deckId;

  // Temporary
  final int createdAt;
  final int lastPlayed;

  const DeckTile({
    required this.title,
    required this.cardsAmount,
    required this.deckId,
    required this.createdAt,
    required this.lastPlayed,
  });

  @override
  Widget build(BuildContext context) {
    final unescape = HtmlUnescape();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).backgroundColor),
        ),
      ),
      child: ListTile(
        title: Text(
          unescape.convert(title),
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.15,
              ),
        ),
        subtitle: Text(
          '$cardsAmount Cards in this deck',
          style: TextStyle(
            color: Colors.grey[500],
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right_rounded,
          color: Colors.grey[300],
        ),
        onTap: () {
          Navigator.of(context)
              .pushNamed(DeckScreen.routeName, arguments: deckId);
        },
      ),
    );
  }
}
