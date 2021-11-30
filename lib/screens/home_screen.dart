import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zxzc9992/providers/decks_provider.dart';
import 'package:zxzc9992/screens/add_deck_screen.dart';
import 'package:zxzc9992/screens/settings_screen.dart';
import 'package:zxzc9992/services/ad_state.dart';
import 'package:zxzc9992/utils/keys.dart';
import 'package:zxzc9992/widgets/deck_tile.dart';

enum PopupSortAction { alphabetically, lastReviewed }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription? _sub;
  late BannerAd banner;

  bool _isLoading = false;
  bool _isInit = true;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    //final adState = Provider.of<AdState>(context, listen: false);

    if (_isInit) {
      setState(() => _isLoading = true);

      //_handleIncomingLinks();

      //final status = await adState.initialization;

      // setState(() {
      //   print('banner intialization');
      //   banner = BannerAd(
      //     adUnitId: adState.bannerAdUnitId,
      //     size: AdSize.banner,
      //     request: const AdRequest(),
      //     listener: adState.adListener,
      //   )..load();
      // });

      await Provider.of<DecksProvider>(context, listen: false).getDecksList();

      await Hive.openBox(flashcardsOptionsBox);
      await Hive.openBox(flashcardsStatsBox);

      setState(() => _isLoading = false);
    }
    _isInit = false;
  }

  @override
  void dispose() {
    super.dispose();
    Hive.box(flashcardsOptionsBox).close();
    Hive.box(flashcardsStatsBox).close();

    _sub?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final decksProvider = Provider.of<DecksProvider>(context);
    final decks = decksProvider.decksList;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.account_circle_outlined,
            color: Colors.grey[500],
            size: 28,
          ),
          onPressed: () async {
            Navigator.of(context).pushNamed(SettingsScreen.routeName);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 28),
            tooltip: 'Add a new deck',
            onPressed: () async {
              Navigator.of(context).pushNamed(AddDeckScreen.routeName);
            },
          ),
          // PopupMenuButton(
          //     icon: const Icon(Icons.sort_rounded, size: 28),
          //     tooltip: 'Sort by',
          //     itemBuilder: (_) => const [
          //           PopupMenuItem(
          //               child: Text('Alphabetically'),
          //               value: PopupSortAction.alphabetically),
          //           PopupMenuItem(
          //               child: Text('Recently reviewed'),
          //               value: PopupSortAction.lastReviewed),
          //           PopupMenuItem(
          //               child: Text('Recently created'),
          //               value: PopupSortAction.lastReviewed)
          //         ],
          //     onSelected: (PopupSortAction action) async {
          //       setState(() {
          //         if (action == PopupSortAction.alphabetically) {
          //           decksProvider.sortDecks(alphabetically: true);
          //           return;
          //         }

          //         if (action == PopupSortAction.lastReviewed) {
          //           decksProvider.sortDecks(lastReviewed: true);
          //           return;
          //         }
          //       });
          //     })
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await decksProvider.syncDecks();
                setState(() {});
              },
              child: CustomScrollView(slivers: [
                // SliverToBoxAdapter(
                //   child: Container(
                //     height: 50,
                //     child: AdWidget(
                //       ad: banner,
                //     ),
                //   ),
                // ),
                if (decks.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Text('You have no decks yet.'),
                    ),
                  ),
                //StatsSection(),
                // SliverToBoxAdapter(
                //     child: ListTile(
                //   title: Text('Review Progress'),
                // )),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => DeckTile(
                      title: decks[i].title,
                      cardsAmount: decks[i].cardsAmount,
                      deckId: decks[i].id,
                      createdAt: decks[i].createdAt,
                      lastPlayed: decks[i].lastPlayed,
                    ),
                    childCount: decks.length,
                  ),
                ),
              ]),
            ),
      //drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_rounded, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pushNamed(AddDeckScreen.routeName);
        },
      ),
    );
  }
}
