import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';

class PlaceSuggestion {
  final String id;
  final String name;
  final String address;
  final LatLng location;

  PlaceSuggestion({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
  });
}

class PlaceSearchService {
  PlaceSearchService({String? apiKey}) : _apiKey = apiKey ?? _defaultKey;

  final String _apiKey;

  // TODO: consider moving to secure storage if needed
  static const String _defaultKey = 'NNIOWMA5fUfQG8nBdHFn';

  Future<List<PlaceSuggestion>> autocomplete({
    required String query,
    LatLng? proximity,
    int limit = 5,
  }) async {
    if (query.trim().isEmpty) return [];
    final encoded = Uri.encodeComponent(query);
    final proximityParam = proximity != null
        ? '&proximity=${proximity.longitude},${proximity.latitude}'
        : '';
    final url = Uri.parse(
        'https://api.maptiler.com/geocoding/$encoded.json?key=$_apiKey&limit=$limit$proximityParam');

    final res = await http.get(url);
    if (res.statusCode != 200) return [];
    final data = json.decode(res.body) as Map<String, dynamic>;
    final features = (data['features'] as List<dynamic>? ?? []);
    return features.map((f) {
      final props = f['properties'] as Map<String, dynamic>? ?? {};
      final geometry = f['geometry'] as Map<String, dynamic>? ?? {};
      final coords = (geometry['coordinates'] as List<dynamic>? ?? [0.0, 0.0])
          .map((e) => (e as num).toDouble())
          .toList();
      return PlaceSuggestion(
        id: (f['id'] ?? '').toString(),
        name: (props['name'] ?? props['feature_type'] ?? 'Place').toString(),
        address: (props['address'] ?? props['formatted'] ?? f['place_name'] ??
                '')
            .toString(),
        location: LatLng(coords.length > 1 ? coords[1] : 0.0,
            coords.isNotEmpty ? coords[0] : 0.0),
      );
    }).toList();
  }
}


