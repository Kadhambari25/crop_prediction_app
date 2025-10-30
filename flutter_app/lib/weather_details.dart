import 'package:flutter/material.dart';

class WeatherDetails extends StatelessWidget {
  final Map<String, dynamic> data;

  const WeatherDetails({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final temp = data['main']?['temp']?.toStringAsFixed(1) ?? "N/A";
    final humidity = data['main']?['humidity']?.toString() ?? "N/A";
    final condition = data['weather']?[0]?['description'] ?? "N/A";
    final wind = data['wind']?['speed']?.toStringAsFixed(1) ?? "N/A";
    final sunrise = _formatTime(data['sys']?['sunrise_formatted'] ?? "N/A");
    final sunset = _formatTime(data['sys']?['sunset_formatted'] ?? "N/A");

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.green[100]!, Colors.green[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Main Weather Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getWeatherColor(condition).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getWeatherIcon(condition),
                    size: 64,
                    color: _getWeatherColor(condition),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$temp°C",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      condition.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Stats Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWeatherStat(
                  icon: Icons.water_drop_outlined,
                  label: "Humidity",
                  value: "$humidity%",
                  color: Colors.blue[600],
                ),
                _buildWeatherStat(
                  icon: Icons.air_outlined,
                  label: "Wind",
                  value: "$wind m/s",
                  color: Colors.green[600],
                ),
                _buildWeatherStat(
                  icon: Icons.wb_sunny, // Replacing wb_rising
                  label: "Sunrise",
                  value: sunrise,
                  color: Colors.orange[600],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Sunset Stat
            _buildWeatherStat(
              icon: Icons.nights_stay, // Replacing wb_twilight
              label: "Sunset",
              value: sunset,
              color: Colors.purple[600],
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherStat({
    required IconData icon,
    required String label,
    required String value,
    required Color? color,
    bool isFullWidth = false,
  }) {
    Widget content = Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color!.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

    return isFullWidth
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: content,
          )
        : Expanded(child: content);
  }

  IconData _getWeatherIcon(String condition) {
    final lowerCondition = condition.toLowerCase();
    if (lowerCondition.contains('clear') || lowerCondition.contains('sunny')) {
      return Icons.wb_sunny;
    } else if (lowerCondition.contains('cloud') || lowerCondition.contains('overcast')) {
      return Icons.wb_cloudy;
    } else if (lowerCondition.contains('rain') || lowerCondition.contains('shower')) {
      return Icons.umbrella;
    } else if (lowerCondition.contains('thunder')) {
      return Icons.flash_on;
    } else if (lowerCondition.contains('snow') || lowerCondition.contains('mist')) {
      return Icons.ac_unit;
    }
    return Icons.wb_cloudy;
  }

  Color _getWeatherColor(String condition) {
    final lowerCondition = condition.toLowerCase();
    if (lowerCondition.contains('clear') || lowerCondition.contains('sunny')) {
      return Colors.orange[600]!;
    } else if (lowerCondition.contains('cloud') || lowerCondition.contains('overcast')) {
      return Colors.grey[600]!;
    } else if (lowerCondition.contains('rain') || lowerCondition.contains('shower')) {
      return Colors.blue[600]!;
    } else if (lowerCondition.contains('thunder')) {
      return Colors.purple[600]!;
    } else if (lowerCondition.contains('snow') || lowerCondition.contains('mist')) {
      return Colors.lightBlue[600]!;
    }
    return Colors.orange[600]!;
  }

  String _formatTime(String timeString) {
    if (timeString == "N/A") return "N/A";
    try {
      final dateTime = DateTime.parse(timeString);
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return timeString;
    }
  }
}
