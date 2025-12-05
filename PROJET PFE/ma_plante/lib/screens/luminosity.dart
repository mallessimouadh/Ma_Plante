import 'dart:async';
import 'package:flutter/material.dart';
import 'package:light/light.dart';
import 'package:fl_chart/fl_chart.dart';

class LuminosityPage extends StatefulWidget {
  const LuminosityPage({Key? key}) : super(key: key);

  @override
  _LuminosityPageState createState() => _LuminosityPageState();
}

class _LuminosityPageState extends State<LuminosityPage> {
  double _lightLevel = 0.0; 
  String _lightCondition = 'Inconnu'; 
  bool _isSensorAvailable = true; 
  bool _isLoading = true; 
  late Light _light; 
  StreamSubscription<int>?
  _lightSubscription; 
  List<FlSpot> _lightData = []; 
  double _timeIndex = 0; 

  @override
  void initState() {
    super.initState();
    _light = Light();
    _lightSubscription = _light.lightSensorStream.listen(
      (int lux) {
        setState(() {
          _lightLevel = lux.toDouble();
          _lightCondition = _getLightCondition(lux.toDouble());
          _isLoading = false;
          _isSensorAvailable = true;

          _lightData.add(FlSpot(_timeIndex, _lightLevel));
          _timeIndex += 1;
          if (_lightData.length > 60) {
            _lightData.removeAt(0);
          }
        });
      },
      onError: (error) {
        setState(() {
          _isSensorAvailable = false;
          _isLoading = false;
        });
      },
      cancelOnError: true,
    );

  
    Future.delayed(const Duration(seconds: 5), () {
      if(mounted && _lightLevel == 0.0 && _isLoading) {
        setState(() {
          _isSensorAvailable = false;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _lightSubscription
        ?.cancel(); 
    super.dispose();
  }

  String _getLightCondition(double lux) {
    if (lux < 50) {
      return 'Très faible luminosité (ex. pièce sombre)';
    } else if (lux < 200) {
      return 'Faible luminosité (ex. zone ombragée)';
    } else if (lux < 500) {
      return 'Luminosité modérée (ex. jour nuageux)';
    } else if (lux < 1000) {
      return 'Luminosité élevée (ex. pièce bien éclairée)';
    } else if (lux < 10000) {
      return 'Très forte luminosité (ex. soleil direct)';
    } else {
      return 'Luminosité extrême (ex. soleil intense)';
    }
  }

  
  IconData _getLightIcon(double lux) {
    if (lux < 50) {
      return Icons.nightlight_round; 
    } else if (lux < 500) {
      return Icons.cloud; 
    } else if (lux < 10000) {
      return Icons.wb_sunny; 
    } else {
      return Icons.wb_incandescent; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4CAF50), 
              Color(0xFF81D4FA), 
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Mesure de Luminosité',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          shadows: [
                            Shadow(
                              blurRadius: 5.0,
                              color: Colors.black26,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 100,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white, Colors.green],
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else if (!_isSensorAvailable)
                  Center(
                    child: Text(
                      'Capteur de luminosité non disponible sur cet appareil.\nVeuillez vérifier si votre appareil prend en charge l\'auto-ajustement de la luminosité.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontFamily: 'Roboto',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )

                else 
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
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
                                  Icon(
                                    _getLightIcon(_lightLevel),
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${_lightLevel.toStringAsFixed(1)} lux',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _lightCondition,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 18,
                                      fontFamily: 'Roboto',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Container(
                            height: 200,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tendance de la luminosité (dernières 60 secondes)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: LineChart(
                                    LineChartData(
                                      gridData: const FlGridData(show: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                value.toInt().toString(),
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontSize: 12,
                                                  fontFamily: 'Roboto',
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                '${value.toInt()}s',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontSize: 12,
                                                  fontFamily: 'Roboto',
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      minX:
                                          _lightData.isNotEmpty
                                              ? _lightData.first.x
                                              : 0,
                                      maxX:
                                          _lightData.isNotEmpty
                                              ? _lightData.last.x
                                              : 60,
                                      minY: 0,
                                      maxY:
                                          _lightData.isNotEmpty
                                              ? (_lightData
                                                      .map((spot) => spot.y)
                                                      .reduce(
                                                        (a, b) => a > b ? a : b,
                                                      ) *
                                                  1.2)
                                              : 1000,
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: _lightData,
                                          isCurved: true,
                                          color: Colors.green,
                                          barWidth: 3,
                                          dotData: const FlDotData(show: false),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: Colors.green.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: Text(
                              'Conseil : Placez votre téléphone dans la zone où vous souhaitez mesurer la luminosité. Les plantes ont généralement besoin de 500 à 1000 lux pour une croissance optimale.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontFamily: 'Roboto',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
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
}
