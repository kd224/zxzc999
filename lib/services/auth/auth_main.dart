import 'package:supabase/supabase.dart';
import 'package:zxzc9992/services/auth/auth.dart';
class AuthMain {
  AuthMain._();

  /// The supabase client used by the addons.
  static late SupabaseClient client;

  static String? appVersion;

  static Future<void> initialize({
    required SupabaseClient client,
    String? appVersion,
  }) async {
    AuthMain.client = client;
    AuthMain.appVersion = appVersion;
    await Auth().intialize();
  }

  static void dispose() {
    Auth().dispose();
  }
}
