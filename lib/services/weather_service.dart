// services/weather_service.dart
// Fetches real-time weather data from the Open-Meteo REST API.
// Open-Meteo is free, requires no API key, and returns JSON.
// Docs: https://open-meteo.com/en/docs

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  // Angeles City, Pampanga coordinates
  static const double _latitude = 15.1606;
  static const double _longitude = 120.6091;

  /// Fetches the current weather for Angeles City from the Open-Meteo API.
  ///
  /// Returns a [WeatherData] object parsed from the JSON response.
  /// Throws an [Exception] if the HTTP request fails or returns a non-200 status.
  static Future<WeatherData> fetchCurrentWeather() async {
    // Build the API URL with query parameters
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$_latitude'
      '&longitude=$_longitude'
      '&current=temperature_2m,wind_speed_10m,weather_code'
      '&timezone=Asia%2FManila',
    );

    // Make the GET request using the `http` package
    final response = await http.get(uri);

    // Check for a successful HTTP status code
    if (response.statusCode == 200) {
      // Decode the JSON response body into a Dart Map
      final Map<String, dynamic> json = jsonDecode(response.body);

      // Parse the map into our WeatherData model using fromJson
      return WeatherData.fromJson(json);
    } else {
      throw Exception(
        'Failed to load weather data. '
        'Status: ${response.statusCode}',
      );
    }
  }
}
