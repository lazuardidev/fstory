import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:{{appName.snakeCase()}}/common/styles.dart';
import 'package:{{appName.snakeCase()}}/presentation/widgets/btn_primary.dart';
import 'package:{{appName.snakeCase()}}/presentation/widgets/loading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:{{appName.snakeCase()}}/domain/entities/login_entity.dart';
import 'package:{{appName.snakeCase()}}/presentation/providers/story_notifier.dart';
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
  bool? _isLocation = false;
  bool _isCustomLocation = false;
  final LatLng _initLocation = const LatLng(-7.4294398, 109.8589577);
  late GoogleMapController mapController;
  LatLng? _customStoryLocation;
  late final Set<Marker> markers = {};

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
              height: MediaQuery.of(context).size.height / 3,
              child: GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: _initLocation, zoom: 6),
                onMapCreated: (controller) {
                  setState(() {
                    mapController = controller;
                  });
                },
                onLongPress: (LatLng latLng) {
                  setState(() {
                    _isCustomLocation = true;
                  });
                  _onSetMarker(latLng, _isCustomLocation);
                },
                markers: markers,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
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
            Row(
              children: [
                Checkbox(
                  value: _isLocation,
                  onChanged: (value) {
                    _onCheckCurrentLocation(value);
                  },
                ),
                Text(
                  "Use current location",
                  style: Theme.of(context).textTheme.bodyMedium,
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
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showSnackbar("Success upload story");
                    context.read<StoryNotifier>().clearPreviousStory();
                    context
                        .read<StoryNotifier>()
                        .refreshListStory(widget.userLoginEntity.token);
                    widget.isBackToHomePage();
                  });
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
      markers.isEmpty
          ? null
          : LatLng(markers.first.position.latitude,
              markers.first.position.longitude),
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
            height: MediaQuery.of(context).size.height / 3,
            width: double.infinity,
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Image.file(
                File(imagePath.toString()),
                fit: BoxFit.fill,
              ),
            ),
          );
  }

  void _onCheckCurrentLocation(bool? value) {
    setState(() {
      markers.clear();
      _isLocation = value;
      _isCustomLocation = false;
    });
    if (value == null || value == false) {
      setState(() {
        markers.clear();
      });
    } else {
      Future.microtask(
        () async {
          final locationPermission =
              await context.read<StoryNotifier>().askLocationPermission();
          if (!locationPermission) {
            setState(() {
              _isLocation = false;
            });
          } else {
            Position? userCurrentLocation;
            userCurrentLocation = await _determinePosition();
            setState(() {
              _customStoryLocation = userCurrentLocation != null
                  ? LatLng(userCurrentLocation.latitude,
                      userCurrentLocation.longitude)
                  : null;
            });
            _customStoryLocation != null
                ? _onSetMarker(
                    LatLng(userCurrentLocation.latitude,
                        userCurrentLocation.longitude),
                    _isCustomLocation)
                : null;
          }
        },
      );
    }
  }

  void _onSetMarker(LatLng latLng, bool isCustomLocation) async {
    final info =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    final place = info[0];
    final street = place.street ?? "street";
    final address =
        '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    final marker = Marker(
        markerId: const MarkerId("userLocation"),
        position: latLng,
        infoWindow: InfoWindow(title: "Location: $street", snippet: address));
    setState(() {
      markers.clear();
      markers.add(marker);
      isCustomLocation ? _isLocation = false : null;
    });
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 13),
    );
  }

  Future<Position> _determinePosition() async {
    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
