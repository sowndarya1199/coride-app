import 'package:maplibre_gl/maplibre_gl.dart';

class SearchPreferences {
  final int seatsRequired;
  final String? vehicleType; // 'Auto' | 'Cab' | null
  final Duration? maxDetour;
  final double? maxPrice;
  const SearchPreferences({
    required this.seatsRequired,
    this.vehicleType,
    this.maxDetour,
    this.maxPrice,
  });

  Map<String, dynamic> toMap() => {
        'seats_required': seatsRequired,
        if (vehicleType != null) 'vehicle_type': vehicleType,
        if (maxDetour != null) 'max_detour_seconds': maxDetour!.inSeconds,
        if (maxPrice != null) 'max_price': maxPrice,
      };
}

class SearchRequest {
  final String userId;
  final LatLng origin;
  final LatLng destination;
  final DateTime clientTimestamp;
  final String appVersion;
  final SearchPreferences prefs;

  const SearchRequest({
    required this.userId,
    required this.origin,
    required this.destination,
    required this.clientTimestamp,
    required this.appVersion,
    required this.prefs,
  });

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'origin': {'lat': origin.latitude, 'lng': origin.longitude},
        'destination': {'lat': destination.latitude, 'lng': destination.longitude},
        'client_timestamp': clientTimestamp.toIso8601String(),
        'app_version': appVersion,
        'preferences': prefs.toMap(),
      };
}


