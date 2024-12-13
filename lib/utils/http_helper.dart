import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpHelper {
  static String movieDbBaseUrl = 'https://api.themoviedb.org/3';
  static final movieDbApiKey = dotenv.env['TMDB_API_KEY'];
  static String movieNightBaseUrl = 'https://movie-night-api.onrender.com';

  static startSession(String? deviceId) async {
    var response = await http
        .get(Uri.parse('$movieNightBaseUrl/start-session?device_id=$deviceId'));
    return jsonDecode(response.body);
  }

  static joinSession(String? deviceId, int code) async {
    var response = await http.get(Uri.parse(
        '$movieNightBaseUrl/join-session?device_id=$deviceId&code=$code'));
    return jsonDecode(response.body);
  }

  static voteMovie(String? sessionId, int movieId, bool vote) async {
    var response = await http.get(Uri.parse(
        '$movieNightBaseUrl/vote-movie?session_id=$sessionId&movie_id=$movieId&vote=$vote'));
    return jsonDecode(response.body);
  }

  static getMovies(int page) async {
    var response = await http.get(Uri.parse(
        '$movieDbBaseUrl/movie/popular?api_key=$movieDbApiKey&page=$page'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['results'] is List) {
        return List<Map<String, dynamic>>.from(data['results']);
      }
    }
  }
}
