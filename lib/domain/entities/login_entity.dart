import 'package:json_annotation/json_annotation.dart';
part 'login_entity.g.dart';

@JsonSerializable()
class LoginEntity {
  String userId;
  String name;
  String token;

  LoginEntity({
    required this.userId,
    required this.name,
    required this.token,
  });

  factory LoginEntity.fromJson(Map<String, dynamic> json) =>
      _$LoginEntityFromJson(json);

  Map<String, dynamic> toJson() => _$LoginEntityToJson(this);
}
