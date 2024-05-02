import 'package:{{appName.snakeCase()}}/domain/entities/login_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'login_model.g.dart';

@JsonSerializable()
class LoginModel {
  String userId;
  String name;
  String token;

  LoginModel({
    required this.userId,
    required this.name,
    required this.token,
  });

  LoginEntity modelToEntity() =>
      LoginEntity(userId: userId, name: name, token: token);

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}
