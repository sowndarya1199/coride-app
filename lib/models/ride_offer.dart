import 'package:maplibre_gl/maplibre_gl.dart';

class RideOffer {
  final String id;
  final String driverId;
  final int availableSeats;
  final List<LatLng> route; // polyline as waypoints
  final LatLng origin;
  final LatLng destination;
  final DateTime updatedAt;

  const RideOffer({
    required this.id,
    required this.driverId,
    required this.availableSeats,
    required this.route,
    required this.origin,
    required this.destination,
    required this.updatedAt,
  });
}


