import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../models/ride_offer.dart';

class RideRepository {
  RideRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('ride_offers');

  Stream<List<RideOffer>> streamActiveRides({Duration recentWithin = const Duration(minutes: 5)}) {
    final cutoff = DateTime.now().subtract(recentWithin);
    return _collection.where('active', isEqualTo: true).snapshots().map((snap) {
      return snap.docs.map((d) => _fromMap(d.id, d.data())).where((r) => r.updatedAt.isAfter(cutoff)).toList();
    });
  }

  RideOffer _fromMap(String id, Map<String, dynamic> data) {
    final route = ((data['route'] as List<dynamic>?) ?? [])
        .map((p) => LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()))
        .toList();
    final origin = data['origin'] as Map<String, dynamic>? ?? {'lat': 0.0, 'lng': 0.0};
    final dest = data['destination'] as Map<String, dynamic>? ?? {'lat': 0.0, 'lng': 0.0};
    final ts = data['updatedAt'];
    final updatedAt = ts is Timestamp ? ts.toDate() : DateTime.now();
    return RideOffer(
      id: id,
      driverId: (data['driverId'] ?? '').toString(),
      availableSeats: (data['availableSeats'] ?? 0) as int,
      route: route,
      origin: LatLng((origin['lat'] as num).toDouble(), (origin['lng'] as num).toDouble()),
      destination: LatLng((dest['lat'] as num).toDouble(), (dest['lng'] as num).toDouble()),
      updatedAt: updatedAt,
    );
  }
}


