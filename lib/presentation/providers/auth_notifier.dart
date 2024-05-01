import 'package:flutter/cupertino.dart';
import 'package:fstory/core/shared_preferences/user_shared_preferences.dart';
import 'package:fstory/domain/repositories/repository.dart';
import '../../domain/entities/login_entity.dart';

class AuthNotifier extends ChangeNotifier {
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

  AuthNotifier({required this.repository});

  Future login(String email, String pass) async {
    _loginLoading = true;
    notifyListeners();

    _loginEntity = null;
    _errorMsg = null;

    final loginEntityFold = await repository.login(email, pass);
    loginEntityFold.fold(
        (error) => _errorMsg = error.msg,
        (response) => _loginEntity = LoginEntity(
            userId: response.userId,
            name: response.name,
            token: response.token));
    if (loginEntity != null) {
      UserSharedPreferences.loginPreference(loginEntity!);
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
    registerEntityFold.fold((error) => _errorMsg = error.msg,
        (response) => _responseMsg = response);
    _registerLoading = false;
    notifyListeners();
  }
}
