import 'package:flutter/material.dart';
import 'package:fstory/presentation/widgets/loading.dart';
import 'package:fstory/presentation/widgets/response_message.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/story_notifier.dart';

class DetailPage extends StatefulWidget {
  final String storyId;
  final String token;

  const DetailPage({super.key, required this.storyId, required this.token});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final LatLng _initLocation = const LatLng(-2.44565, 117.8888);
  late GoogleMapController mapController;
  late Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Detail Page")),
        body: Center(
          child: Consumer<StoryNotifier>(
            builder: (ctx, provider, _) {
              if (provider.getStoryDetailState == GetStoryDetailState.loading) {
                return const Loading();
              } else if (provider.getStoryDetailState ==
                  GetStoryDetailState.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      provider.storyDetailEntity?.lat != null
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height / 3,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                    target: _initLocation, zoom: 4),
                                markers: markers,
                                onMapCreated: (controller) {
                                  setState(() {
                                    mapController = controller;
                                  });
                                  provider.storyDetailEntity?.lat != null
                                      ? _setStoryMarker(LatLng(
                                          provider.storyDetailEntity!.lat ?? 0,
                                          provider.storyDetailEntity!.lon ?? 0))
                                      : null;
                                },
                              ))
                          : const SizedBox(),
                      const SizedBox(
                        height: 16,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height / 3,
                          width: double.infinity,
                          child: Image.network(
                            provider.storyDetailEntity?.photoUrl ?? '',
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return const Loading();
                              }
                            },
                            errorBuilder: (_, __, ___) {
                              return Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: MediaQuery.of(context).size.width * 0.8,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.storyDetailEntity?.name ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                          ),
                          Text(
                            timeago.format(
                                provider.storyDetailEntity?.createdAt ??
                                    DateTime.now(),
                                locale: 'en'),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        provider.storyDetailEntity?.description ?? "",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        maxLines: 3,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w300, fontSize: 12),
                      ),
                    ],
                  ),
                );
              } else if (provider.getStoryDetailState ==
                  GetStoryDetailState.noData) {
                return const ResponseMessage(
                  image: 'assets/images/no-data.png',
                  message: 'No Data',
                );
              } else if (provider.getStoryDetailState ==
                  GetStoryDetailState.error) {
                return ResponseMessage(
                  image: 'assets/images/error.png',
                  message: "Error...\n${provider.errorMsg}",
                );
              } else {
                return const Loading();
              }
            },
          ),
        ));
  }

  void _setStoryMarker(LatLng latLng) async {
    final info =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    final place = info[0];
    final street = place.street ?? "street";
    final address = '${place.subLocality}, ${place.country}';
    setState(() {
      markers.clear();
      markers.add(Marker(
          markerId: const MarkerId("source"),
          position: LatLng(latLng.latitude, latLng.longitude),
          infoWindow: InfoWindow(title: street, snippet: address)));
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 13),
      );
    });
  }
}
