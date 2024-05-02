import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:fstory/domain/entities/story_detail_entity.dart';
import 'package:fstory/domain/repositories/repository.dart';
import '../../domain/entities/story_entity.dart';

enum GetStoriesState { init, loading, noData, hasData, error }

enum GetStoryDetailState { init, loading, noData, hasData, error }

enum PostStoryState { init, loading, hasData, error }

class StoryNotifier extends ChangeNotifier {
  String? imagePath;
  XFile? imageFile;
  List<StoryEntity>? _listStoryEntity = [];
  StoryDetailEntity? _storyDetailEntity;
  String? _postResponse;
  String? _errorMsg;
  PostStoryState _postStoryState = PostStoryState.init;
  GetStoryDetailState _getStoryDetailState = GetStoryDetailState.init;
  GetStoriesState _getStoriesState = GetStoriesState.init;

  List<StoryEntity>? get listStoryEntity => _listStoryEntity;
  StoryDetailEntity? get storyDetailEntity => _storyDetailEntity;
  String? get postResponse => _postResponse;
  String? get errorMsg => _errorMsg;
  PostStoryState get postStoryState => _postStoryState;
  GetStoryDetailState get getStoryDetailState => _getStoryDetailState;
  GetStoriesState get getStoriesState => _getStoriesState;
  final Repository repository;

  int? page = 1;
  int sizeItems = 10;

  StoryNotifier({required this.repository});

  void setPostStoryInitState() {
    _postStoryState = PostStoryState.init;
  }

  void setImagePath(String? value) {
    imagePath = value;
    notifyListeners();
  }

  void setImageFile(XFile? value) {
    imageFile = value;
    notifyListeners();
  }

  Future getListStory(String token) async {
    if (page == 1) {
      _getStoriesState = GetStoriesState.loading;
    }
    _errorMsg = null;
    final storyListEntityFold = await repository.getStoryList(
        token, page.toString(), sizeItems.toString());
    storyListEntityFold.fold((error) {
      _errorMsg = error.msg;
      _getStoriesState = GetStoriesState.error;
    }, (response) {
      if (response.isEmpty) {
        _getStoriesState = GetStoriesState.noData;
        page = null;
      } else {
        if (response.length < sizeItems) {
          page = null;
        } else {
          page = page! + 1;
        }
        _getStoriesState = GetStoriesState.hasData;
        _listStoryEntity?.addAll(response);
      }
    });
    notifyListeners();
  }

  Future getStoryDetail(String token, String id) async {
    _errorMsg = null;
    _storyDetailEntity = null;

    final storyDetailEntityFold = await repository.getStoryDetail(token, id);
    storyDetailEntityFold.fold((error) {
      _errorMsg = error.msg;
      _getStoryDetailState = GetStoryDetailState.error;
    }, (response) {
      if (response.photoUrl.isEmpty) {
        _getStoryDetailState = GetStoryDetailState.noData;
        _storyDetailEntity = response;
      } else {
        _getStoryDetailState = GetStoryDetailState.hasData;
        _storyDetailEntity = response;
      }
    });
    notifyListeners();
  }

  Future postStory(String token, String desc, List<int> bytes, String filename,
      LatLng? latLng) async {
    _postStoryState = PostStoryState.loading;
    notifyListeners();

    _errorMsg = null;
    _postResponse = null;

    final Uint8List uint8List = Uint8List.fromList(bytes);
    final responseFold = await repository.postStory(
        token, desc, uint8List, filename, latLng?.latitude, latLng?.longitude);
    responseFold.fold((error) {
      _errorMsg = error.msg;
      _postStoryState = PostStoryState.error;
    }, (response) {
      _postResponse = response;
      _postStoryState = PostStoryState.hasData;
    });
    notifyListeners();
  }

  Future<List<int>> compressImage(Uint8List bytes) async {
    int imageLength = bytes.length;
    if (imageLength < 1000000) return bytes;
    final img.Image image = img.decodeImage(bytes)!;
    int compressQuality = 100;
    int length = imageLength;
    List<int> newByte = [];
    do {
      compressQuality -= 10;
      newByte = img.encodeJpg(
        image,
        quality: compressQuality,
      );
      length = newByte.length;
    } while (length > 1000000);
    return newByte;
  }

  void clearPreviousStory() {
    imageFile = null;
    imagePath = null;
    _postStoryState = PostStoryState.init;
    _postResponse = null;
    _errorMsg = null;
    notifyListeners();
  }

  Future<void> refreshListStory(String token) async {
    _listStoryEntity = [];
    page = 1;
    _errorMsg = null;
    await getListStory(token);
  }

  Future<bool> askLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }
}
