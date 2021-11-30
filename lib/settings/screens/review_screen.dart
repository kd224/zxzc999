import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zxzc9992/settings/widgets/cards_per_game_dialog.dart';

class ReviewScreen extends StatefulWidget {
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final box = Hive.box('flashcards_options'); 

  bool frontToBack = true;
  int cardsPerGame = 25;

  @override
  void initState() {
    super.initState();

    final data = box.get('default');

    if (data != null) {
      frontToBack = data['cards_orientation'] as bool;
      cardsPerGame = data['cards_per_game'] as int;
    }
  }

  void _persistOptions(bool cardsOrientation, int cardsPerGame) {
    box.put('default', {
      'cards_orientation': cardsOrientation,
      'cards_per_game': cardsPerGame,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards Reviewing'),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text('Cards orientation'),
            trailing: Text(frontToBack ? 'front to back' : 'back to front'),
            onTap: () async {
              setState(() => frontToBack = !frontToBack);

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

              setState(() => cardsPerGame = data);
            },
          ),
        ],
      ),
    );
  }
}
