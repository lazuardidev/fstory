import 'package:{{appName.snakeCase()}}/domain/entities/story_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'story_model.g.dart';

@JsonSerializable()
class StoryModel {
  String id;
  String name;
  String description;
  String photoUrl;
  DateTime createdAt;
  double? lat;
  double? lon;

  StoryModel(
      {required this.id,
      required this.name,
      required this.description,
      required this.photoUrl,
      required this.createdAt,
      this.lat,
      this.lon});

  StoryEntity modelToEntity() => StoryEntity(
      id: id,
      name: name,
      description: description,
      photoUrl: photoUrl,
      createdAt: createdAt,
      lat: lat,
      lon: lon);

  factory StoryModel.fromJson(Map<String, dynamic> json) =>
      _$StoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$StoryModelToJson(this);
}
