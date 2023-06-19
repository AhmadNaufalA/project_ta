import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey('user')) {
    return null;
  }

  final user = User.fromJson(prefs.getString('user')!);
  return user.token;
}
