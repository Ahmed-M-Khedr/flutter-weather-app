import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/data/repositories/weather_repository.dart';
import 'package:weather_app/data/services/weather_service.dart';
import 'package:weather_app/main.dart';

void main() {
  testWidgets('Weather app shows English search instructions on launch', (
    tester,
  ) async {
    final weatherRepository = WeatherRepository(
      weatherService: WeatherService(dio: Dio()),
    );

    await tester.pumpWidget(MyApp(weatherRepository: weatherRepository));

    expect(
      find.text('Search for a city to view the weather ☀️'),
      findsOneWidget,
    );
    expect(find.text('Enter city name (e.g. Cairo)'), findsOneWidget);
  });
}
