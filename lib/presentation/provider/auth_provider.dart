import 'package:flutter/cupertino.dart';
import 'package:fstory/core/sharedpreferences/user_shared_preferences.dart';
import 'package:fstory/domain/repositories/repository.dart';

import '../../domain/entities/login_entity.dart';

class AuthProvider extends ChangeNotifier {
  LoginEntity? _loginEntity;
  String? _responseMsg;
  String? _errorMsg;
  bool _registerLoading = false;
  bool _loginLoading = false;

  LoginEntity? get loginEntity => _loginEntity;
  String? get responseMsg => _responseMsg;
  String? get errorMsg => _errorMsg;
  bool get registerLoading => _registerLoading;
  bool get loginLoading => _loginLoading;

  final Repository repository;

  AuthProvider({required this.repository});

  Future login(String email, String pass) async {
    _loginLoading = true;
    notifyListeners();

    _loginEntity = null;
    _errorMsg = null;

    final loginEntityFold = await repository.login(email, pass);
    loginEntityFold.fold(
        (l) => _errorMsg = l.msg,
        (r) => _loginEntity =
            LoginEntity(userId: r.userId, name: r.name, token: r.token));
    if (loginEntity != null) {
      UserSharedPreferences.loginPrefs(loginEntity!);
    }
    _loginLoading = false;
    notifyListeners();
  }

  Future register(String name, String email, String pass) async {
    _registerLoading = true;
    notifyListeners();

    _responseMsg = null;
    _errorMsg = null;

    final registerEntityFold = await repository.register(name, email, pass);
    registerEntityFold.fold((l) => _errorMsg = l.msg, (r) => _responseMsg = r);
    _registerLoading = false;
    notifyListeners();
  }
}
