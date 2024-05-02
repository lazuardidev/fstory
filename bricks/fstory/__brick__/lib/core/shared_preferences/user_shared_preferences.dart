import 'package:{{appName.snakeCase()}}/common/constants.dart';
import 'package:{{appName.snakeCase()}}/domain/entities/login_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSharedPreferences {
  static late SharedPreferences sharedPreferences;
  static Future init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future loginPreference(LoginEntity loginEntity) async {
    await sharedPreferences.setString(TOKEN_KEY, loginEntity.token);
    await sharedPreferences.setString(NAME_KEY, loginEntity.name);
    await sharedPreferences.setString(ID_KEY, loginEntity.userId);
    await sharedPreferences.setBool(IS_LOGIN_KEY, true);
  }

  static Future logoutPreference() async {
    await sharedPreferences.remove(TOKEN_KEY);
    await sharedPreferences.remove(NAME_KEY);
    await sharedPreferences.remove(ID_KEY);
    await sharedPreferences.setBool(IS_LOGIN_KEY, false);
  }

  static bool isUserLoggedInPreference() {
    final isLoggedIn = sharedPreferences.getBool(IS_LOGIN_KEY) ?? false;
    return isLoggedIn;
  }

  static LoginEntity getUserPreference() {
    final token = sharedPreferences.getString(TOKEN_KEY) ?? "";
    final name = sharedPreferences.getString(NAME_KEY) ?? "";
    final id = sharedPreferences.getString(ID_KEY) ?? "";
    return LoginEntity(userId: id, name: name, token: token);
  }
}
