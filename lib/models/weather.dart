class WeatherData {
  final double temperatureCelsius;
  final double windspeed;
  final int weatherCode;
  final String description;
  final String iconEmoji;

  WeatherData({
    required this.temperatureCelsius,
    required this.windspeed,
    required this.weatherCode,
    required this.description,
    required this.iconEmoji,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final code = (current['weather_code'] as num).toInt();

    return WeatherData(
      temperatureCelsius: (current['temperature_2m'] as num).toDouble(),
      windspeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: code,
      description: _descriptionFromCode(code),
      iconEmoji: _emojiFromCode(code),
    );
  }

  /// Reference: https://open-meteo.com/en/docs#weathervariables
  static String _descriptionFromCode(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 2) return 'Partly cloudy';
    if (code == 3) return 'Overcast';
    if (code <= 49) return 'Foggy';
    if (code <= 59) return 'Drizzle';
    if (code <= 69) return 'Rain';
    if (code <= 79) return 'Snow';
    if (code <= 82) return 'Rain showers';
    if (code <= 86) return 'Snow showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  static String _emojiFromCode(int code) {
    if (code == 0) return '☀️';
    if (code <= 2) return '⛅';
    if (code == 3) return '☁️';
    if (code <= 49) return '🌫️';
    if (code <= 69) return '🌧️';
    if (code <= 79) return '❄️';
    if (code <= 82) return '🌦️';
    if (code <= 86) return '🌨️';
    if (code <= 99) return '⛈️';
    return '🌡️';
  }
}
