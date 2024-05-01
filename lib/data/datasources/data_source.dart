import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fstory/common/exception.dart';
import 'package:fstory/data/models/login_model.dart';
import 'package:fstory/data/models/story_detail_model.dart';
import 'package:fstory/data/models/story_model.dart';
import 'package:fstory/data/datasources/response/login_response.dart';
import 'package:fstory/data/datasources/response/server_response.dart';
import 'package:fstory/data/datasources/response/story_detail_response.dart';
import 'package:fstory/data/datasources/response/story_list_response.dart';

abstract class DataSource {
  Future<List<StoryModel>> getStoryList(String token);
  Future<StoryDetailModel> getStoryDetail(String id, String token);
  Future<LoginModel> login(String email, String pass);
  Future<String> register(String name, String email, String pass);
  Future<String> postStory(
    String token,
    String desc,
    List<int> bytes,
    String fileName,
  );
}

class DataSourceImpl implements DataSource {
  final Dio dio;
  static const baseUrl = "https://story-api.dicoding.dev/v1";
  static const endpointRegister = "/register";
  static const endpointLogin = "/login";
  static const endpointAccountAddStory = "/stories";
  static const endpointGetStories = "/stories?size=25";
  static const endpointGetDetail = "/stories/";

  const DataSourceImpl({required this.dio});

  @override
  Future<String> register(String name, String email, String pass) async {
    try {
      final registerResponse = await dio.post(baseUrl + endpointRegister,
          options: Options(
            headers: {
              HttpHeaders.contentTypeHeader: "application/json",
            },
          ),
          data: jsonEncode({"name": name, "email": email, "password": pass}));
      if (registerResponse.statusCode == 201) {
        return ServerResponse.fromJson(registerResponse.data).message;
      } else {
        throw const ServerException(msg: "Server Problem Occured");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(msg: e.response!.data["message"]);
      } else {
        throw const ConnectionException(msg: "Internet Connection Problem!");
      }
    }
  }

  @override
  Future<LoginModel> login(String email, String pass) async {
    try {
      final loginResponse = await dio.post(baseUrl + endpointLogin,
          options: Options(
              headers: {HttpHeaders.contentTypeHeader: "application/json"}),
          data: jsonEncode({"email": email, "password": pass}));

      if (loginResponse.statusCode == 200) {
        return LoginResponse.fromJson(loginResponse.data).loginResult;
      } else {
        throw const ServerException(msg: "Server Problem Occured");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(msg: e.response!.data["message"]);
      } else {
        throw const ConnectionException(msg: "Internet Connection Problem!");
      }
    }
  }

  @override
  Future<List<StoryModel>> getStoryList(String token) async {
    try {
      final storyListResponse = await dio.get(baseUrl + endpointGetStories,
          options: Options(headers: {"Authorization": "Bearer $token"}));
      if (storyListResponse.statusCode == 200) {
        return StoryListResponse.fromJson(storyListResponse.data).listStory;
      } else {
        throw const ServerException(msg: "Incorrect/expired bearer token");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(msg: e.response!.data["message"]);
      } else {
        throw const ConnectionException(msg: "Internet Connection Problem!");
      }
    }
  }

  @override
  Future<StoryDetailModel> getStoryDetail(String id, String token) async {
    try {
      final storyDetailResponse = await dio.get(
          baseUrl + endpointGetDetail + id,
          options: Options(headers: {"Authorization": "Bearer $token"}));
      if (storyDetailResponse.statusCode == 200) {
        return StoryDetailResponse.fromJson(storyDetailResponse.data).story;
      } else {
        throw const ServerException(msg: "Incorrect/expired bearer token");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(msg: e.response!.data["message"]);
      } else {
        throw const ConnectionException(msg: "Internet Connection Problem!");
      }
    }
  }

  @override
  Future<String> postStory(
    String token,
    String desc,
    List<int> bytes,
    String fileName,
  ) async {
    try {
      var formData = FormData.fromMap({
        'photo': MultipartFile.fromBytes(bytes, filename: fileName),
        'description': desc
      });
      final postStoryResponse =
          await dio.post(baseUrl + endpointAccountAddStory,
              options: Options(headers: {
                "Authorization": "Bearer $token",
                HttpHeaders.contentTypeHeader: "multipart/form-data"
              }),
              data: formData);
      if (postStoryResponse.statusCode == 201) {
        return ServerResponse.fromJson(postStoryResponse.data).message;
      } else {
        throw const ServerException(msg: "Incorrect/expired bearer token");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(msg: e.response!.data["message"]);
      } else {
        throw const ConnectionException(msg: "Internet Connection Problem!");
      }
    }
  }
}