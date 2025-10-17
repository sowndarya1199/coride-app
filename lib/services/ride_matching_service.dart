import 'dart:math';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../models/ride_offer.dart';

class RideMatchResult {
  final RideOffer offer;
  final double score; // higher is better
  const RideMatchResult(this.offer, this.score);
}

class RideMatchingService {
  // Rough distance in meters between two coordinates using Haversine
  double _distanceMeters(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLon = _degToRad(b.longitude - a.longitude);
    final la1 = _degToRad(a.latitude);
    final la2 = _degToRad(b.latitude);
    final h = pow(sin(dLat / 2), 2) + cos(la1) * cos(la2) * pow(sin(dLon / 2), 2);
    final c = 2 * asin(min(1, sqrt(h)));
    return r * c;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);

  // Simple route overlap: percentage of ride waypoints close to passenger path
  double _routeOverlapScore(List<LatLng> rideRoute, LatLng passengerOrigin, LatLng passengerDest) {
    if (rideRoute.isEmpty) return 0;
    // approximate passenger path as a line origin->dest; count points within 300m
    const threshold = 300.0;
    int closePoints = 0;
    for (final p in rideRoute) {
      final d = _pointToSegmentDistance(p, passengerOrigin, passengerDest);
      if (d <= threshold) closePoints++;
    }
    return closePoints / rideRoute.length;
  }

  // Distance from point to line segment AB in meters
  double _pointToSegmentDistance(LatLng p, LatLng a, LatLng b) {
    // project p onto AB using simple planar approximation for small distances
    final ax = a.longitude, ay = a.latitude;
    final bx = b.longitude, by = b.latitude;
    final px = p.longitude, py = p.latitude;
    final abx = bx - ax, aby = by - ay;
    final apx = px - ax, apy = py - ay;
    final ab2 = abx * abx + aby * aby;
    final t = ab2 == 0 ? 0 : max(0, min(1, (apx * abx + apy * aby) / ab2));
    final proj = LatLng(ay + t * aby, ax + t * abx);
    return _distanceMeters(p, proj);
  }

  // Lightweight DBSCAN-like clustering on ride route points to prioritize dense corridors
  List<RideOffer> _prioritizeCorridors(List<RideOffer> offers) {
    // For now, return as-is; placeholder where DBSCAN could be applied later.
    return offers;
  }

  List<RideMatchResult> matchRides({
    required List<RideOffer> offers,
    required LatLng passengerOrigin,
    required LatLng passengerDestination,
    required int requiredSeats,
  }) {
    final filtered = offers.where((o) => o.availableSeats >= requiredSeats).toList();
    final prioritized = _prioritizeCorridors(filtered);
    final results = <RideMatchResult>[];
    for (final o in prioritized) {
      final originProximity = _distanceMeters(o.origin, passengerOrigin);
      final destProximity = _distanceMeters(o.destination, passengerDestination);
      final overlap = _routeOverlapScore(o.route, passengerOrigin, passengerDestination);
      // scoring: closer origins/dests and higher overlap => higher score
      final score = overlap * 0.6 + (1 / (1 + originProximity / 1000)) * 0.2 + (1 / (1 + destProximity / 1000)) * 0.2;
      results.add(RideMatchResult(o, score));
    }
    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(10).toList();
  }
}


