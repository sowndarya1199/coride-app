import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/search_request.dart';
import '../models/search_response.dart';

class SearchApi {
  SearchApi({String? baseUrl}) : _baseUrl = baseUrl ?? _defaultBase;

  final String _baseUrl;
  static const String _defaultBase = 'https://your-app-name.railway.app'; // Replace with your deployed URL

  Future<SearchResponse?> submitSearch({
    required SearchRequest request,
    String? authToken,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/v1/search');
      final headers = {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };
      
      final res = await http.post(uri, headers: headers, body: json.encode(request.toMap()));
      
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        return SearchResponse.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Search API error: $e');
      return null;
    }
  }
}


