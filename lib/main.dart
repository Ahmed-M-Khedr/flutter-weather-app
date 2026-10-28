import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/bloc/weather_bloc.dart';
import 'package:weather_app/data/repositories/weather_repository.dart';
import 'package:weather_app/data/services/weather_service.dart';
import 'package:weather_app/pages/weather_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dio = Dio();
  final weatherService = WeatherService(dio: dio);
  final weatherRepository = WeatherRepository(weatherService: weatherService);
  runApp(MyApp(weatherRepository: weatherRepository));
}

class MyApp extends StatelessWidget {
  final WeatherRepository weatherRepository;
  const MyApp({super.key, required this.weatherRepository});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherBloc(weatherRepository),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const WeatherScreen(),
      ),
    );
  }
}
