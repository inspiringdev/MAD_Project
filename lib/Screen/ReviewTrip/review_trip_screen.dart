import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sawaari/Components/ink_well_custom.dart';
import 'package:sawaari/theme/style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../app_router.dart';

class ReviewTripScreen extends StatefulWidget {
  @override
  _ReviewTripScreenState createState() => _ReviewTripScreenState();
}

class _ReviewTripScreenState extends State<ReviewTripScreen> {
  MapboxMap? mapboxMap;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Point currentLocation = Point(coordinates: Position(-95.630775, 39.065747));
  Map<String, PointAnnotation> annotations = <String, PointAnnotation>{};
  String? selectedAnnotation;
  Map<String, PolylineAnnotation> polylines = <String, PolylineAnnotation>{};
  String? selectedPolyline;
  double? ratingScore;

  void _onMapCreated(MapboxMap controller) {
    mapboxMap = controller;
    _addAnnotation();
    // Move camera to current location
    _moveCamera();
  }

  Future<void> _addAnnotation() async {
    if (mapboxMap == null) return;

    try {
      // Load and add the custom image
      final imageData = await _loadImageFromAsset('assets/image/marker/ic_pick_96.png');
      await mapboxMap!.style.addStyleImage('trip-marker', 1.0, MbxImage(
        width: 96,
        height: 96,
        data: imageData,
      ), false, [], [], null);

      // Create point annotation manager
      final annotationManager = await mapboxMap!.annotations.createPointAnnotationManager();

      // Create the annotation
      final annotation = await annotationManager.create(
        PointAnnotationOptions(
          geometry: currentLocation,
          iconImage: 'trip-marker',
          iconSize: 1.0,
        ),
      );

      setState(() {
        annotations['trip_marker'] = annotation;
      });
    } catch (e) {
      debugPrint('Error adding annotation: $e');
    }
  }

  Future<Uint8List> _loadImageFromAsset(String assetName) async {
    final ByteData data = await DefaultAssetBundle.of(context).load(assetName);
    return data.buffer.asUint8List();
  }

  void _moveCamera() {
    mapboxMap?.easeTo(
      CameraOptions(
        center: currentLocation,
        zoom: 11.0,
      ),
      MapAnimationOptions(duration: 1000, startDelay: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: whiteColor,
        title: Text('Review your trip', style: TextStyle(color: blackColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: blackColor),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRoute.homeScreen);
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
        child: SizedBox(
          width: screenSize.width,
          height: 50.0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
            ),
            child: Text('Submit Review', style: headingWhite),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoute.homeScreen);
            },
          ),
        ),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overScroll) {
          overScroll.disallowIndicator();
          return false;
        },
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(height: screenSize.height * 0.35),
                    Container(
                      height: screenSize.height * 0.25,
                      child: mapView(context),
                    ),
                    Positioned(
                      top: screenSize.height * 0.18,
                      child: Material(
                        elevation: 10.0,
                        color: Colors.white,
                        shape: CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.all(2.0),
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: Hero(
                              tag: "avatar_profile",
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.transparent,
                                backgroundImage: CachedNetworkImageProvider(
                                  "https://source.unsplash.com/300x300/?portrait",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                InkWellCustom(
                  onTap: () {
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: buildContent(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget mapView(BuildContext context) {
    return SizedBox(
      height: 215.0,
      child: MapWidget(
        key: ValueKey("mapWidget"),
        onMapCreated: _onMapCreated,
        styleUri: MapboxStyles.MAPBOX_STREETS,
        cameraOptions: CameraOptions(
          center: currentLocation,
          zoom: 11.0,
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          "John Wick",
          style: TextStyle(
            fontSize: 14,
            color: blackColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "Huyndai(TX32-33567)",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 10),
        RatingBar.builder(
          initialRating: 4,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 30.0,
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              ratingScore = rating;
            });
            print(rating);
          },
        ),
        SizedBox(height: 10),
        Text(
          "How is your trip?",
          style: TextStyle(
            fontSize: 16,
            color: blackColor,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5.0),
        Text(
          "Your feedback will help improve driving experience",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Container(
          padding: EdgeInsets.only(top: 15.0, left: 20, right: 20),
          child: SizedBox(
            height: 100.0,
            child: TextField(
              style: TextStyle(
                color: Colors.black38,
                fontSize: 14.0,
              ),
              decoration: InputDecoration(
                hintText: "Additional comments...",
                hintStyle: TextStyle(
                  color: Colors.black38,
                  fontSize: 14.0,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
              ),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              onChanged: (String value) {},
            ),
          ),
        ),
      ],
    );
  }
}