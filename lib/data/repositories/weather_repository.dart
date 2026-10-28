import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherRepository {
  final WeatherService weatherService;

  WeatherRepository({required this.weatherService});
  Future<WeatherModel> fetchWeather(String cityName) async {
    return await weatherService.getWeatherByCity(cityName);
  }
}
