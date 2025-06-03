import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sawaari/Blocs/place_bloc.dart';
import 'package:sawaari/Components/autoRotationMarker.dart' as rm;
import 'package:sawaari/Components/loading.dart';
import 'dart:typed_data';
import 'package:sawaari/Screen/Directions/screens/chat_screen/chat_screen.dart';
import 'package:sawaari/Screen/Directions/widgets/arriving_detail_widget.dart';
import 'package:sawaari/Screen/Directions/widgets/booking_detail_widget.dart';
import 'package:sawaari/app_router.dart';
import 'package:sawaari/data/Model/direction_model.dart';
import 'package:sawaari/theme/style.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Networking/Apis.dart';
import '../../data/Model/get_routes_request_model.dart';
import '../../google_map_helper.dart';
import 'widgets/select_service_widget.dart';

class DirectionsView extends StatefulWidget {
  final PlaceBloc placeBloc;
  DirectionsView({required this.placeBloc});

  @override
  _DirectionsViewState createState() => _DirectionsViewState();
}

class _DirectionsViewState extends State<DirectionsView> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Point> points = <Point>[];
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _polylineAnnotationManager;

  Map<String, PointAnnotation> pointAnnotations = <String, PointAnnotation>{};
  String? selectedPointAnnotation;

  Map<String, PolylineAnnotation> polylines = <String, PolylineAnnotation>{};
  int _lineIdCounter = 1;
  String? selectedLine;

  bool checkPlatform = Platform.isIOS;
  String? distance, duration;
  bool isLoading = false;
  bool isResult = false;
  Point? positionDriver;
  bool isComplete = false;
  final Apis apis = Apis();
  List<Routes?>? routesData;
  final GMapViewHelper _gMapViewHelper = GMapViewHelper();
  final PanelController panelController = PanelController();
  String? selectedService;

  @override
  void initState() {
    super.initState();
    // Set Mapbox access token
    MapboxOptions.setAccessToken(
        'pk.eyJ1IjoidWJhaWQyMzA2MjAwNCIsImEiOiJjbWJnNWNrc2YwNGdtMmtzZzFnOGxuOXdoIn0.UDuNHWwIJHbqdxjEF3k8Nw');
    print(widget.placeBloc.formLocation);
    print(widget.placeBloc.locationSelect);
    addMarkers();
    getRouter();
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    _polylineAnnotationManager = await mapboxMap.annotations.createPolylineAnnotationManager();
  }

  @override
  void dispose() {
    _mapboxMap?.dispose();
    super.dispose();
  }

  Future<void> _addMarkerImage() async {
    final markerImageData = await _loadImageFromAsset(
      Platform.isIOS ? 'assets/image/marker/marker-icon.png' : 'assets/image/marker/marker-icon.png',
    );
    final markerMbxImage = MbxImage(
      width: 48, // Adjust based on your image size
      height: 48,
      data: markerImageData,
    );
    await _mapboxMap?.style.addStyleImage(
      'marker-icon',
      1.0,
      markerMbxImage,
      false,
      [],
      [],
      null,
    );

    final carImageData = await _loadImageFromAsset(
      Platform.isIOS ? 'assets/image/marker/car-icon.png' : 'assets/image/marker/car-icon.png',
    );
    final carMbxImage = MbxImage(
      width: 48, // Adjust based on your image size
      height: 48,
      data: carImageData,
    );
    await _mapboxMap?.style.addStyleImage(
      'car-icon',
      1.0,
      carMbxImage,
      false,
      [],
      [],
      null,
    );
  }

  Future<Uint8List> _loadImageFromAsset(String assetName) async {
    final ByteData data = await DefaultAssetBundle.of(context).load(assetName);
    return data.buffer.asUint8List();
  }

  Future<void> addMarkers() async {
    await _addMarkerImage();

    // Add from marker
    final fromAnnotation = await _pointAnnotationManager?.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            widget.placeBloc.formLocation?.lng ?? 0,
            widget.placeBloc.formLocation?.lat ?? 0,
          ),
        ),
        iconImage: 'marker-icon',
        textField: widget.placeBloc.formLocation?.name ?? '',
        textOffset: [0, -2],
      ),
    );

    // Add to marker
    final toAnnotation = await _pointAnnotationManager?.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            widget.placeBloc.locationSelect?.lng ?? 0,
            widget.placeBloc.locationSelect?.lat ?? 0,
          ),
        ),
        iconImage: 'marker-icon',
        textField: widget.placeBloc.locationSelect?.name ?? '',
        textOffset: [0, -2],
      ),
    );

    if (fromAnnotation != null && toAnnotation != null) {
      setState(() {
        pointAnnotations['from'] = fromAnnotation;
        pointAnnotations['to'] = toAnnotation;
      });
    }
  }

  void getRouter() async {
    final String lineIdVal = 'line_id_$_lineIdCounter';
    polylines.clear();

    Point fromLocation = Point(
      coordinates: Position(
        widget.placeBloc.formLocation?.lng ?? 0,
        widget.placeBloc.formLocation?.lat ?? 0,
      ),
    );
    Point toLocation = Point(
      coordinates: Position(
        widget.placeBloc.locationSelect?.lng ?? 0,
        widget.placeBloc.locationSelect?.lat ?? 0,
      ),
    );

    List<Routes?>? router;
    await apis.getRoutes(
      getRoutesRequest: GetRoutesRequestModel(
        fromLocation: fromLocation,
        toLocation: toLocation,
        mode: "driving",
        origin: '',
        destination: '',
      ),
    ).then((data) {
      if (data != null && data.result != null && data.result!.routes != null) {
        router = data.result!.routes;
        routesData = data.result!.routes;
      }
    }).catchError((error) {
      print("GetRoutesRequest > $error");
    });

    if (routesData != null && routesData!.isNotEmpty) {
      final firstRoute = routesData!.first;
      if (firstRoute != null && firstRoute.legs != null && firstRoute.legs!.isNotEmpty) {
        final firstLeg = firstRoute.legs!.first;
        distance = firstLeg.distance?.text ?? 'Unknown';
        duration = firstLeg.duration?.text ?? 'Unknown';
      } else {
        distance = 'Unknown';
        duration = 'Unknown';
      }
    } else {
      distance = 'Unknown';
      duration = 'Unknown';
    }

    if (router != null && router!.isNotEmpty && router![0] != null && router![0]!.overviewPolyline != null && router![0]!.overviewPolyline!.points != null){
      List<Point> coordinates = _decodePolyline(router![0]!.overviewPolyline!.points!);

      final polyline = await _polylineAnnotationManager?.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: coordinates.map((p) => p.coordinates).toList()),
          lineColor: int.parse('0xFF3b85f5'),
          lineWidth: 5.0,
          lineOpacity: 0.8,
        ),
      );

      if (polyline != null) {
        setState(() {
          polylines[lineIdVal] = polyline;
          _lineIdCounter++;
        });
      }
    }

    setState(() {});
    if (_mapboxMap != null) {
      _gMapViewHelper.cameraMove(
        mapController: _mapboxMap!,
        fromLocation: fromLocation,
        toLocation: toLocation,
      );
    }
  }
  List<Point> _decodePolyline(String encoded) {
    List<Point> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(Point(coordinates: Position(lng / 1E5, lat / 1E5)));
    }
    return points;
  }

  /// Real-time test of driver's location
  double? valueRotation;
  void runTrackingDriver(List<Point> _listPosition) {
    int count = 1;
    int two = count;
    const timeRequest = Duration(seconds: 2);
    Timer.periodic(timeRequest, (Timer t) {
      Point positionDriverBefore = _listPosition[two - 1];
      positionDriver = _listPosition[count++];
      print(count);

      valueRotation = rm.calculateangle(
        positionDriverBefore.coordinates.lat.toDouble(),
        positionDriverBefore.coordinates.lng.toDouble(),
        positionDriver?.coordinates.lat.toDouble() ?? 0.0,
        positionDriver?.coordinates.lng.toDouble() ?? 0.0,
      );

      print(valueRotation);
      addMarkersDriver(positionDriver!);
      _mapboxMap?.setCamera(
        CameraOptions(
          center: positionDriver,
          zoom: 15.0,
        ),
      );
      if (count == _listPosition.length) {
        setState(() {
          t.cancel();
          isComplete = true;
          showDialog(context: context, builder: (context) => dialogInfo());
        });
      }
    });
  }

  Future<void> addMarkersDriver(Point _position) async {
    await _pointAnnotationManager?.deleteAll();
    pointAnnotations.clear();

    final driverAnnotation = await _pointAnnotationManager?.create(
      PointAnnotationOptions(
        geometry: _position,
        iconImage: 'car-icon',
        iconSize: 1.5,
        iconRotate: valueRotation ?? 0,
      ),
    );

    if (driverAnnotation != null) {
      setState(() {
        pointAnnotations['driver'] = driverAnnotation;
      });
    }
  }

  Widget dialogOption() {
    return AlertDialog(
      title: const Text("Option"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      content: TextFormField(
        style: textStyle,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: "Ex: I'm standing in front of the bus stop...",
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget dialogPromoCode() {
    return AlertDialog(
      title: const Text("Promo Code"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      content: TextFormField(
        style: textStyle,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: "Enter promo code",
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Confirm'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void handSubmit() {
    print("Submit");
    setState(() {
      isLoading = true;
    });
    Timer(const Duration(seconds: 5), () {
      setState(() {
        isLoading = false;
        isResult = true;
      });
    });
  }

  Widget dialogInfo() {
    return AlertDialog(
      title: const Text("Information"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      content: const Text('Trip completed. Review your trip now!.'),
      actions: <Widget>[
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(AppRoute.reviewTripScreen);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        buildContent(context),
        Positioned(
          left: 18,
          top: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                centerTitle: true,
                leading: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed(AppRoute.homeScreen);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white,
                    ),
                    child: Icon(Icons.arrow_back_ios, color: blackColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildContent(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    print(selectedService);

    return SlidingUpPanel(
      controller: panelController,
      maxHeight: screenSize.height * 0.8,
      minHeight: 0.0,
      parallaxEnabled: false,
      parallaxOffset: 0.8,
      backdropEnabled: false,
      renderPanelSheet: false,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15.0),
        topRight: Radius.circular(15.0),
      ),
      body: Stack(
        children: <Widget>[
          MapWidget(
            key: const ValueKey("mapWidget"),
            onMapCreated: _onMapCreated,
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(
                  widget.placeBloc.locationSelect?.lng ?? 0,
                  widget.placeBloc.locationSelect?.lat ?? 0,
                ),
              ),
              zoom: 13,
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Material(
              elevation: 10.0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: isLoading
                  ? searchDriver(context)
                  : isResult
                  ? ArrivingDetail(
                onTapCall: () {
                  launchUrl(Uri.parse('tel:+1 555 010 999'));
                },
                onTapChat: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(),
                      fullscreenDialog: true,
                    ),
                  );
                },
                onTapCancel: () {
                  Navigator.of(context).pushNamed(AppRoute.cancellationReasonsScreen);
                },
              )
                  : BookingDetailWidget(
                bookingSubmit: handSubmit,
                panelController: panelController,
                distance: distance ?? '',
                duration: duration ?? '',
                onTapOptionMenu: () =>
                    showDialog(context: context, builder: (context) => dialogOption()),
                onTapPromoMenu: () =>
                    showDialog(context: context, builder: (context) => dialogPromoCode()),
              ),
            ),
          ),
        ],
      ),
      panel: SelectServiceWidget(
        serviceSelected: selectedService ?? '',
        panelController: panelController,
      ),
    );
  }

  Widget searchDriver(BuildContext context) {
    return Container(
      height: 270.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          LoadingBuilder(),
          const SizedBox(height: 20),
          Text(
            'Searching for a driver',
            style: TextStyle(
              fontSize: 18,
              color: greyColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}