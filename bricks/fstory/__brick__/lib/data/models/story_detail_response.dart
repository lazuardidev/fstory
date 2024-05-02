import 'package:{{appName.snakeCase()}}/data/models/story_detail_model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'story_detail_response.g.dart';

@JsonSerializable()
class StoryDetailResponse {
  bool error;
  String message;
  StoryDetailModel story;

  StoryDetailResponse({
    required this.error,
    required this.message,
    required this.story,
  });

  factory StoryDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$StoryDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StoryDetailResponseToJson(this);
}
