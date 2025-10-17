import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../providers/auth_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../repositories/location_repository.dart';
import '../../services/place_search_service.dart';
import '../../repositories/ride_repository.dart';
import '../../services/ride_matching_service.dart';
import '../../models/ride_offer.dart';
import '../../models/search_request.dart';
import '../../models/search_response.dart';
import '../../services/search_api.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MaplibreMapController? _controller;
  LatLng? _myLatLng;
  StreamSubscription<List<LocationPoint>>? _nearbySub;
  List<Symbol> _driverSymbols = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final PlaceSearchService _placeSearch = PlaceSearchService();
  List<PlaceSuggestion> _suggestions = [];
  Timer? _searchDebounce;
  String _selectedRideType = 'Auto';
  Symbol? _destinationSymbol;
  final RideRepository _rideRepo = RideRepository();
  final RideMatchingService _rideMatcher = RideMatchingService();
  StreamSubscription<List<RideOffer>>? _rideSub;
  List<RideMatchResult> _rideMatches = [];
  List<Symbol> _rideSymbols = [];
  LatLng? _destinationLatLng;
  int _seatsRequired = 1;
  final SearchApi _searchApi = SearchApi();

  void _onQueryChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      final center = _myLatLng;
      final results = await _placeSearch.autocomplete(
        query: value,
        proximity: center,
        limit: 6,
      );
      if (!mounted) return;
      setState(() {
        _suggestions = results;
      });
    });
  }

  Future<void> _selectSuggestion(PlaceSuggestion s) async {
    _searchFocus.unfocus();
    setState(() {
      _suggestions = [];
      _searchController.text = s.name;
    });
    if (_controller == null) return;
    await _controller!.animateCamera(CameraUpdate.newLatLngZoom(s.location, 15));
    if (_destinationSymbol != null) {
      await _controller!.removeSymbol(_destinationSymbol!);
      _destinationSymbol = null;
    }
    _destinationSymbol = await _controller!.addSymbol(
      SymbolOptions(
        geometry: s.location,
        iconImage: 'marker-15',
        iconSize: 1.6,
        textField: 'Destination',
        textOffset: const Offset(0, 1.2),
      ),
    );
    _destinationLatLng = s.location;

    // Start ride discovery and matching when destination is chosen
    _rideSub?.cancel();
    final origin = _myLatLng;
    if (origin == null) return;
    _rideSub = _rideRepo.streamActiveRides().listen((offers) {
      final matches = _rideMatcher.matchRides(
        offers: offers,
        passengerOrigin: origin,
        passengerDestination: s.location,
        requiredSeats: 1,
      );
      _showRideMatches(matches);
    });
  }

  Future<void> _showRideMatches(List<RideMatchResult> matches) async {
    if (!mounted) return;
    setState(() => _rideMatches = matches);
    // update markers
    if (_controller == null) return;
    if (_rideSymbols.isNotEmpty) {
      await _controller!.removeSymbols(_rideSymbols);
      _rideSymbols.clear();
    }
    for (final m in matches.take(5)) {
      final route = m.offer.route;
      final point = route.isNotEmpty ? route.first : m.offer.origin;
      final symbol = await _controller!.addSymbol(
        SymbolOptions(
          geometry: point,
          iconImage: 'marker-15',
          iconSize: 1.2,
          textField: 'Ride (${m.offer.availableSeats})',
          textOffset: const Offset(0, 1.0),
        ),
      );
      _rideSymbols.add(symbol);
    }
  }

  Widget _rideTypeChip(String type) {
    final isSelected = _selectedRideType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedRideType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type == 'Auto' ? Icons.two_wheeler : Icons.local_taxi,
              size: 18,
              color: isSelected ? Colors.green.shade800 : Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              type,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.green.shade800 : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final tracking = context.read<TrackingProvider>();
    final auth = context.read<AuthProvider>();
    final me = await tracking.getCurrentLatLng();
    if (!mounted) return;
    setState(() {
      _myLatLng = me;
    });
    if (me != null) {
      _listenNearby(me);
    }
    // Auto-start tracking for passengers so their location is saved
    final user = auth.user;
    if (user != null && user.role == 'passenger') {
      await tracking.goOnline(userId: user.uid, role: user.role);
    }
  }

  void _listenNearby(LatLng center) {
    _nearbySub?.cancel();
    _nearbySub = context
        .read<TrackingProvider>()
        .nearbyDrivers(center: center)
        .listen((drivers) {
      if (_controller == null) return;
      // Clear existing driver symbols
      if (_driverSymbols.isNotEmpty) {
        _controller!.removeSymbols(_driverSymbols);
        _driverSymbols.clear();
      }
      // Add new symbols for drivers
      for (final d in drivers) {
        // Using default marker icon; can be customized via asset images
        _controller!
            .addSymbol(SymbolOptions(
          geometry: d.latLng,
          iconImage: 'marker-15',
          iconSize: 1.5,
          textField: 'Driver',
          textOffset: const Offset(0, 1.2),
        ))
            .then((symbol) {
          _driverSymbols.add(symbol);
        });
      }
    });
  }

  @override
  void dispose() {
    _nearbySub?.cancel();
    // Stop tracking for passengers when leaving the map
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user != null && user.role == 'passenger') {
      context.read<TrackingProvider>().goOffline(userId: user.uid, role: user.role);
    }
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _rideSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tracking = context.watch<TrackingProvider>();
    final role = auth.user?.role ?? 'passenger';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Map'),
      ),
      body: _myLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MaplibreMap(
                  styleString: _styleUrl,
                  initialCameraPosition: CameraPosition(
                    target: _myLatLng!,
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  compassEnabled: true,
                  onMapCreated: (c) async {
                    _controller = c;
                  },
                ),
                if (role == 'passenger') ...[
                  // Top search bar
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 16,
                    child: Column(
                      children: [
                        Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocus,
                            onChanged: _onQueryChanged,
                            decoration: InputDecoration(
                              hintText: 'Search Destination',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        if (_suggestions.isNotEmpty && _searchFocus.hasFocus)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _suggestions.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final s = _suggestions[index];
                                return ListTile(
                                  leading: const Icon(Icons.place_outlined),
                                  title: Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  subtitle: Text(s.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  onTap: () => _selectSuggestion(s),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Bottom panel with Auto/Cab
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _rideTypeChip('Auto'),
                              const SizedBox(width: 12),
                              _rideTypeChip('Cab'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Seats'),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  if (_seatsRequired > 1) {
                                    setState(() => _seatsRequired--);
                                  }
                                },
                              ),
                              Text('$_seatsRequired'),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setState(() => _seatsRequired++);
                                },
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: _onSearchPressed,
                                icon: const Icon(Icons.search),
                                label: const Text('Search Rides'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (_rideMatches.isNotEmpty) ...[
                            const Text(
                              'Suggested rides nearby',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _rideMatches.length.clamp(0, 5),
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final m = _rideMatches[i];
                                return ListTile(
                                  leading: const Icon(Icons.directions_car),
                                  title: Text('Seats: ${m.offer.availableSeats}'),
                                  subtitle: Text('Match: ${(m.score * 100).toStringAsFixed(0)}% overlap'),
                                  onTap: () async {
                                    // center map on selected ride origin
                                    await _controller?.animateCamera(
                                        CameraUpdate.newLatLng(m.offer.origin));
                                  },
                                );
                              },
                            ),
                          ]
                          else ...[
                            Row(
                              children: const [
                                Icon(Icons.info_outline, color: Colors.grey),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text('Choose a destination to see suggested rides'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (role == 'driver')
            FloatingActionButton.extended(
              heroTag: 'onlineToggle',
              onPressed: () async {
                final user = auth.user!;
                if (tracking.isOnline) {
                  await tracking.goOffline(userId: user.uid, role: user.role);
                } else {
                  await tracking.goOnline(userId: user.uid, role: user.role);
                }
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(tracking.isOnline ? 'You are online' : 'You are offline')),
                );
              },
              label: Text(tracking.isOnline ? 'Go Offline' : 'Go Online'),
              icon: Icon(tracking.isOnline ? Icons.toggle_on : Icons.toggle_off),
            ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'center',
            onPressed: () async {
              final me = await context.read<TrackingProvider>().getCurrentLatLng();
              if (me == null) return;
              setState(() => _myLatLng = me);
              final c = _controller;
              await c?.animateCamera(CameraUpdate.newLatLng(me));
              _listenNearby(me);
            },
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Future<void> _onSearchPressed() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    final origin = _myLatLng;
    final dest = _destinationLatLng;
    
    if (user == null || origin == null || dest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set your destination first.')),
      );
      return;
    }

    // Show loading state
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Searching for rides...')),
    );

    final req = SearchRequest(
      userId: user.uid,
      origin: origin,
      destination: dest,
      clientTimestamp: DateTime.now(),
      appVersion: '1.0.0',
      prefs: SearchPreferences(
        seatsRequired: _seatsRequired,
        vehicleType: _selectedRideType,
      ),
    );

    try {
      final resp = await _searchApi.submitSearch(request: req);
      
      if (resp != null && resp.matches.isNotEmpty) {
        // Convert backend matches to local format and display
        final localMatches = resp.matches.map((m) => RideMatchResult(
          RideOffer(
            id: m.driverId,
            driverId: m.driverId,
            availableSeats: m.availableSeats,
            route: m.routePolyline,
            origin: m.pickupLocation,
            destination: m.dropoffLocation,
            updatedAt: DateTime.now(),
          ),
          m.matchScore,
        )).toList();
        
        await _showRideMatches(localMatches);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Found ${resp.matches.length} rides from backend')),
        );
      } else {
        // Fallback to local matching
        _fallbackToLocalMatching(origin, dest);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backend unavailable, using local discovery')),
        );
      }
    } catch (e) {
      _fallbackToLocalMatching(origin, dest);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error, using local discovery')),
      );
    }
  }

  Future<void> _fallbackToLocalMatching(LatLng origin, LatLng dest) async {
    _rideSub?.cancel();
    _rideSub = _rideRepo.streamActiveRides().listen((offers) {
      final matches = _rideMatcher.matchRides(
        offers: offers,
        passengerOrigin: origin,
        passengerDestination: dest,
        requiredSeats: _seatsRequired,
      );
      _showRideMatches(matches);
    });
  }
}

// Use a free MapTiler style URL with your key
const String _styleUrl = 'https://api.maptiler.com/maps/streets-v2/style.json?key=NNIOWMA5fUfQG8nBdHFn';


