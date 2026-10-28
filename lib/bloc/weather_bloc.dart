import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather_app/data/models/weather_model.dart';
import 'package:weather_app/data/repositories/weather_repository.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;
  WeatherBloc(this.weatherRepository) : super(WeatherInitial()) {
    on<FetchWeatherEvent>((event, emit) async {
      emit(WeatherLoading());
      try {
        final weather = await weatherRepository.fetchWeather(event.cityName);
        emit(WeatherSuccess(weather: weather));
      } catch (e) {
        final cleanError = e.toString().replaceAll('Exception: ', '');
        emit(WeatherFailure(errorMessage: cleanError));
      }
    });
  }
}
