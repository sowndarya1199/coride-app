import 'dart:math';
import 'package:maplibre_gl/maplibre_gl.dart';

class DirectionsService {
  double distanceMeters(LatLng a, LatLng b) {
    const earthRadiusMeters = 6371000.0;
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLon = _degToRad(b.longitude - a.longitude);
    final lat1 = _degToRad(a.latitude);
    final lat2 = _degToRad(b.latitude);
    final h = _hav(dLat) + cos(lat1) * cos(lat2) * _hav(dLon);
    final c = 2 * asin(min(1, sqrt(h)));
    return earthRadiusMeters * c;
  }

  double _hav(double x) => pow(sin(x / 2), 2).toDouble();
  double _degToRad(double deg) => deg * (pi / 180.0);
}


