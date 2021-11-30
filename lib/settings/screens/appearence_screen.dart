import 'package:flutter/material.dart';
import 'package:theme_provider/theme_provider.dart';

enum Themes {
  light,
  dark,
  black,
}

class AppearenceScreen extends StatefulWidget {
  @override
  _AppearenceScreenState createState() => _AppearenceScreenState();
}

class _AppearenceScreenState extends State<AppearenceScreen> {
  Themes? _theme = Themes.light;

  @override
  Widget build(BuildContext context) {
    final themeId = ThemeProvider.themeOf(context).id;
    
    if (themeId == 'light_theme') {
      _theme = Themes.light;
    } else if (themeId == 'dark_theme') {
      _theme = Themes.dark;
    } else {
      _theme = Themes.black;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Appearence')),
      body: Column(
        children: [
          
          ListTile(
            title: const Text('Light theme'),
            trailing: Radio(
              value: Themes.light,
              groupValue: _theme,
              onChanged: (Themes? val) {
                ThemeProvider.controllerOf(context).setTheme('light_theme');
                setState(() {
                  _theme = val;
                });
              },
            ),
          ),
          // ListTile(
          //   title: const Text('Dark'),
          //   trailing: Radio(
          //     value: Themes.dark,
          //     groupValue: _theme,
          //     onChanged: (Themes? val) {
          //       ThemeProvider.controllerOf(context).setTheme('dark_theme');
          //       setState(() {
          //         _theme = val;
          //       });
          //     },
          //   ),
          // ),
          ListTile(
            title: const Text('Black theme'),
            trailing: Radio(
              value: Themes.black,
              groupValue: _theme,
              onChanged: (Themes? val) {
                ThemeProvider.controllerOf(context).setTheme('black_theme');
                setState(() {
                  _theme = val;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Device settings
