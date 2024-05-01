import 'package:flutter/material.dart';
import 'package:fstory/core/shared_preferences/user_shared_preferences.dart';
import 'package:fstory/presentation/pages/register_page.dart';
import 'package:fstory/presentation/pages/upload_page.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/story_notifier.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/detail_page.dart';
import '../../presentation/pages/home_page.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navKey;
  String? selectedStory;
  bool isLoggedIn = false;
  bool isRegisteredSelected = false;
  bool isUploadSelected = false;

  MyRouterDelegate() : _navKey = GlobalKey<NavigatorState>() {
    _init();
  }

  _init() async {
    isLoggedIn = UserSharedPreferences.isUserLoggedInPrefs();
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navKey,
      pages: [
        if (!isLoggedIn)
          MaterialPage(
            child: LoginPage(
              isLoggedIn: () {
                isLoggedIn = true;
                notifyListeners();
              },
              isRegisterClicked: () {
                isRegisteredSelected = true;
                notifyListeners();
              },
            ),
          ),
        if (isLoggedIn)
          MaterialPage(
            child: HomePage(
              onSelectedStory: (storyId) {
                selectedStory = storyId;
                final storyNotifier = context.read<StoryNotifier>();
                final token = UserSharedPreferences.getUserPrefs().token;
                storyNotifier.getStoryDetail(token, storyId);
                notifyListeners();
              },
              isUploadSelected: () {
                isUploadSelected = true;
                context.read<StoryNotifier>().setPostStoryInitState();
                notifyListeners();
              },
              userLoginEntity: UserSharedPreferences.getUserPrefs(),
              loggingOut: () {
                isLoggedIn = false;
                notifyListeners();
              },
            ),
          ),
        if (isLoggedIn && isUploadSelected)
          MaterialPage(
              child: UploadPage(
            isBackToHomePage: () {
              isUploadSelected = false;
              context
                  .read<StoryNotifier>()
                  .getListStory(UserSharedPreferences.getUserPrefs().token);
              notifyListeners();
            },
            userLoginEntity: UserSharedPreferences.getUserPrefs(),
          )),
        if (isRegisteredSelected)
          MaterialPage(
            child: RegisterPage(isSuccessfulyRegistered: () {
              isRegisteredSelected = false;
              notifyListeners();
            }),
          ),
        if (isLoggedIn && selectedStory != null)
          MaterialPage(
              child: DetailPage(
            storyId: selectedStory ?? "",
            token: UserSharedPreferences.getUserPrefs().token,
          )),
      ],
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) {
          return false;
        }
        isRegisteredSelected = false;
        selectedStory = null;
        isUploadSelected = false;
        notifyListeners();
        return true;
      },
    );
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navKey;

  @override
  Future<void> setNewRoutePath(configuration) {
    throw UnimplementedError();
  }
}
