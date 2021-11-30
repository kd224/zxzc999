import 'package:flutter/material.dart';
import 'package:zxzc9992/services/local_db/sqflite.dart';
import 'package:zxzc9992/settings/screens/appearence_screen.dart';
import 'package:zxzc9992/settings/screens/review_screen.dart';
import 'package:zxzc9992/settings/screens/account_section.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(children: [
        ListTile(
          leading: const Icon(Icons.account_circle_outlined),
          title: const Text('Account'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => AccountScreen()),
            );
          },
        ),
        const Divider(),
        ListTile(
          // TODO: Change the icon
          leading: const Icon(Icons.dark_mode_rounded),
          title: const Text('Appearence'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => AppearenceScreen()),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.show_chart_rounded),
          title: const Text('Flashcards reviewing'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => ReviewScreen()),
            );
          },
        ),
        const Divider(),
        TextButton(
          child: const Text('All decks'),
          onPressed: () async {
            final data = await DBHelper.fetch('decks');
            for (final x in data) {
              print(x);
            }
          },
        ),
        // TextButton(
        //   child: const Text('decks to sync'),
        //   onPressed: () async {
        //     final data = await DBHelper.fetch('decksToSync');
        //     for (final x in data) {
        //       print(x);
        //     }
        //   },
        // ),
        // TextButton(
        //   child: const Text('test'),
        //   onPressed: () async {
        //     // final deck = await DBHelper.fetch('decks', where: 'id = "1eWyZBw6r50"');
        //     // print(deck);
        //     //final data = await DBHelper.fetch('cards', where: 'id = "6MUEMq2E9kV"');
        //     //DBHelper.delete('cardsToSync', 'card_id', "YUHZhYHzvcb");
        //     // print(data);
        //     // for (final x in data) {
        //     //   print(x);
        //     // }
        //   },
        // ),
        // TextButton(
        //   child: const Text('All cards'),
        //   onPressed: () async {
        //     final data =
        //         await DBHelper.fetch('cards', where: 'id = "ia4TEqMO9XL"');
        //     print(data);
        //     // final data = await DBHelper.fetch('cards', where: 'deck_id = "LN3GSlDpR57"');
        //     // for (final x in data) {
        //     //   print(x);
        //     // }
        //   },
        // ),
        // TextButton(
        //   child: const Text('cards to sync'),
        //   onPressed: () async {
        //     final data = await DBHelper.fetch('cardsToSync');
        //     for (final x in data) {
        //       //final id = x['card_id'];
        //       //final data2 = await DBHelper.fetch('cards', where: 'card_id = "$id"');
        //       print(x);
        //     }
        //   },
        // ),
      ]),
    );
  }
}

//Language
// Notifications
// Delete account - Permanently delete your account

// ABOUT
// Share this app, send feedback, version 1.0.0
