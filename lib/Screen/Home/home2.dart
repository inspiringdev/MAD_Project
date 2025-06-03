import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'dart:math' show cos, sqrt, asin;

class HomeScreen2 extends StatefulWidget {
  @override
  _HomeScreen2State createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  final String screenName = "HOME2";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  CircleAnnotationManager? _circleAnnotationManager;
  Map<String, PointAnnotation> pointAnnotations = {};
  Map<String, CircleAnnotation> circleAnnotations = {};
  String? selectedCircle;
  geolocator.Position? _position;
  double? distance = 0;
  Point currentLocation = Point(
    coordinates: Position(-95.449974, 39.170655), // lng, lat
  );
  double _radius = 5000;

  List<Map<String, dynamic>> listDistance = [
    {"id": "1", "title": "5 km"},
    {"id": "2", "title": "10 km"},
    {"id": "3", "title": "15 km"}
  ];
  String selectedDistance = "1";

  List<Map<String, dynamic>> dataMarker = [
    {"id": "1", "lat": 39.170655, "lng": -95.449974},
    {"id": "2", "lat": 39.165576, "lng": -95.457672},
    {"id": "3", "lat": 39.155726, "lng": -95.429189},
    {"id": "4", "lat": 39.183142, "lng": -95.438454},
    {"id": "5", "lat": 39.153597, "lng": -95.385606},
    {"id": "6", "lat": 39.179682, "lng": -95.406882},
    {"id": "7", "lat": 39.150934, "lng": -95.524604},
  ];

  @override
  void initState() {
    super.initState();
    // Set Mapbox access token
    MapboxOptions.setAccessToken(
        'pk.eyJ1IjoidWJhaWQyMzA2MjAwNCIsImEiOiJjbWJnNWNrc2YwNGdtMmtzZzFnOGxuOXdoIn0.UDuNHWwIJHbqdxjEF3k8Nw');
    _getCurrentLocation();
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    _circleAnnotationManager = await mapboxMap.annotations.createCircleAnnotationManager();
    _mapboxMap?.setCamera(CameraOptions(
      center: currentLocation,
      zoom: 12,
    ));
    _addCircle();

    for (var marker in dataMarker) {
      distance = calculateDistance(
        currentLocation.coordinates.lat.toDouble(),
        currentLocation.coordinates.lng.toDouble(),
        (marker['lat'] as num).toDouble(),
        (marker['lng'] as num).toDouble(),
      );
      if (distance! * 1000 < _radius) {
        _addPointAnnotation(marker['id'], (marker['lat'] as num).toDouble(), (marker['lng'] as num).toDouble());
      }
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  void dispose() {
    _mapboxMap?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    geolocator.Position? position;
    try {
      position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.bestForNavigation,
      );
    } on PlatformException {
      position = null;
    }
    if (!mounted) return;
    setState(() {
      _position = position;
      if (position != null) {
        currentLocation = Point(
          coordinates: Position(position.longitude, position.latitude),
        );
      }
    });
  }
  Future<void> _createPointAnnotationImage() async {
    final imageData = await _loadImageFromAsset(
      Platform.isIOS
          ? 'assets/image/marker/car_top_48.png'
          : 'assets/image/marker/car_top_96.png',
    );
    final mbxImage = MbxImage(
      width: Platform.isIOS ? 48 : 96,
      height: Platform.isIOS ? 48 : 96,
      data: imageData,
    );
    await _mapboxMap?.style.addStyleImage(
      'car-marker',
      1.0,
      mbxImage, // Pass MbxImage
      false, // sdf: false for non-SDF images
      [], // stretchX
      [], // stretchY
      null,
    );
  }

  Future<Uint8List> _loadImageFromAsset(String assetName) async {
    final ByteData data = await DefaultAssetBundle.of(context).load(assetName);
    return data.buffer.asUint8List();
  }

  void _addPointAnnotation(String id, double lat, double lng) async {
    await _createPointAnnotationImage();
    final pointAnnotation = await _pointAnnotationManager?.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        iconImage: 'car-marker',
        iconSize: Platform.isIOS ? 0.5 : 1.0,
      ),
    );
    if (pointAnnotation != null) {
      setState(() {
        pointAnnotations[id] = pointAnnotation;
      });
    }
  }

  void _addCircle() async {
    // Get current zoom level
    final currentZoom = await _mapboxMap?.getCameraState().then((state) => state.zoom) ?? 12.0;

    // Scale radius based on zoom level (adjust multiplier as needed)
    double adjustedRadius = _radius * (1.0 / (1.0 + (14.0 - currentZoom))); // Smaller radius at higher zoom

    final circleAnnotation = await _circleAnnotationManager?.create(
      CircleAnnotationOptions(
        geometry: currentLocation,
        circleRadius: adjustedRadius, // Adjusted radius in meters
        circleColor: int.parse('0xFF87CEFA'),
        circleOpacity: 0.3,
        circleStrokeColor: int.parse('0xFF87CEFA'),
        circleStrokeWidth: 4.0,
        circleStrokeOpacity: 0.9,
      ),
    );
    if (circleAnnotation != null) {
      setState(() {
        circleAnnotations['circle_id'] = circleAnnotation;
      });
    }
  }

  Widget getListOptionDistance() {
    final List<Widget> choiceChips = listDistance.map<Widget>((value) {
      return Padding(
        padding: const EdgeInsets.all(3.0),
        child: ChoiceChip(
          key: ValueKey<String>(value['id'].toString()),
          labelStyle: const TextStyle(color: Colors.grey), // Replace with textGrey
          backgroundColor: Colors.grey[200], // Replace with greyColor2
          selectedColor: Colors.blue, // Replace with primaryColor
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          selected: selectedDistance == value['id'].toString(),
          label: Text(value['title']),
          onSelected: (bool check) {
            setState(() {
              selectedDistance = check ? value["id"].toString() : '';
              changeCircle(selectedDistance);
            });
          },
        ),
      );
    }).toList();
    return Wrap(children: choiceChips);
  }

  void changeCircle(String selectedCircle) async {
    if (selectedCircle == "1") {
      setState(() {
        _radius = 5000;
        _moveCamera(11.5);
      });
    } else if (selectedCircle == "2") {
      setState(() {
        _radius = 10000;
        _moveCamera(11.2);
      });
    } else if (selectedCircle == "3") {
      setState(() {
        _radius = 15000;
        _moveCamera(10.5);
      });
    }
    await _circleAnnotationManager?.deleteAll();
    circleAnnotations.clear();
    _addCircle();

    for (var marker in dataMarker) {
      distance = calculateDistance(
        currentLocation.coordinates.lat.toDouble(),
        currentLocation.coordinates.lng.toDouble(),
        (marker['lat'] as num).toDouble(),
        (marker['lng'] as num).toDouble(),
      );
      if (distance! * 1000 < _radius) {
        _addPointAnnotation(marker['id'], (marker['lat'] as num).toDouble(), (marker['lng'] as num).toDouble());
      } else {
        _remove(marker['id']);
      }
    }
  }

  void _remove(String id) async {
    if (pointAnnotations.containsKey(id)) {
      await _pointAnnotationManager?.delete(pointAnnotations[id]!);
      setState(() {
        pointAnnotations.remove(id);
      });
    }
  }

  void _moveCamera(double zoom) {
    _mapboxMap?.setCamera(CameraOptions(
      center: currentLocation,
      zoom: zoom,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(), // Replace with MenuScreens(activeScreenName: screenName),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            MapWidget(
              key: const ValueKey("mapWidget"),
              onMapCreated: _onMapCreated,
              cameraOptions: CameraOptions(
                center: currentLocation,
                zoom: 12,
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    centerTitle: true,
                    leading: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: getListOptionDistance(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}