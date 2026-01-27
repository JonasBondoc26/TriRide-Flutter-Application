import 'package:google_maps_flutter/google_maps_flutter.dart';

class Driver {
  final String id;
  final String name;
  final String plateNumber;
  final double rating;
  final String imageUrl;
  final double distance;
  final int estimatedTime;
  final double fare;
  final LatLng location;

  Driver({
    required this.id,
    required this.name,
    required this.plateNumber,
    required this.rating,
    required this.imageUrl,
    required this.distance,
    required this.estimatedTime,
    required this.fare,
    required this.location,
  });
}