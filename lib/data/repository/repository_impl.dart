import 'package:dartz/dartz.dart';
import 'package:fstory/domain/entity/login_entity.dart';
import 'package:fstory/domain/entity/story_detail_entity.dart';
import 'package:fstory/domain/entity/story_entity.dart';
import 'package:fstory/data/remotedatasource/remotedata_source.dart';
import 'package:fstory/common/exception.dart';
import 'package:fstory/common/failure.dart';
import '../../domain/repository/repository.dart';

class RepositoryImpl extends Repository {
  final RemoteDataSource remoteDataSource;

  RepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, StoryDetailEntity>> getStoryDetail(
      String token, String id) async {
    try {
      final storyDetailModel = await remoteDataSource.getStoryDetail(id, token);
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
  Future<Either<Failure, List<StoryEntity>>> getStoryList(String token) async {
    try {
      final listStoryModel = await remoteDataSource.getStoryList(token);
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
      final loginModel = await remoteDataSource.login(email, pass);
      final loginEntity = loginModel.modelToEntity();
      return Right(loginEntity);
    } on ServerException catch (e) {
      return Left(ServerFailure("Login failed!\n${e.msg}"));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.msg));
    }
  }

  @override
  Future<Either<Failure, String>> postStory(
      String token, String desc, List<int> bytes, String fileName) async {
    try {
      final storyResponse =
          await remoteDataSource.postStory(token, desc, bytes, fileName);
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
      final registerResponse =
          await remoteDataSource.register(name, email, pass);
      return Right(registerResponse);
    } on ServerException catch (e) {
      return Left(ServerFailure("Register failed!\nError Info: ${e.msg}"));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.msg));
    }
  }
}
