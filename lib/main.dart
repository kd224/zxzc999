import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase/supabase.dart' as s;
import 'package:theme_provider/theme_provider.dart';
import 'package:path_provider/path_provider.dart' as p;

import 'package:zxzc9992/providers/cards_provider.dart';
import 'package:zxzc9992/providers/decks_provider.dart';
import 'package:zxzc9992/providers/flashcards_provider.dart';
import 'package:zxzc9992/services/ad_state.dart';
import 'package:zxzc9992/services/auth/auth.dart';

import 'package:zxzc9992/screens/add_card_screen.dart';
import 'package:zxzc9992/screens/add_deck_screen.dart';
import 'package:zxzc9992/screens/deck_screen.dart';
import 'package:zxzc9992/screens/splash_screen.dart';
import 'package:zxzc9992/screens/home_screen.dart';
import 'package:zxzc9992/screens/settings_screen.dart';
import 'package:zxzc9992/flashcards/screens/flashcards_screen.dart';
import 'package:zxzc9992/auth/screens/auth_screen.dart';

import 'package:zxzc9992/services/auth/auth_main.dart';
import 'package:zxzc9992/utils/keys.dart';
import 'package:zxzc9992/utils/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //final initFuture = MobileAds.instance.initialize();
  //final adState = AdState(initFuture);

  final appDocDir = await p.getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);

  await AuthMain.initialize(client: s.SupabaseClient(supabaseUrl, supabaseKey));

  runApp(
    // Provider.value(
    //   value: adState,
    //   builder: (context, child) => MyApp(),
    // ),
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  //final Auth _auth = Auth();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => DecksProvider()),
        ChangeNotifierProvider(create: (ctx) => CardsProvider()),
        ChangeNotifierProvider(create: (ctx) => FlashcardsProvider()),
      ],
      child: ThemeProvider(
        saveThemesOnChange: true,
        loadThemeOnInit: true,
        themes: [
          AppTheme(id: "light_theme", description: "light", data: lightTheme),
          AppTheme(id: "dark_theme", description: "dark", data: darkTheme),
          AppTheme(id: "black_theme", description: "black", data: blackTheme),
        ],
        child: ThemeConsumer(
          child: Builder(
            builder: (themeContext) => MaterialApp(
              theme: ThemeProvider.themeOf(themeContext).data,
              home: SplashScreen(),
              // StreamBuilder(
              //     stream: Auth().onAuthStateChange,
              //     builder: (context, snapshot) {
              //       if (snapshot.hasData) {
              //         print(snapshot.data);
              //       }
              //       return SplashScreen();
              //     }),
              //initialRoute: '/',
              routes: {
                '/home': (ctx) => HomeScreen(),
                AuthScreen.routeName: (ctx) => AuthScreen(),
                DeckScreen.routeName: (ctx) => DeckScreen(),
                AddDeckScreen.routeName: (ctx) => AddDeckScreen(),
                AddCardScreen.routeName: (ctx) => AddCardScreen(),
                SettingsScreen.routeName: (ctx) => SettingsScreen(),
                FlashcardsScreen.routeName: (ctx) => FlashcardsScreen(),
              },
            ),
          ),
        ),
      ),
    );
  }
}
