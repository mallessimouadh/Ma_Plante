import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class Humidity extends StatefulWidget {
  const Humidity({Key? key}) : super(key: key);

  @override
  _HumidityState createState() => _HumidityState();
}

class _HumidityState extends State<Humidity>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _weeklyHumidity = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _waveAnimation;
  String _lastUpdated = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _waveAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fetchWeeklyHumidity();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeeklyHumidity() async {
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

  
        List<Map<String, dynamic>> humidityData = [];
        int daysAdded = 0;

       
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

          String wateringAdvice = _getWateringAdvice(
            dailyData['main']['humidity'],
            dailyData['main']['temp'],
          );

          humidityData.add({
            'day': _getDayName(forecastDate),
            'date': dateKey,
            'humidity': dailyData['main']['humidity'],
            'condition': _getHumidityCondition(dailyData['main']['humidity']),
            'icon': _getHumidityIcon(dailyData['main']['humidity']),
            'temperature': dailyData['main']['temp'],
            'description': dailyData['weather'][0]['description'],
            'wind': dailyData['wind']['speed'],
            'watering_advice': wateringAdvice,
          });

          daysAdded++;
        }

        String now_str = DateTime.now().toString();

        setState(() {
          _weeklyHumidity = humidityData;
          _isLoading = false;
          _lastUpdated = 'Dernière mise à jour: ${now_str.substring(0, 16)}';
        });

        await FirebaseFirestore.instance
            .collection('weather')
            .doc('tunis_humidity')
            .set({'humidity': humidityData, 'last_updated': now_str});
      } else {
        await _fetchFromFirestore();
      }
    } catch (e) {
      print('Error fetching humidity data: $e');
      await _fetchFromFirestore();
    }
  }

  Future<void> _fetchFromFirestore() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('weather')
              .doc('tunis_humidity')
              .get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> humidityData = data['humidity'];
        String lastUpdated = data['last_updated'] ?? 'Date inconnue';

        setState(() {
          _weeklyHumidity = List<Map<String, dynamic>>.from(humidityData);
          _isLoading = false;
          _lastUpdated =
              'Dernière mise à jour: ${lastUpdated.substring(0, 16)}';
        });
      } else {
        setState(() {
          _weeklyHumidity = _getDefaultHumidity();
          _isLoading = false;
          _lastUpdated = '(Données par défaut)';
        });
      }
    } catch (e) {
      print('Error fetching from Firestore: $e');
      setState(() {
        _weeklyHumidity = _getDefaultHumidity();
        _isLoading = false;
        _lastUpdated = '(Données par défaut)';
      });
    }
  }

  List<Map<String, dynamic>> _getDefaultHumidity() {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> defaults = [];

    for (int i = 0; i < 5; i++) {
      DateTime day = now.add(Duration(days: i));
      String dateStr =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

      int humidity = 55 + (i * 5) % 25;
      double temp = 22.0 + (i * 1.5) % 6;

      defaults.add({
        'day': _getDayName(day),
        'date': dateStr,
        'humidity': humidity,
        'condition': _getHumidityCondition(humidity),
        'icon': _getHumidityIcon(humidity),
        'temperature': temp,
        'description': 'Partiellement nuageux',
        'wind': 8.0 + i % 4,
        'watering_advice': _getWateringAdvice(humidity, temp),
      });
    }
    return defaults;
  }

  String _getDayName(DateTime date) {
    final List<String> days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    return days[date.weekday % 7]; 
  }

  String _getHumidityCondition(int humidity) {
    if (humidity < 30) {
      return 'Très faible';
    } else if (humidity < 50) {
      return 'Faible';
    } else if (humidity < 70) {
      return 'Modérée';
    } else if (humidity < 85) {
      return 'Élevée';
    } else {
      return 'Très élevée';
    }
  }

  IconData _getHumidityIcon(int humidity) {
    if (humidity < 30) {
      return Icons.air; 
    } else if (humidity < 50) {
      return Icons.water_drop_outlined; 
    } else if (humidity < 70) {
      return Icons.water_drop; 
    } else if (humidity < 85) {
      return Icons.water; 
    } else {
      return Icons.waves; 
    }
  }

  String _getWateringAdvice(int humidity, double temperature) {
    if (humidity < 40) {
      if (temperature > 25) {
        return "Arrosez abondamment - l'air est sec et chaud";
      } else if (temperature < 15) {
        return "Arrosez modérément malgré l'air sec (températures fraîches)";
      } else {
        return "Augmentez l'arrosage - humidité de l'air faible";
      }
    } else if (humidity < 60) {
      if (temperature > 25) {
        return "Arrosez régulièrement - évaporation importante";
      } else if (temperature < 15) {
        return "Arrosage normal à espacé - conditions équilibrées";
      } else {
        return "Arrosage normal - conditions idéales";
      }
    } else if (humidity < 80) {
      if (temperature > 25) {
        return "Arrosage modéré - atmosphère humide mais chaude";
      } else {
        return "Réduisez l'arrosage - bonne humidité ambiante";
      }
    } else {
      if (temperature > 22) {
        return "Arrosage minimal - risque de maladies fongiques élevé";
      } else {
        return "Évitez d'arroser - l'air est déjà très humide";
      }
    }
  }
  
  double _getAverageHumidity() {
    if (_weeklyHumidity.isEmpty) return 60.0;
    return _weeklyHumidity
            .map((day) => day['humidity'] as int)
            .reduce((a, b) => a + b) /
        _weeklyHumidity.length;
  }

  String _getHumidityAdvice() {
    double avgHumidity = _getAverageHumidity();

    if (avgHumidity < 40) {
      return "Cette semaine: Humidité faible. Considérez l'utilisation d'un humidificateur pour vos plantes d'intérieur ou arrosez plus fréquemment.";
    } else if (avgHumidity < 60) {
      return "Cette semaine: Humidité idéale pour la plupart des plantes. Maintenez votre routine d'arrosage habituelle.";
    } else if (avgHumidity < 75) {
      return "Cette semaine: Humidité légèrement élevée. Réduisez l'arrosage et assurez une bonne ventilation pour éviter les maladies fongiques.";
    } else {
      return "Cette semaine: Humidité très élevée. Espacez les arrosages et surveillez vos plantes pour les signes de moisissure ou de mildiou.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0288D1), Color(0xFF4FC3F7)],
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
                  "Prévisions d'Humidité ",
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _weeklyHumidity.length,
                      itemBuilder: (context, index) {
                        final dayHumidity = _weeklyHumidity[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _waveAnimation.value),
                                child: child,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dayHumidity['day'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                          Text(
                                            dayHumidity['date']
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
                                              color: _getHumidityColor(
                                                dayHumidity['humidity'],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              dayHumidity['condition'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Roboto',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue.shade300,
                                                  Colors.blue.shade600,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                dayHumidity['icon'],
                                                color: Colors.white,
                                                size: 34,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Text(
                                            '${dayHumidity['humidity']}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 28,
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
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      dayHumidity['watering_advice'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
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
                const SizedBox(height: 16),
                if (!_isLoading)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Conseil de la semaine',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getHumidityAdvice(),
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
                    _fetchWeeklyHumidity();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualiser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontFamily: 'Roboto'),
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
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }

  Color _getHumidityColor(int humidity) {
    if (humidity < 30) {
      return Colors.amber;
    } else if (humidity < 50) {
      return Colors.green.shade400;
    } else if (humidity < 70) {
      return Colors.blue.shade400;
    } else if (humidity < 85) {
      return Colors.blue.shade700;
    } else {
      return Colors.indigo;
    }
  }
}
