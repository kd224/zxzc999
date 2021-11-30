import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zxzc9992/auth/screens/change_password_screen.dart';
import 'package:zxzc9992/services/auth/auth.dart';

import 'package:zxzc9992/utils/keys.dart';

class AccountScreen extends StatelessWidget {
  Future<void> test() async {
    await Hive.openBox(authBoxKey);
    //await Hive.openBox(sessionInfoKey);
  }

  final _auth = Auth();
  final authBox = Hive.box(authBoxKey);

  @override
  Widget build(BuildContext context) {
    final sessionInfo = authBox.get(sessionInfoKey) as String;
    final decoded = jsonDecode(sessionInfo) as Map<String, dynamic>;
    final email = decoded["currentSession"]["user"]["email"] as String;
    final userId = decoded["currentSession"]["user"]["id"] as String;
    //final jwt = decoded["currentSession"]
    //final userId= Auth.auth.currentUser?.id;

    print(userId);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Column(
        children: [
          ListTile(
            //title: const Text('Email'),
            title: const Text('Email'),
            subtitle: Text(email),
            trailing: const Icon(Icons.email_outlined),
            onTap: () {
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => const ChangeCredentials(
              //           isChangeEmail: false,
              //         )));
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Password'),
            subtitle: const Text('********'),
            trailing: const Icon(Icons.password_rounded),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChangePasswordScreen()));
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => const ChangeCredentials(
              //           isChangeEmail: false,
              //         )));
            },
          ),
          const Divider(),
          ListTile(
            title: const Text(
              'Log out',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.logout_rounded),
            onTap: () async {
              final res = await _auth.signOut();
              if (res == false) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('An error occurred')),
                );
              } else {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/auth',
                  (route) => false,
                );
              }
            },
          ),
          const Divider(),
          // const Spacer(),
          // ListTile(
          //   title: Text(
          //     'Delete your account',
          //     style: TextStyle(
          //       color: Colors.red[400],
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          //   trailing:
          //       Icon(Icons.delete_forever_rounded, color: Colors.red[400]),
          //   onTap: () async {},
          // ),
        ],
      ),
    );
  }
}
