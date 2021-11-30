import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import 'package:supabase/supabase.dart';
import 'package:zxzc9992/services/auth/auth_main.dart';
import 'package:zxzc9992/services/deep_linking.dart';

import 'package:zxzc9992/utils/keys.dart';

class Auth with DeepLinking {
  
  /// Get the auth client from the current SupabaseClient
  GoTrueClient get auth => AuthMain.client.auth;

  final _authController = StreamController<AuthChangeEvent>.broadcast();

  Stream<AuthChangeEvent> get onAuthStateChange =>
      _authController.stream;

  late String userId;
  late bool initialized = false;

  /// Intiailize the auth.
  ///
  /// This must be called only once on the app
  Future<void> intialize() async {
    print("initialize 1");

    //startDeeplinkObserver();

    await Hive.openBox(authBoxKey);

    await _initListeners();

    final connection = await Connectivity().checkConnectivity();
    if (connection != ConnectivityResult.none) {
      print(connection);
      await recoverPersistedSession();
    }

    print('initialize 2');
    //userId = ;
  }

  void connectionListener() {
    if (initialized == false) return;

    Connectivity().onConnectivityChanged.listen((
      ConnectivityResult result,
    ) async {
      if (result != ConnectivityResult.none) {
        await recoverPersistedSession();
        print('auth, initialize: ${auth.currentUser?.id}');
      }
    });
  }

  Future<void> _initListeners() async {
    auth.onAuthStateChange((event, session) {
      _authController.add(event);
    });

    onAuthStateChange.listen((event) async {
      print('auth, _initListeners: $event');
      //if (event == AuthChangeEvent.userUpdated) {}

      if (event == AuthChangeEvent.signedIn) {
        if (auth.currentSession != null) {
          await persistSession();
        }
        return;
      }
      if (event == AuthChangeEvent.signedOut) {
        await unpersistSession();
        return;
      }

      if (event == AuthChangeEvent.passwordRecovery) {
        
      }
    });
  }

  Future<bool> isAuthenticated() async {
    final box = await Hive.openBox(authBoxKey);
    final sessionInfo = box.get(sessionInfoKey);

    if (sessionInfo != null) {
      return true;
    } else {
      return false;
    }
  }

  /// Dispose the addon to free up resources.
  ///
  /// The [onAuthStateChange] stream can not be used after this
  /// method is called.
  void dispose() {
    _authController.close();
  }

  /// Persist the current user session on the disk
  Future<void> persistSession() {
    assert(auth.currentSession != null, 'There is not session to be persisted');
    final box = Hive.box(authBoxKey);
    return box.put(sessionInfoKey, auth.currentSession!.persistSessionString);
  }

  /// Remove the persisted session on the disk
  Future<void> unpersistSession() {
    final box = Hive.box(authBoxKey);
    return box.delete(sessionInfoKey);
  }

  /// Recover the persisted session from disk
  Future<bool> recoverPersistedSession() async {
    final box = Hive.box(authBoxKey);
    if (box.containsKey(sessionInfoKey)) {
      final sessionInfo = box.get(sessionInfoKey) as String;
      final res = await auth.recoverSession(sessionInfo);
      if (res.error != null) {
        print('recoverPersistedSession: ${res.error?.message}');
        signOut();
        return false;
      } else {
        final valid = res.data is Session;
        if (valid) {
          _authController.add(AuthChangeEvent.signedIn);
        }
        return valid;
      }
    }

    return false;
  }

  Future<bool> signIn(String email, String password) async {
    final res = await auth.signIn(email: email, password: password);

    if (res.error == null) return true;

    log('Sign in error: ${res.error!.message}');
    return false;
  }

  Future<bool> signUp(String email, String password) async {
    final res = await auth.signUp(
      email,
      password,
      options: AuthOptions(redirectTo: 'zxzc9992://login-callback/'),
    );

    if (res.error == null) return true;

    log('Sign in error: ${res.error!.message}');
    return false;
  }

 Future<bool> signOut() async {
    final response = await auth.signOut();
    if (response.error == null) {
      return true;
    }
    log('Log out error: ${response.error!.message}');
    return false;
  }

  Future<bool> resetPassword(String email) async {
    final res = await auth.api.resetPasswordForEmail(email);
    if (res.error == null) {}
    return false;
  }
}
