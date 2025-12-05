import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({Key? key}) : super(key: key);

  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _weeklyForecast = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _lastUpdated = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fetchWeeklyTemperature();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeeklyTemperature() async {
    const String apiKey =
        'd548c2088861d8cc7bf099796590c828'; 
    const String city = 'Tunis';
    const String url =
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> forecastList = data['list'];

        Map<String, List<dynamic>> dailyForecasts = {};

        for (var forecast in forecastList) {
          DateTime forecastDate = DateTime.fromMillisecondsSinceEpoch(
            forecast['dt'] * 1000,
          );

          String dateKey =
              '${forecastDate.year}-${forecastDate.month.toString().padLeft(2, '0')}-${forecastDate.day.toString().padLeft(2, '0')}';

          if (dailyForecasts[dateKey] == null) {
            dailyForecasts[dateKey] = [];
          }
          dailyForecasts[dateKey]!.add(forecast);
        }

        List<Map<String, dynamic>> forecast = [];
        int daysAdded = 0;
        DateTime now = DateTime.now();

        List<String> sortedDates = dailyForecasts.keys.toList()..sort();

        for (String dateKey in sortedDates) {
          if (daysAdded >= 5) break;

          var dailyData = dailyForecasts[dateKey]!.firstWhere(
            (entry) {
              DateTime entryDate = DateTime.fromMillisecondsSinceEpoch(
                entry['dt'] * 1000,
              );
              return entryDate.hour >= 12 && entryDate.hour <= 15;
            },
            orElse:
                () =>
                    dailyForecasts[dateKey]!
                        .first, 
          );

          DateTime forecastDate = DateTime.fromMillisecondsSinceEpoch(
            dailyData['dt'] * 1000,
          );

          forecast.add({
            'day': _getDayName(forecastDate),
            'date': '$dateKey',
            'temperature': dailyData['main']['temp'],
            'condition': _getTemperatureCondition(dailyData['main']['temp']),
            'icon': _getTemperatureIcon(dailyData['main']['temp']),
            'description': dailyData['weather'][0]['description'],
            'wind': dailyData['wind']['speed'],
            
          });

          daysAdded++;
        }

        String now_str = DateTime.now().toString();

        setState(() {
          _weeklyForecast = forecast;
          _isLoading = false;
          _lastUpdated = 'Dernière mise à jour: ${now_str.substring(0, 16)}';
        });
        _animationController.forward();

        await FirebaseFirestore.instance
            .collection('weather')
            .doc('tunis_forecast')
            .set({'forecast': forecast, 'last_updated': now_str});
      } else {
        await _fetchFromFirestore();
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      await _fetchFromFirestore();
    }
  }

  Future<void> _fetchFromFirestore() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('weather')
              .doc('tunis_forecast')
              .get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> forecastData = data['forecast'];
        String lastUpdated = data['last_updated'] ?? 'Date inconnue';

        setState(() {
          _weeklyForecast = List<Map<String, dynamic>>.from(forecastData);
          _isLoading = false;
          _lastUpdated =
              'Dernière mise à jour: ${lastUpdated.substring(0, 16)}';
        });
        _animationController.forward();
      } else {
        setState(() {
          _weeklyForecast = _getDefaultForecast();
          _isLoading = false;
          _lastUpdated = '(Données par défaut)';
        });
        _animationController.forward();
      }
    } catch (e) {
      print('Error fetching from Firestore: $e');
      setState(() {
        _weeklyForecast = _getDefaultForecast();
        _isLoading = false;
        _lastUpdated = '(Données par défaut)';
      });
      _animationController.forward();
    }
  }

  List<Map<String, dynamic>> _getDefaultForecast() {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> defaults = [];

    for (int i = 0; i < 5; i++) {
      DateTime day = now.add(Duration(days: i));
      String dateStr =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

      defaults.add({
        'day': _getDayName(day),
        'date': dateStr,
        'temperature': 22.0 + i, 
        'condition': _getTemperatureCondition(22.0 + i),
        'icon': _getTemperatureIcon(22.0 + i),
        'description': 'Ensoleillé',
        'wind': 10.0,
      });
    }
    return defaults;
  }

  String _getDayName(DateTime date) {
    final List<String> days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    return days[date.weekday % 7]; 
  }

  String _getTemperatureCondition(double temp) {
    if (temp < 10) {
      return 'Très froid (ex. hiver rigoureux)';
    } else if (temp < 20) {
      return 'Froid (ex. matinée fraîche)';
    } else if (temp < 25) {
      return 'Agréable (ex. printemps doux)';
    } else if (temp < 30) {
      return 'Chaud (ex. été modéré)';
    } else {
      return 'Très chaud (ex. canicule)';
    }
  }

  IconData _getTemperatureIcon(double temp) {
    if (temp < 10) {
      return Icons.ac_unit;
    } else if (temp < 20) {
      return Icons.cloud;
    } else if (temp < 25) {
      return Icons.wb_sunny;
    } else if (temp < 30) {
      return Icons.wb_sunny;
    } else {
      return Icons.local_fire_department;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fond.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Prévisions de Température',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black54,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                if (!_isLoading)
                  Text(
                    _lastUpdated,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  )
                else
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView.builder(
                        itemCount: _weeklyForecast.length,
                        itemBuilder: (context, index) {
                          final dayForecast = _weeklyForecast[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.white.withOpacity(0.15),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          Text(
                                            dayForecast['day'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                          Text(
                                            dayForecast['date']
                                                .toString()
                                                .substring(5),
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black26,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              dayForecast['condition'],
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
                                                fontSize: 10,
                                                fontFamily: 'Roboto',
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [Colors.green, Colors.lime],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        dayForecast['icon'],
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    ),
                                    Flexible(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          Text(
                                            '${dayForecast['temperature'].toStringAsFixed(1)}°C',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Roboto',
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 5.0,
                                                  color: Colors.black54,
                                                  offset: Offset(1.0, 1.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.air,
                                                color: Colors.white70,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${dayForecast['wind']} m/s',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
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
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (!_isLoading)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Conseil du jour:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTempAdvice(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    _fetchWeeklyTemperature();
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Actualiser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontFamily: 'Roboto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }

  String _getTempAdvice() {
    if (_weeklyForecast.isEmpty) return '';

    double avgTemp =
        _weeklyForecast
            .map((day) => day['temperature'] as double)
            .reduce((a, b) => a + b) /
        _weeklyForecast.length;

    if (avgTemp < 10) {
      return 'Protégez vos plantes du froid. Envisagez de les rentrer à l\'intérieur ou de les couvrir pendant la nuit.';
    } else if (avgTemp < 15) {
      return 'Température fraîche cette semaine. Réduisez l\'arrosage et vérifiez que vos plantes sont à l\'abri des courants d\'air froid.';
    } else if (avgTemp < 25) {
      return 'Température idéale pour la plupart des plantes. Maintenez un arrosage régulier et surveillez l\'humidité du sol.';
    } else if (avgTemp < 30) {
      return 'Temps chaud prévu. Augmentez légèrement la fréquence d\'arrosage et protégez les plantes sensibles du soleil direct.';
    } else {
      return 'Canicule prévue! Arrosez abondamment vos plantes tôt le matin ou tard le soir et créez de l\'ombre pour les protéger.';
    }
  }
}
