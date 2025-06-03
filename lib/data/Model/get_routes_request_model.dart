import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../data/equatable.dart';

part 'get_routes_request_model.g.dart';

@JsonSerializable()
class GetRoutesRequestModel extends Equatable {
  @JsonKey(ignore: true)
  Point? fromLocation;

  @JsonKey(name: 'origin')
  String origin;

  @JsonKey(ignore: true)
  Point? toLocation;

  @JsonKey(name: 'destination')
  String destination;

  @JsonKey(name: 'mode')
  String mode;

  GetRoutesRequestModel({
    this.fromLocation,
    required this.origin,
    this.toLocation,
    required this.destination,
    this.mode = "driving",
  }) : super([origin, destination, mode]) {
    // Convert fromLocation to origin string
    if (origin.isEmpty && fromLocation != null) {
      origin = "${fromLocation!.coordinates.lng},${fromLocation!.coordinates.lat}";
    }

    // Convert toLocation to destination string
    if (destination.isEmpty && toLocation != null) {
      destination = "${toLocation!.coordinates.lng},${toLocation!.coordinates.lat}";
    }

    // Parse origin string into fromLocation
    if (origin.isNotEmpty && fromLocation == null) {
      final data = origin.split(',');
      if (data.length == 2) {
        fromLocation = Point(
          coordinates: Position(
            double.tryParse(data[0]) ?? 0.0, // lng
            double.tryParse(data[1]) ?? 0.0, // lat
          ),
        );
      }
    }

    // Parse destination string into toLocation
    if (destination.isNotEmpty && toLocation == null) {
      final data = destination.split(',');
      if (data.length == 2) {
        toLocation = Point(
          coordinates: Position(
            double.tryParse(data[0]) ?? 0.0, // lng
            double.tryParse(data[1]) ?? 0.0, // lat
          ),
        );
      }
    }
  }

  factory GetRoutesRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GetRoutesRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetRoutesRequestModelToJson(this);
}