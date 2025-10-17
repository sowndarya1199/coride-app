import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:maplibre_gl/maplibre_gl.dart';

class LocationPoint {
  final String userId;
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final String role;
  final bool online;
  final DateTime updatedAt;

  const LocationPoint({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.role,
    required this.online,
    required this.updatedAt,
    this.heading,
    this.speed,
  });

  LatLng get latLng => LatLng(latitude, longitude);
}

class LocationRepository {
  LocationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('locations');

  Stream<LocationPoint?> streamUserLocation(String userId) {
    return _collection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return _fromMap(userId, data);
    });
  }

  Future<void> setUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    required String role,
    required bool online,
    double? heading,
    double? speed,
  }) async {
    await _collection.doc(userId).set({
      'lat': latitude,
      'lng': longitude,
      'heading': heading,
      'speed': speed,
      'role': role,
      'online': online,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<LocationPoint>> streamRecentOnlineDrivers({
    required LatLng center,
    Duration recentWithin = const Duration(minutes: 5),
    double radiusKm = 5,
  }) {
    final cutoff = DateTime.now().subtract(recentWithin);
    return _collection
        .where('role', isEqualTo: 'driver')
        .where('online', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final now = DateTime.now();
      return snap.docs.map((doc) {
        return _fromMap(doc.id, doc.data());
      }).where((p) {
        final isRecent = p.updatedAt.isAfter(cutoff) || p.updatedAt.isAfter(now.subtract(recentWithin));
        if (!isRecent) return false;
        final d = _haversineKm(center.latitude, center.longitude, p.latitude, p.longitude);
        return d <= radiusKm;
      }).toList();
    });
  }

  LocationPoint _fromMap(String userId, Map<String, dynamic> data) {
    final ts = data['updatedAt'];
    DateTime updatedAt;
    if (ts is Timestamp) {
      updatedAt = ts.toDate();
    } else if (ts is DateTime) {
      updatedAt = ts;
    } else {
      updatedAt = DateTime.now();
    }
    return LocationPoint(
      userId: userId,
      latitude: (data['lat'] ?? 0).toDouble(),
      longitude: (data['lng'] ?? 0).toDouble(),
      heading: (data['heading'] as num?)?.toDouble(),
      speed: (data['speed'] as num?)?.toDouble(),
      role: (data['role'] ?? 'driver').toString(),
      online: (data['online'] ?? false) as bool,
      updatedAt: updatedAt,
    );
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
                (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (pi / 180.0);
}


