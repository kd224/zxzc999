import 'package:flutter/material.dart';
import 'package:zxzc9992/services/local_db/sqflite.dart';

class DataScreen extends StatelessWidget {
  Future<void> printData(String table) async {
    final data = await DBHelper.fetch(table);
    for (final x in data) {
      print(x);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(
            child: const Text('Decks'),
            onPressed: () async {
              await printData('decks');
            },
          ),
          ElevatedButton(
            child: const Text('Cards'),
            onPressed: () async {
              await printData('cards');
            },
          ),
          ElevatedButton(
            child: const Text('decksToSync'),
            onPressed: () async {
              await printData('decks');
            },
          ),
          ElevatedButton(
            child: const Text('CardsToSync'),
            onPressed: () async {
              await printData('cardsToSync');
            },
          ),
        ],
      ),
    );
  }
}
