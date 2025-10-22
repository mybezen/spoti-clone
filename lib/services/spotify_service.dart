import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SpotifyService {
  final String clientId;
  final String clientSecret;
  String? _accessToken;
  DateTime? _tokenExpiry;

  SpotifyService({required this.clientId, required this.clientSecret});

  Future<String> _getAccessToken() async {
    if (_accessToken != null && 
        _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    try {
      final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'client_credentials'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry = DateTime.now().add(Duration(seconds: data['expires_in']));
        return _accessToken!;
      } else {
        throw Exception('Failed to get access token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting access token: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchTracks(String query) async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/search?q=${Uri.encodeComponent(query)}&type=track&limit=20'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['tracks']['items'] as List;
        return tracks.map((track) => {
          'id': track['id'],
          'name': track['name'],
          'artist': track['artists'][0]['name'],
          'album': track['album']['name'],
          'imageUrl': track['album']['images'].isNotEmpty 
              ? track['album']['images'][0]['url'] 
              : '',
          'previewUrl': track['preview_url'],
          'spotifyUrl': track['external_urls']['spotify'],
          'duration': track['duration_ms'],
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error searching tracks: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getTrack(String trackId) async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/tracks/$trackId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final track = json.decode(response.body);
        return {
          'id': track['id'],
          'name': track['name'],
          'artist': track['artists'][0]['name'],
          'album': track['album']['name'],
          'imageUrl': track['album']['images'].isNotEmpty 
              ? track['album']['images'][0]['url'] 
              : '',
          'previewUrl': track['preview_url'],
          'spotifyUrl': track['external_urls']['spotify'],
          'duration': track['duration_ms'],
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error getting track: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getRecommendations({String? seedTrackId}) async {
    try {
      final token = await _getAccessToken();
      final seed = seedTrackId ?? '3n3Ppam7vgaVa1iaRUc9Lp';
      
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/recommendations?seed_tracks=$seed&limit=10'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tracks = data['tracks'] as List;
        return tracks.map((track) => {
          'id': track['id'],
          'name': track['name'],
          'artist': track['artists'][0]['name'],
          'album': track['album']['name'],
          'imageUrl': track['album']['images'].isNotEmpty 
              ? track['album']['images'][0]['url'] 
              : '',
          'previewUrl': track['preview_url'],
          'spotifyUrl': track['external_urls']['spotify'],
          'duration': track['duration_ms'],
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting recommendations: $e');
      return [];
    }
  }
}