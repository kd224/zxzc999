import 'dart:async';

import 'package:uni_links/uni_links.dart';
import 'package:zxzc9992/services/auth/auth.dart';

mixin DeepLinking {
  StreamSubscription? _sub;

  // void startDeeplinkObserver() {
  //   print('***** deepLinkingMixin startAuthObserver');
  //   _handleIncomingLinks();
  //   // _handleInitialUri();
  // }

  // // Handle incoming links - the ones that the app will recieve from the OS
  // // while already started.
  // Future<void> _handleIncomingLinks() async {
  //   // ... check initialLink
  //   print('_handleIncomingLinks()');
  //   _sub = uriLinkStream.listen((Uri? uri) {
  //     // Parse the link and warn the user, if it is not correct

  //     print('uri: $uri');
  //     if (uri != null) {
  //       handleDeeplink(uri);
  //     }
  //   }, onError: (err) {
  //     // Handle exception by warning the user their action did not succeed
  //     print('_handleIncomingLinks err: $err');
  //   });

  //   // NOTE: Don't forget to call _sub.cancel() in dispose()
  // }

  // Callback when deeplink receiving succeeds
  //void handleDeeplink(Uri uri);
  // Future<bool> handleDeeplink(Uri uri) async {
  //   print('handleDeeplink(): $uri');
  //   final res = await Auth().auth.getSessionFromUrl(uri);
  //   print('res.data: ${res.data}');
  //   if (res.error == null) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  //zxzc9992://reset-callback/#access_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJhdXRoZW50aWNhdGVkIiwiZXhwIjoxNjM2OTE5NDM4LCJzdWIiOiI5YzQ3MGZlMS0zMmM0LTQ5NTctYTU5YS1hMmZhMDlhMjVhYWMiLCJlbWFpbCI6ImtkMjI0bWNAZ21haWwuY29tIiwicGhvbmUiOiIiLCJhcHBfbWV0YWRhdGEiOnsicHJvdmlkZXIiOiJlbWFpbCJ9LCJ1c2VyX21ldGFkYXRhIjp7fSwicm9sZSI6ImF1dGhlbnRpY2F0ZWQifQ.raRpCqkv7_o80gBKcvERtqSBfwFa3moZ_6ml17rE4Ng&expires_in=3600&refresh_token=HbpwmOZQI5xlV7fACrmYxA&token_type=bearer&type=recovery
}
