import 'package:json_annotation/json_annotation.dart';
part 'story_entity.g.dart';

@JsonSerializable()
class StoryEntity {
  String id;
  String name;
  String description;
  String photoUrl;
  DateTime createdAt;
  double? lat;
  double? lon;

  StoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
    this.lat,
    this.lon,
  });

  factory StoryEntity.fromJson(Map<String, dynamic> json) =>
      _$StoryEntityFromJson(json);

  Map<String, dynamic> toJson() => _$StoryEntityToJson(this);
}
