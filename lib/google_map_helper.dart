import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class GMapViewHelper {
  GMapViewHelper();

  Widget buildMapView({
    required BuildContext context,
    required String accessToken,
    required void Function(MapboxMap) onMapCreated,
    void Function(MapContentGestureContext)? onMapTap,
    Point? initialLocation,
  }) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: MapWidget(
        key: const ValueKey("mapWidget"),
        onMapCreated: onMapCreated,
        onTapListener: onMapTap,
        styleUri: MapboxStyles.MAPBOX_STREETS,
        cameraOptions: CameraOptions(
          center: initialLocation ?? Point(coordinates: Position(0, 0)),
          zoom: 12.0,
        ),
      ),
    );
  }

  static Future<PointAnnotation?> addMarker({
    required MapboxMap controller,
    required String markerId,
    required Point position,
    String iconImage = 'marker-icon',
    String? text,
    Function(String)? onTap,
  }) async {
    try {
      final pointAnnotationManager = await controller.annotations.createPointAnnotationManager();

      final pointAnnotation = PointAnnotationOptions(
        geometry: position,
        iconImage: iconImage,
        textField: text,
        textOffset: [0.0, -2.0],
      );

      final createdAnnotation = await pointAnnotationManager.create(pointAnnotation);

      if (onTap != null) {
        pointAnnotationManager.addOnPointAnnotationClickListener(
            _PointAnnotationClickListener(onTap: () => onTap(markerId))
        );
      }

      return createdAnnotation;
    } catch (e) {
      debugPrint('Error adding marker: $e');
      return null;
    }
  }

  static Future<PolylineAnnotation?> addPolyline({
    required MapboxMap controller,
    required String polylineId,
    required List<Point> points,
    int lineColor = 0xFF669df6,
    double lineWidth = 6.0,
    double lineOpacity = 1.0,
  }) async {
    try {
      final polylineAnnotationManager = await controller.annotations.createPolylineAnnotationManager();

      final polylineAnnotation = PolylineAnnotationOptions(
        geometry: LineString(coordinates: points.map((point) => point.coordinates).toList()),
        lineColor: lineColor,
        lineWidth: lineWidth,
        lineOpacity: lineOpacity,
      );

      return await polylineAnnotationManager.create(polylineAnnotation);
    } catch (e) {
      debugPrint('Error adding polyline: $e');
      return null;
    }
  }

  Future<void> cameraMove({
    required MapboxMap mapController,
    required Point fromLocation,
    required Point toLocation,
    double padding = 120.0,
  }) async {
    final bounds = CoordinateBounds(
      southwest: Point(
        coordinates: Position(
          fromLocation.coordinates.lng < toLocation.coordinates.lng
              ? fromLocation.coordinates.lng
              : toLocation.coordinates.lng,
          fromLocation.coordinates.lat < toLocation.coordinates.lat
              ? fromLocation.coordinates.lat
              : toLocation.coordinates.lat,
        ),
      ),
      northeast: Point(
        coordinates: Position(
          fromLocation.coordinates.lng > toLocation.coordinates.lng
              ? fromLocation.coordinates.lng
              : toLocation.coordinates.lng,
          fromLocation.coordinates.lat > toLocation.coordinates.lat
              ? fromLocation.coordinates.lat
              : toLocation.coordinates.lat,
        ),
      ),
      infiniteBounds: false,
    );

    await mapController.easeTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            (fromLocation.coordinates.lng + toLocation.coordinates.lng) / 2,
            (fromLocation.coordinates.lat + toLocation.coordinates.lat) / 2,
          ),
        ),
        padding: MbxEdgeInsets(
            top: padding,
            left: padding,
            bottom: padding,
            right: padding
        ),
      ),
      MapAnimationOptions(duration: 1000, startDelay: 0),
    );
  }

  static CoordinateBounds boundsFromLocations(Point location1, Point location2) {
    return CoordinateBounds(
      southwest: Point(
        coordinates: Position(
          location1.coordinates.lng < location2.coordinates.lng
              ? location1.coordinates.lng
              : location2.coordinates.lng,
          location1.coordinates.lat < location2.coordinates.lat
              ? location1.coordinates.lat
              : location2.coordinates.lat,
        ),
      ),
      northeast: Point(
        coordinates: Position(
          location1.coordinates.lng > location2.coordinates.lng
              ? location1.coordinates.lng
              : location2.coordinates.lng,
          location1.coordinates.lat > location2.coordinates.lat
              ? location1.coordinates.lat
              : location2.coordinates.lat,
        ),
      ),
      infiniteBounds: false,
    );
  }

  static List<Point> decodePolyline(String encoded) {
    List<Point> points = [];
    int index = 0, len = encoded.length;
    double lat = 0, lng = 0;

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

      points.add(Point(
        coordinates: Position(lat / 1E5, lng / 1E5),
      ));
    }
    return points;
  }
}

class _PointAnnotationClickListener extends OnPointAnnotationClickListener {
  final VoidCallback onTap;

  _PointAnnotationClickListener({required this.onTap});

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    onTap();
  }
}