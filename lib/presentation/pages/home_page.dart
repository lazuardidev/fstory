import 'package:flutter/material.dart';
import 'package:fstory/common/styles.dart';
import 'package:fstory/core/shared_preferences/user_shared_preferences.dart';
import 'package:fstory/presentation/widgets/card_story.dart';
import 'package:fstory/presentation/widgets/loading.dart';
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
  @override
  void initState() {
    super.initState();
    _fetchListStory();
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
                UserSharedPreferences.logoutPrefs();
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
          if (provider.getStoriesState == GetStoriesState.loading) {
            return const Loading();
          } else if (provider.getStoriesState == GetStoriesState.hasData) {
            return RefreshIndicator(
              onRefresh: () async {
                _fetchListStory();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: provider.listStoryEntity?.length ?? 0,
                  itemBuilder: (ctx, idx) {
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
            return const Center(
              child: Text(
                "There are no data to be displayed...",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.deepOrangeAccent),
              ),
            );
          } else if (provider.getStoriesState == GetStoriesState.error) {
            return Center(
              child: Text(
                provider.errorMsg ?? "Error...",
                textAlign: TextAlign.center,
                style: const TextStyle(color: primaryColor),
              ),
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
}
