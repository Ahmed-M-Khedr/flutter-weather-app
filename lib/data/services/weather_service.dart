import 'package:dio/dio.dart';
import '../models/weather_model.dart';

class WeatherService {
  final Dio dio;
  final String apiKey = 'f83386fdbde24b0b99c110500262908';
  final String baseUrl = 'http://api.weatherapi.com/v1';

  WeatherService({required this.dio});

  Future<WeatherModel> getWeatherByCity(String cityName) async {
    try {
      Response response = await dio.get(
        '$baseUrl/forecast.json',
        queryParameters: {'key': apiKey, 'q': cityName, 'days': 1},
      );
      return WeatherModel.fromJson(response.data);
    } on DioException catch (e) {
      final String errorMessage =
          e.response?.data['error']['message'] ??
          'Network connection error. Please try again later.';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}
