import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:fstory/domain/entities/story_detail_entity.dart';
import 'package:fstory/domain/repositories/repository.dart';

import '../../domain/entities/story_entity.dart';

enum ListStoryState { init, loading, noData, hasData, error }

enum StoryDetailState { init, loading, noData, hasData, error }

enum UploadStoryState { init, loading, hasData, error }

class StoryProvider extends ChangeNotifier {
  String? imagePath;
  XFile? imageFile;
  List<CameraDescription>? _listCameraDescription;
  List<StoryEntity>? _listStoryEntity;
  StoryDetailEntity? _storyDetailEntity;
  String? _postResponse;
  String? _errorMsg;
  UploadStoryState _uploadStoryState = UploadStoryState.init;
  StoryDetailState _storyDetailState = StoryDetailState.init;
  ListStoryState _listStoryState = ListStoryState.init;

  List<StoryEntity>? get listStoryEntity => _listStoryEntity;
  StoryDetailEntity? get storyDetailEntity => _storyDetailEntity;
  String? get postResponse => _postResponse;
  String? get errorMsg => _errorMsg;
  UploadStoryState get uploadStoryState => _uploadStoryState;
  StoryDetailState get storyDetailState => _storyDetailState;
  ListStoryState get listStoryState => _listStoryState;
  List<CameraDescription>? get listCameraDescription => _listCameraDescription;
  final Repository repository;

  StoryProvider({required this.repository});

  void setListCameraDescription(List<CameraDescription> cameras) {
    _listCameraDescription = cameras;
  }

  void setPostStoryInitState() {
    _uploadStoryState = UploadStoryState.init;
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
    _listStoryState = ListStoryState.loading;

    _errorMsg = null;
    _listStoryEntity = null;

    final storyListEntityFold = await repository.getStoryList(token);
    storyListEntityFold.fold((l) {
      _errorMsg = l.msg;
      _listStoryState = ListStoryState.error;
    }, (r) {
      if (r.isEmpty) {
        _listStoryState = ListStoryState.noData;
        _listStoryEntity = r;
      } else {
        _listStoryState = ListStoryState.hasData;
        _listStoryEntity = r;
      }
    });

    notifyListeners();
  }

  Future getStoryDetail(String token, String id) async {
    _errorMsg = null;
    _storyDetailEntity = null;

    final storyDetailEntityFold = await repository.getStoryDetail(token, id);
    storyDetailEntityFold.fold((l) {
      _errorMsg = l.msg;
      _storyDetailState = StoryDetailState.error;
    }, (r) {
      if (r.photoUrl.isEmpty) {
        _storyDetailState = StoryDetailState.noData;
        _storyDetailEntity = r;
      } else {
        _storyDetailState = StoryDetailState.hasData;
        _storyDetailEntity = r;
      }
    });
    notifyListeners();
  }

  Future postStory(
      String token, String desc, List<int> bytes, String filename) async {
    _uploadStoryState = UploadStoryState.loading;
    notifyListeners();

    _errorMsg = null;
    _postResponse = null;

    final Uint8List uint8List = Uint8List.fromList(bytes);
    final responseFold =
        await repository.postStory(token, desc, uint8List, filename);
    responseFold.fold((l) {
      _errorMsg = l.msg;
      _uploadStoryState = UploadStoryState.error;
    }, (r) {
      _postResponse = r;
      _uploadStoryState = UploadStoryState.hasData;
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
}
