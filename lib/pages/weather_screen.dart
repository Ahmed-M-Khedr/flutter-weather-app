import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/weather_bloc.dart';
import '../data/models/weather_model.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  double _safeAlpha(double value) => value.clamp(0.0, 1.0);

  late final AnimationController _searchControllerAnimation =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_handleSearchFocus);
  }

  void _handleSearchFocus() {
    if (_searchFocusNode.hasFocus) {
      _searchControllerAnimation.forward();
    } else {
      _searchControllerAnimation.reverse();
    }
  }

  void _submitSearch([String? value]) {
    final trimmedValue = (value ?? _searchController.text).trim();
    if (trimmedValue.isEmpty) return;

    context.read<WeatherBloc>().add(FetchWeatherEvent(cityName: trimmedValue));
    _searchFocusNode.unfocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchControllerAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF50E3C2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _searchControllerAnimation,
                          builder: (context, child) {
                            final progress = _safeAlpha(
                              _searchControllerAnimation.value,
                            );
                            return Transform.scale(
                              scale: 0.98 + (progress * 0.02),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                    alpha: _safeAlpha(0.18 + (progress * 0.12)),
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.white.withValues(
                                      alpha: _safeAlpha(
                                        0.35 + (progress * 0.35),
                                      ),
                                    ),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: _safeAlpha(
                                          0.12 + (progress * 0.12),
                                        ),
                                      ),
                                      blurRadius: 18 + (progress * 12),
                                      offset: Offset(0, 8 + (progress * 8)),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        focusNode: _searchFocusNode,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          hintText:
                                              'Enter city name (e.g. Cairo)',
                                          hintStyle: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.72,
                                            ),
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                        onSubmitted: _submitSearch,
                                      ),
                                    ),
                                    AnimatedScale(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      scale: 1,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.search,
                                          color: Colors.white,
                                        ),
                                        splashRadius: 22,
                                        onPressed: () => _submitSearch(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: BlocBuilder<WeatherBloc, WeatherState>(
                            builder: (context, state) {
                              if (state is WeatherLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              }

                              if (state is WeatherSuccess) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 600),
                                  switchInCurve: Curves.easeOutBack,
                                  switchOutCurve: Curves.easeIn,
                                  child: _buildWeatherInfo(state.weather),
                                );
                              }

                              if (state is WeatherFailure) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  child: SingleChildScrollView(
                                    key: const ValueKey('error-state'),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Center(
                                      child: Text(
                                        state.errorMessage,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                child: SingleChildScrollView(
                                  key: const ValueKey('empty-state'),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Search for a city to view the weather ☀️',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherInfo(WeatherModel weather) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.8, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            final safeValue = _safeAlpha(value);
            return Transform.translate(
              offset: Offset(0, (1 - safeValue) * 28),
              child: Opacity(opacity: safeValue, child: child),
            );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      weather.cityName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    weather.conditionText,
                    style: const TextStyle(color: Colors.white70, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Hero(
                    tag: 'weather-icon-${weather.cityName}',
                    child: Image.network(
                      weather.conditionIcon,
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.cloud,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${weather.tempC.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Text(
                        'High: ${weather.maxTemp.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Low: ${weather.minTemp.round()}°',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      runSpacing: 16,
                      spacing: 20,
                      children: [
                        _WeatherDetailItem(
                          icon: Icons.water_drop,
                          title: 'Humidity',
                          value: '${weather.humidity}%',
                        ),
                        _WeatherDetailItem(
                          icon: Icons.air,
                          title: 'Wind',
                          value: '${weather.windKph} km/h',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WeatherDetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _WeatherDetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
