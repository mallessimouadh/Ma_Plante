import 'package:flutter/material.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  String _getDayName(DateTime date) {
    final List<String> joursSemaine = [
      'Dimanche',
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
    ];
    return joursSemaine[date.weekday % 7];
  }

  String _getMonthName(int month) {
    final List<String> mois = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    return mois[month - 1];
  }

  
  String _formatDate(DateTime date) {
    return '${_getDayName(date)}, ${date.day} ${_getMonthName(date.month)}';
  }

  String _getDayShort(DateTime date) {
    final List<String> joursAbr = [
      'Dim',
      'Lun',
      'Mar',
      'Mer',
      'Jeu',
      'Ven',
      'Sam',
    ];
    if (date.day == DateTime.now().day) return 'Auj.';
    return joursAbr[date.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Météo', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildCurrentWeather(now),
              const SizedBox(height: 20),
              _buildWeeklyForecast(now),
              const SizedBox(height: 20),
              _buildPlantTips(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.white,
        child: const Icon(Icons.add_a_photo, color: Colors.green),
        tooltip: 'Analyser ma plante',
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Tunis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather(DateTime now) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '22°', 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Ensoleillé',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    _formatDate(now),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const Icon(Icons.wb_sunny, color: Colors.yellow, size: 100),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _WeatherDetailItem(Icons.air, '8 km/h', 'Vent'),
                _WeatherDetailItem(Icons.wb_sunny_outlined, '10', 'UV'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyForecast(DateTime now) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prévisions de la semaine',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _DayForecastItem('Auj.', Icons.wb_sunny, '22°', '16°'),
              _DayForecastItem('Lun', Icons.wb_sunny, '23°', '17°'),
              _DayForecastItem('Mar', Icons.cloud, '21°', '15°'),
              _DayForecastItem('Mer', Icons.wb_sunny, '24°', '18°'),
              _DayForecastItem('Jeu', Icons.wb_sunny, '25°', '19°'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlantTips() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.yellow),
              SizedBox(width: 8),
              Text(
                'Conseils pour vos plantes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Attention aux températures élevées, arrosez vos plantes tôt le matin ou tard le soir.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            'Niveau de luminosité: Très élevé (12500 lux)',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _WeatherDetailItem extends StatelessWidget {
  const _WeatherDetailItem(this.icon, this.value, this.label, {Key? key})
    : super(key: key);

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class _DayForecastItem extends StatelessWidget {
  const _DayForecastItem(
    this.day,
    this.weatherIcon,
    this.highTemp,
    this.lowTemp, {
    Key? key,
  }) : super(key: key);

  final String day;
  final IconData weatherIcon;
  final String highTemp;
  final String lowTemp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Icon(weatherIcon, color: Colors.white),
        const SizedBox(height: 8),
        Text(
          highTemp,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(lowTemp, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
