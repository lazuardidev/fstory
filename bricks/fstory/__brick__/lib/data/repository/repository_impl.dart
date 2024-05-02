import 'package:dartz/dartz.dart';
import 'package:{{appName.snakeCase()}}/domain/entities/login_entity.dart';
import 'package:{{appName.snakeCase()}}/domain/entities/story_detail_entity.dart';
import 'package:{{appName.snakeCase()}}/domain/entities/story_entity.dart';
import 'package:{{appName.snakeCase()}}/data/data_sources/data_source.dart';
import 'package:{{appName.snakeCase()}}/common/exception.dart';
import 'package:{{appName.snakeCase()}}/common/failure.dart';
import '../../domain/repositories/repository.dart';

class RepositoryImpl extends Repository {
  final DataSource dataSource;

  RepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, StoryDetailEntity>> getStoryDetail(
      String token, String id) async {
    try {
      final storyDetailModel = await dataSource.getStoryDetail(id, token);
      final storyDetailEntity = storyDetailModel.modelToEntity();
      return Right(storyDetailEntity);
    } on ServerException catch (e) {
      return Left(ServerFailure("Login invalid!\nError Info: ${e.toString()}"));
    } on ConnectionException catch (e) {
      return Left(
          ConnectionFailure("Internet Problem!\nError Info: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, List<StoryEntity>>> getStoryList(
      String token, String page, String sizeItems) async {
    try {
      final listStoryModel =
          await dataSource.getStoryList(token, page, sizeItems);
      final storyDetailEntity = listStoryModel
          .map((storyModel) => storyModel.modelToEntity())
          .toList();
      return Right(storyDetailEntity);
    } on ServerException catch (e) {
      return Left(
          ServerFailure("Failed to fetch data!\nError Info: ${e.toString()}"));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoginEntity>> login(String email, String pass) async {
    try {
      final loginModel = await dataSource.login(email, pass);
      final loginEntity = loginModel.modelToEntity();
      return Right(loginEntity);
    } on ServerException catch (e) {
      return Left(ServerFailure("Login failed!\n${e.msg}"));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.msg));
    }
  }

  @override
  Future<Either<Failure, String>> postStory(String token, String desc,
      List<int> bytes, String fileName, double? lat, double? lon) async {
    try {
      final storyResponse =
          await dataSource.postStory(token, desc, bytes, fileName, lat, lon);
      return Right(storyResponse);
    } on ServerException catch (e) {
      return Left(ServerFailure("Upload failed!\nError Info: ${e.msg}"));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.msg));
    }
  }

  @override
  Future<Either<Failure, String>> register(
      String name, String email, String pass) async {
    try {
      final registerResponse = await dataSource.register(name, email, pass);
      return Right(registerResponse);
    } on ServerException catch (e) {
      return Left(ServerFailure("Register failed!\nError Info: ${e.msg}"));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.msg));
    }
  }
}
