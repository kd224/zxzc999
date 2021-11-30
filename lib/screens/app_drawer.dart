import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zxzc9992/screens/settings_screen.dart';
import 'package:zxzc9992/utils/data_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(children: [
          ListTile(
            leading: const Icon(Icons.create_rounded),
            title: const Text('Create a deck'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pushNamed(SettingsScreen.routeName);
            },
          ),
          if (!kReleaseMode)
            ListTile(
              leading: const Icon(Icons.storage_rounded),
              title: const Text('Data'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => DataScreen()),
                );
              },
            ),
        ]),
      ),
    );
  }
}

//share, send feedback, rate use, upgrade
