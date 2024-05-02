import 'package:flutter/material.dart';
import 'package:fstory/common/styles.dart';
import 'package:fstory/core/shared_preferences/user_shared_preferences.dart';
import 'package:fstory/presentation/widgets/card_story.dart';
import 'package:fstory/presentation/widgets/loading.dart';
import 'package:fstory/presentation/widgets/response_message.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/login_entity.dart';
import '../providers/story_notifier.dart';

class HomePage extends StatefulWidget {
  final Function(String) onSelectedStory;
  final Function() isUploadSelected;
  final Function() loggingOut;
  final LoginEntity userLoginEntity;

  const HomePage(
      {super.key,
      required this.onSelectedStory,
      required this.isUploadSelected,
      required this.userLoginEntity,
      required this.loggingOut});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          context.read<StoryNotifier>().page != null) {
        _fetchListStory();
      }
    });
    Future.microtask(() async => _fetchListStory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "FStory",
          textAlign: TextAlign.start,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.w700, color: primaryColor),
        ),
        actions: [
          GestureDetector(
              onTap: () {
                UserSharedPreferences.logoutPreference();
                widget.loggingOut();
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(
                  Icons.logout,
                  color: primaryColor,
                  size: 28,
                ),
              ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.isUploadSelected();
        },
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: const Icon(
          Icons.add,
          color: secondaryGray,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Consumer<StoryNotifier>(
        builder: (ctx, provider, _) {
          final currentStoriesLength = provider.listStoryEntity?.length ?? 0;
          if (provider.getStoriesState == GetStoriesState.loading) {
            return const Loading();
          } else if (provider.getStoriesState == GetStoriesState.hasData) {
            return RefreshIndicator(
              onRefresh: () async {
                _refreshListStory();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount:
                      currentStoriesLength + (provider.page != null ? 1 : 0),
                  itemBuilder: (ctx, idx) {
                    if (idx == currentStoriesLength && provider.page != null) {
                      return const Loading();
                    }
                    return CardStory(
                      photoUrl: provider.listStoryEntity![idx].photoUrl,
                      name: provider.listStoryEntity![idx].name,
                      createdAt: provider.listStoryEntity![idx].createdAt,
                      description: provider.listStoryEntity![idx].description,
                      onTap: () {
                        widget
                            .onSelectedStory(provider.listStoryEntity![idx].id);
                      },
                    );
                  },
                ),
              ),
            );
          } else if (provider.getStoriesState == GetStoriesState.noData) {
            return const ResponseMessage(
              image: 'assets/images/no-data.png',
              message: 'No Data',
            );
          } else if (provider.getStoriesState == GetStoriesState.error) {
            return ResponseMessage(
              image: 'assets/images/error.png',
              message: "Error...\n${provider.errorMsg}",
              onPressed: () => _fetchListStory(),
            );
          } else {
            return const Loading();
          }
        },
      ),
    );
  }

  Future _fetchListStory() async {
    final storyNotifier = context.read<StoryNotifier>();
    await storyNotifier.getListStory(widget.userLoginEntity.token);
  }

  Future _refreshListStory() async {
    final storyProvider = context.read<StoryNotifier>();
    await storyProvider.refreshListStory(widget.userLoginEntity.token);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
