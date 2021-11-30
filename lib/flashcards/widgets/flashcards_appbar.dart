import 'package:flutter/material.dart';
import 'package:zxzc9992/flashcards/screens/flashcards_options_screen.dart';
import 'package:zxzc9992/settings/models/flashcards_options.dart';

class FlashcardsAppBar extends StatelessWidget {
  final Function? onOptionsChanged;

  const FlashcardsAppBar({this.onOptionsChanged});

  @override
  Widget build(BuildContext context) {
    //final flashcards = Provider.of<FlashcardsProvider>(context, listen: false);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 30),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const Spacer(),
            // IconButton(
            //   icon: Icon(Icons.undo_outlined, size: 30, color: Colors.grey[500]),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            // ),
            IconButton(
              icon: Icon(Icons.tune_rounded, size: 30, color: Colors.grey[500]),
              onPressed: () async {
                final FlashcardsOptions? res =
                    await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => FlashcardsOptionsScreen(),
                ));

                if (res != null) {
                  onOptionsChanged!(res.cardsPerGame, res.isFrontFirst);
                }
              },
            ),

            // IconButton(
            //   icon: const Icon(Icons.undo_rounded, size: 34),
            //   onPressed: () {},
            // ),
            // IconButton(
            //   icon: const Icon(Icons.edit_rounded, size: 34),
            //   onPressed: () async {
            //     final cardId = flashcards.currentCardId();

            //     await Navigator.of(context).pushNamed(
            //       AddCardScreen.routeName,
            //       arguments: cardId,
            //     );

            //      Czy nie ma błędów w tekscie?
            //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            //         content: Text('Changes will occur in next play')));
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
