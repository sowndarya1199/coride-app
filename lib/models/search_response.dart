import 'package:maplibre_gl/maplibre_gl.dart';

class SearchResponse {
  final String searchId;
  final List<BackendRideMatch> matches;
  final DateTime expiresAt;
  final String? errorMessage;

  const SearchResponse({
    required this.searchId,
    required this.matches,
    required this.expiresAt,
    this.errorMessage,
  });

  factory SearchResponse.fromMap(Map<String, dynamic> map) {
    return SearchResponse(
      searchId: map['search_id'] ?? '',
      matches: (map['matches'] as List<dynamic>? ?? [])
          .map((m) => BackendRideMatch.fromMap(m))
          .toList(),
      expiresAt: DateTime.parse(map['expires_at'] ?? DateTime.now().add(Duration(minutes: 5)).toIso8601String()),
      errorMessage: map['error_message'],
    );
  }
}

class BackendRideMatch {
  final String driverId;
  final String driverName;
  final String vehicleType;
  final int availableSeats;
  final double priceEstimate;
  final int etaMinutes;
  final double matchScore;
  final LatLng pickupLocation;
  final LatLng dropoffLocation;
  final List<LatLng> routePolyline;
  final String clusterId;
  final double detourDistance;
  final double pathOverlapPercentage;

  const BackendRideMatch({
    required this.driverId,
    required this.driverName,
    required this.vehicleType,
    required this.availableSeats,
    required this.priceEstimate,
    required this.etaMinutes,
    required this.matchScore,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.routePolyline,
    required this.clusterId,
    required this.detourDistance,
    required this.pathOverlapPercentage,
  });

  factory BackendRideMatch.fromMap(Map<String, dynamic> map) {
    final route = (map['route_polyline'] as List<dynamic>? ?? [])
        .map((p) => LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()))
        .toList();
    
    final pickup = map['pickup_location'] as Map<String, dynamic>? ?? {'lat': 0.0, 'lng': 0.0};
    final dropoff = map['dropoff_location'] as Map<String, dynamic>? ?? {'lat': 0.0, 'lng': 0.0};
    
    return BackendRideMatch(
      driverId: map['driver_id'] ?? '',
      driverName: map['driver_name'] ?? 'Driver',
      vehicleType: map['vehicle_type'] ?? 'Auto',
      availableSeats: map['available_seats'] ?? 0,
      priceEstimate: (map['price_estimate'] ?? 0.0).toDouble(),
      etaMinutes: map['eta_minutes'] ?? 0,
      matchScore: (map['match_score'] ?? 0.0).toDouble(),
      pickupLocation: LatLng((pickup['lat'] as num).toDouble(), (pickup['lng'] as num).toDouble()),
      dropoffLocation: LatLng((dropoff['lat'] as num).toDouble(), (dropoff['lng'] as num).toDouble()),
      routePolyline: route,
      clusterId: map['cluster_id'] ?? '',
      detourDistance: (map['detour_distance'] ?? 0.0).toDouble(),
      pathOverlapPercentage: (map['path_overlap_percentage'] ?? 0.0).toDouble(),
    );
  }
}
