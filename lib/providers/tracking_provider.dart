import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../repositories/location_repository.dart';
import '../services/location_service.dart';

class TrackingProvider with ChangeNotifier {
  TrackingProvider({
    LocationService? locationService,
    LocationRepository? locationRepository,
  })  : _locationService = locationService ?? LocationService(),
        _locationRepository = locationRepository ?? LocationRepository();

  final LocationService _locationService;
  final LocationRepository _locationRepository;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  Position? _lastPosition;
  Position? get lastPosition => _lastPosition;

  StreamSubscription<Position>? _positionSub;

  Future<void> goOnline({
    required String userId,
    required String role,
  }) async {
    if (_isOnline) return;
    _isOnline = true;
    notifyListeners();

    await _positionSub?.cancel();
    _positionSub = _locationService
        .positionStream(distanceFilterMeters: 10)
        .listen((pos) {
      _lastPosition = pos;
      _locationRepository.setUserLocation(
        userId: userId,
        latitude: pos.latitude,
        longitude: pos.longitude,
        heading: pos.heading == 0 ? null : pos.heading,
        speed: pos.speed == 0 ? null : pos.speed,
        role: role,
        online: true,
      );
      notifyListeners();
    });
  }

  Future<void> goOffline({
    required String userId,
    required String role,
  }) async {
    if (!_isOnline) return;
    _isOnline = false;
    notifyListeners();
    await _positionSub?.cancel();
    _positionSub = null;
    final pos = _lastPosition;
    if (pos != null) {
      await _locationRepository.setUserLocation(
        userId: userId,
        latitude: pos.latitude,
        longitude: pos.longitude,
        heading: pos.heading == 0 ? null : pos.heading,
        speed: pos.speed == 0 ? null : pos.speed,
        role: role,
        online: false,
      );
    }
  }

  Future<LatLng?> getCurrentLatLng() async {
    final pos = await _locationService.getCurrentPosition();
    if (pos == null) return null;
    _lastPosition = pos;
    notifyListeners();
    return LatLng(pos.latitude, pos.longitude);
  }

  Stream<List<LocationPoint>> nearbyDrivers({
    required LatLng center,
  }) {
    return _locationRepository.streamRecentOnlineDrivers(center: center);
  }
}


