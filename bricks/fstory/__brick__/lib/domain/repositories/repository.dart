import 'package:dartz/dartz.dart';
import 'package:{{appName.snakeCase()}}/domain/entities/login_entity.dart';
import 'package:{{appName.snakeCase()}}/domain/entities/story_detail_entity.dart';
import 'package:{{appName.snakeCase()}}/domain/entities/story_entity.dart';
import '../../common/failure.dart';

abstract class Repository {
  Future<Either<Failure, List<StoryEntity>>> getStoryList(
      String token, String page, String sizeItems);
  Future<Either<Failure, StoryDetailEntity>> getStoryDetail(
      String token, String id);
  Future<Either<Failure, LoginEntity>> login(String email, String pass);
  Future<Either<Failure, String>> register(
      String name, String email, String pass);
  Future<Either<Failure, String>> postStory(String token, String desc,
      List<int> bytes, String fileName, double? lat, double? lon);
}
