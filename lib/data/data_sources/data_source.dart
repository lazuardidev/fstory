import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fstory/common/exception.dart';
import 'package:fstory/data/models/login_model.dart';
import 'package:fstory/data/models/story_detail_model.dart';
import 'package:fstory/data/models/story_model.dart';
import 'package:fstory/data/models/login_response.dart';
import 'package:fstory/data/models/server_response.dart';
import 'package:fstory/data/models/story_detail_response.dart';
import 'package:fstory/data/models/story_list_response.dart';

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

  const DataSourceImpl({required this.dio});

  @override
  Future<String> register(String name, String email, String pass) async {
    try {
      final response = await dio.post("$baseUrl/register",
          options: Options(
            headers: {
              HttpHeaders.contentTypeHeader: "application/json",
            },
          ),
          data: jsonEncode({"name": name, "email": email, "password": pass}));
      if (response.statusCode == 201) {
        return ServerResponse.fromJson(response.data).message;
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
      final response = await dio.post("$baseUrl/login",
          options: Options(
              headers: {HttpHeaders.contentTypeHeader: "application/json"}),
          data: jsonEncode({"email": email, "password": pass}));

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data).loginResult;
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
      final response = await dio.get("$baseUrl/stories?size=30",
          options: Options(headers: {"Authorization": "Bearer $token"}));
      if (response.statusCode == 200) {
        return StoryListResponse.fromJson(response.data).listStory;
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
      final response = await dio.get("$baseUrl/stories/$id",
          options: Options(headers: {"Authorization": "Bearer $token"}));
      if (response.statusCode == 200) {
        return StoryDetailResponse.fromJson(response.data).story;
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
      final response = await dio.post("$baseUrl/stories",
          options: Options(headers: {
            "Authorization": "Bearer $token",
            HttpHeaders.contentTypeHeader: "multipart/form-data"
          }),
          data: formData);
      if (response.statusCode == 201) {
        return ServerResponse.fromJson(response.data).message;
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
