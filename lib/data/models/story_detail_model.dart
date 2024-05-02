import 'package:fstory/domain/entities/story_detail_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'story_detail_model.g.dart';

@JsonSerializable()
class StoryDetailModel {
  String id;
  String name;
  String description;
  String photoUrl;
  DateTime createdAt;
  double? lat;
  double? lon;

  StoryDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
    this.lat,
    this.lon,
  });

  StoryDetailEntity modelToEntity() => StoryDetailEntity(
      id: id,
      name: name,
      description: description,
      photoUrl: photoUrl,
      createdAt: createdAt,
      lat: lat,
      lon: lon);

  factory StoryDetailModel.fromJson(Map<String, dynamic> json) =>
      _$StoryDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoryDetailModelToJson(this);
}
