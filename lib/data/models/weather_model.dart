class WeatherModel {
  final String cityName;
  final double tempC;
  final double maxTemp;
  final double minTemp;
  final String conditionText;
  final String conditionIcon;
  final int humidity;
  final double windKph;

  WeatherModel({
    required this.cityName,
    required this.tempC,
    required this.maxTemp,
    required this.minTemp,
    required this.conditionText,
    required this.conditionIcon,
    required this.humidity,
    required this.windKph,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final forecastDay = json['forecast']['forecastday'][0]['day'];
    return WeatherModel(
      cityName: json['location']['name'],
      tempC: (json['current']['temp_c'] as num).toDouble(),
      maxTemp: (forecastDay['maxtemp_c'] as num).toDouble(),
      minTemp: (forecastDay['mintemp_c'] as num).toDouble(),
      conditionText: forecastDay['condition']['text'],
      conditionIcon: 'https:${forecastDay['condition']['icon']}',
      humidity: json['current']['humidity'],
      windKph: (json['current']['wind_kph'] as num).toDouble(),
    );
  }
}
