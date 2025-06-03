import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sawaari/Blocs/place_bloc.dart';
import 'package:sawaari/Components/select_address_view.dart';
import 'package:sawaari/Model/map_type_model.dart';
import 'package:sawaari/Model/place_model.dart';
import 'package:sawaari/Screen/Menu/menu_screen.dart';
import 'package:sawaari/Screen/SearchAddress/search_address_screen.dart';
import 'package:sawaari/theme/style.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'select_map_type.dart';

class HomeView extends StatefulWidget {
  final PlaceBloc? placeBloc;
  HomeView({this.placeBloc});
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final String screenName = "HOME";
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  String? _placemark = '';
  bool checkPlatform = Platform.isIOS;
  bool nightMode = false;
  VoidCallback? showPersBottomSheetCallBack;
  List<MapTypeModel> sampleData = <MapTypeModel>[];
  PersistentBottomSheetController? _controller;
  String _currentMapStyle = MapboxStyles.MAPBOX_STREETS; // Default style

  geo.Position? currentLocation;
  geo.Position? _lastKnownPosition;
  final geo.Geolocator _locationService = geo.Geolocator();
  PermissionStatus? permission;
  bool isEnabledLocation = false;

  @override
  void initState() {
    super.initState();

    // Initialize Mapbox
    MapboxOptions.setAccessToken('YOUR_MAPBOX_ACCESS_TOKEN');

    fetchLocation();
    showPersBottomSheetCallBack = _showBottomSheet;
    sampleData.add(MapTypeModel(1, true, 'assets/style/maptype_nomal.png', 'Normal', MapboxStyles.MAPBOX_STREETS));
    sampleData.add(MapTypeModel(2, false, 'assets/style/maptype_silver.png', 'Silver', MapboxStyles.LIGHT));
    sampleData.add(MapTypeModel(3, false, 'assets/style/maptype_dark.png', 'Dark', MapboxStyles.DARK));
    sampleData.add(MapTypeModel(4, false, 'assets/style/maptype_night.png', 'Night', MapboxStyles.SATELLITE_STREETS));
    sampleData.add(MapTypeModel(5, false, 'assets/style/maptype_netro.png', 'Netro', MapboxStyles.SATELLITE));
    sampleData.add(MapTypeModel(6, false, 'assets/style/maptype_aubergine.png', 'Aubergine', MapboxStyles.OUTDOORS));
  }

  Future<void> _initLastKnownLocation() async {
    geo.Position? position;
    try {
      position = await geo.Geolocator.getLastKnownPosition();
    } catch (e) {
      position = null;
    }
    if (!mounted) return;
    _lastKnownPosition = position;
  }

  Future<void> checkPermission() async {
    isEnabledLocation = await Permission.location.serviceStatus.isEnabled;
  }

  void fetchLocation() {
    checkPermission().then((_) {
      if (isEnabledLocation) {
        _initCurrentLocation();
      }
    });
  }

  Future<void> _initCurrentLocation() async {
    try {
      currentLocation = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.bestForNavigation);
      if (currentLocation != null) {
        moveCameraToMyLocation();
        widget.placeBloc?.getCurrentLocation(Place(
          name: _placemark ?? '',
          formattedAddress: "",
          lat: currentLocation?.latitude,
          lng: currentLocation?.longitude,
        ));
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void moveCameraToMyLocation() {
    if (_mapboxMap != null && currentLocation != null) {
      _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(
              currentLocation!.longitude,
              currentLocation!.latitude,
            ),
          ),
          zoom: 14.0,
        ),
        MapAnimationOptions(duration: 2000, startDelay: 0),
      );
    }
  }

  void getLocationName(double lat, double lng) async {
    // Placeholder for location name fetching
    // Note: Mapbox Geocoding API can be used here for reverse geocoding
    widget.placeBloc?.getCurrentLocation(Place(
      name: _placemark ?? '',
      formattedAddress: "",
      lat: lat,
      lng: lng,
    ));
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _pointAnnotationManager = await _mapboxMap!.annotations.createPointAnnotationManager();

    if (currentLocation != null) {
      await _addMarker(currentLocation!.latitude, currentLocation!.longitude);
    }
  }

  void _onCameraIdle() {
    // Get current camera position and update location
    _mapboxMap?.getCameraState().then((cameraState) {
      if (cameraState.center.coordinates.length >= 2) {
        double lat = (cameraState.center.coordinates[1] as num).toDouble(); // latitude
        double lng = (cameraState.center.coordinates[0] as num).toDouble(); // longitude
        getLocationName(lat, lng);
      }
    });
  }

  Future<void> _addMarker(double lat, double lng) async {
    if (_pointAnnotationManager != null) {
      // Load marker image
      final ByteData bytes = await rootBundle.load(
        checkPlatform
            ? 'assets/image/marker/ic_pick_48.png'
            : 'assets/image/marker/ic_pick_96.png',
      );
      final Uint8List imageData = bytes.buffer.asUint8List();

      // Create point annotation
      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        image: imageData,
        iconSize: checkPlatform ? 0.5 : 1.0,
      );

      await _pointAnnotationManager!.create(pointAnnotationOptions);
    }
  }

  void changeMapType(int id, String? styleId) {
    setState(() {
      nightMode = styleId != null;
      _currentMapStyle = styleId ?? MapboxStyles.MAPBOX_STREETS;
    });

    // Update map style
    if (_mapboxMap != null) {
      _mapboxMap!.loadStyleURI(_currentMapStyle);
    }
  }

  void _showBottomSheet() async {
    setState(() {
      showPersBottomSheetCallBack = null;
    });
    _controller = await _scaffoldKey.currentState?.showBottomSheet((context) {
      return Container(
        height: 300.0,
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text("Map type", style: heading18Black),
                  ),
                  Container(
                    child: IconButton(
                      icon: Icon(Icons.close, color: blackColor),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  )
                ],
              ),
              Expanded(
                child: GridView.builder(
                  itemCount: sampleData.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      highlightColor: Colors.red,
                      splashColor: Colors.blueAccent,
                      onTap: () {
                        _closeModalBottomSheet();
                        sampleData.forEach((element) => element.isSelected = false);
                        sampleData[index].isSelected = true;
                        changeMapType(sampleData[index].id, sampleData[index].fileName);
                      },
                      child: SelectMapTypeView(sampleData[index]),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  void _closeModalBottomSheet() {
    if (_controller != null) {
      _controller?.close();
      _controller = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuScreens(activeScreenName: screenName),
      body: Stack(
        children: <Widget>[
          MapWidget(
            key: ValueKey("mapWidget"),
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(
                  currentLocation?.longitude ?? -122.677433,
                  currentLocation?.latitude ?? 45.521563,
                ),
              ),
              zoom: 11.0,
            ),
            styleUri: _currentMapStyle,
            onMapCreated: _onMapCreated,
            onCameraChangeListener: (cameraChangedEventData) {
              // Handle camera changes here if needed
              _onCameraIdle();
            },
          ),
          Positioned(
            bottom: 30.0,
            left: 20.0,
            right: 20.0,
            child: Container(
              height: 150.0,
              child: SelectAddress(
                fromAddress: widget.placeBloc?.formLocation?.name,
                toAddress: "To address",
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SearchAddressScreen(),
                    fullscreenDialog: true,
                  ));
                },
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            right: 20,
            child: GestureDetector(
              onTap: () {
                fetchLocation();
              },
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(100.0)),
                ),
                child: Icon(Icons.my_location, size: 20.0, color: blackColor),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 10,
            child: GestureDetector(
              onTap: () {
                _showBottomSheet();
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.white,
                ),
                child: Icon(Icons.layers, color: blackColor),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 10,
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(100.0)),
                ),
                child: Icon(Icons.menu, color: blackColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapboxMap?.dispose();
    super.dispose();
  }
}