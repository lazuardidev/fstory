import 'package:{{appName.snakeCase()}}/data/models/login_model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  bool error;
  String message;
  LoginModel loginResult;

  LoginResponse({
    required this.error,
    required this.message,
    required this.loginResult,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
