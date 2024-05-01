import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fstory/common/styles.dart';
import 'package:fstory/presentation/widgets/btn_primary.dart';
import 'package:fstory/presentation/widgets/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fstory/domain/entities/login_entity.dart';
import 'package:fstory/presentation/providers/story_notifier.dart';
import 'package:provider/provider.dart';

class UploadPage extends StatefulWidget {
  final Function() isBackToHomePage;
  final LoginEntity userLoginEntity;
  const UploadPage(
      {super.key,
      required this.isBackToHomePage,
      required this.userLoginEntity});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String? _desc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Story")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            SizedBox(
              child: context.watch<StoryNotifier>().imagePath == null
                  ? const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image,
                        size: 300,
                      ),
                    )
                  : _showImage(),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _onGalleryView(),
                  child: const Text("Gallery"),
                ),
                ElevatedButton(
                  onPressed: () => _onCameraView(),
                  child: const Text("Camera"),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(26, 14, 4, 14),
                hintText: 'Enter description...',
                hintStyle: Theme.of(context).textTheme.bodyLarge,
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: primaryGray, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: primaryColor, width: 1),
                ),
              ),
              onChanged: (inputDesc) {
                setState(() {
                  _desc = inputDesc;
                });
              },
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(
              height: 40,
            ),
            Consumer<StoryNotifier>(
              builder: (ctx, provider, _) {
                if (provider.postStoryState == PostStoryState.loading) {
                  return const Center(
                    child: Loading(),
                  );
                } else if (provider.postStoryState == PostStoryState.init) {
                  return BtnPrimary(
                    title: 'Upload',
                    onClick: () {
                      _onUpload(provider);
                    },
                  );
                } else if (provider.postStoryState == PostStoryState.error) {
                  _showSnackbar(provider.errorMsg);
                  return BtnPrimary(
                    title: 'Upload',
                    onClick: () {
                      _onUpload(provider);
                    },
                  );
                } else if (provider.postStoryState == PostStoryState.hasData) {
                  WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _showSnackbar("Sukses upload story"));
                  return BtnPrimary(
                    title: 'Upload',
                    onClick: () {
                      _onUpload(provider);
                    },
                  );
                } else {
                  return const Loading();
                }
              },
            )
          ],
        ),
      ),
    );
  }

  _onSuccess() {
    widget.isBackToHomePage();
  }

  _onUpload(StoryNotifier provider) async {
    final imagePath = provider.imagePath;
    final imageFile = provider.imageFile;
    if (imagePath == null || imageFile == null || _desc == null) {
      final ScaffoldMessengerState scaffoldMessengerState =
          ScaffoldMessenger.of(context);
      scaffoldMessengerState.showSnackBar(
        const SnackBar(
          content:
              Text("Please insert your story pics and fill the description!"),
        ),
      );
      return;
    }
    final fileName = imageFile.name;
    final bytes = await imageFile.readAsBytes();
    final newBytes = await provider.compressImage(bytes);
    await provider.postStory(
      widget.userLoginEntity.token,
      _desc!,
      newBytes,
      fileName,
      _onSuccess,
    );
  }

  Future _showSnackbar(String? msg) async {
    final ScaffoldMessengerState scaffoldMessengerState =
        ScaffoldMessenger.of(context);
    scaffoldMessengerState.showSnackBar(
      SnackBar(content: Text(msg ?? "Error uploading story")),
    );
  }

  _onGalleryView() async {
    final ImagePicker picker = ImagePicker();
    final provider = context.read<StoryNotifier>();

    final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    final isLinux = defaultTargetPlatform == TargetPlatform.linux;

    if (isMacOS || isLinux) return;

    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      provider.setImagePath(pickedFile.path);
      provider.setImageFile(pickedFile);
    }
  }

  _onCameraView() async {
    final ImagePicker picker = ImagePicker();
    final provider = context.read<StoryNotifier>();

    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isiOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isNotMobile = !(isAndroid || isiOS);
    if (isNotMobile) return;

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      provider.setImagePath(pickedFile.path);
      provider.setImageFile(pickedFile);
    }
  }

  Widget _showImage() {
    final imagePath = context.read<StoryNotifier>().imagePath;
    return kIsWeb
        ? Image.network(
            imagePath.toString(),
            fit: BoxFit.contain,
          )
        : SizedBox(
            height: 300,
            width: double.infinity,
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Image.file(
                File(imagePath.toString()),
                fit: BoxFit.fill,
              ),
            ));
  }
}