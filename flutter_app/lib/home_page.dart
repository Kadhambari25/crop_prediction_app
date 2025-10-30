import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'weather_controller.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'weather_details.dart'; // Import the enhanced WeatherDetails widget

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherController weatherController = Get.put(WeatherController());

  bool isListening = false;
  String cropTamil = "";
  late stt.SpeechToText _speech;
  bool _speechAvailable = false;
  TextEditingController areaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.mic_off, color: Colors.white),
              SizedBox(width: 8),
              Text('Microphone permission is required'),
            ],
          ),
          backgroundColor: Colors.orange[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    _speechAvailable = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );
    setState(() {});
  }

  void startListening() async {
    if (!_speechAvailable) return;
    setState(() => isListening = true);

    await _speech.listen(
      onResult: (val) {
        setState(() {
          cropTamil = val.recognizedWords;
        });
      },
      localeId: 'ta_IN',
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 2),
      cancelOnError: true,
      partialResults: true,
    );
  }

  void stopListening() async {
    await _speech.stop();
    setState(() => isListening = false);
  }

  void predict() {
    if (cropTamil.isEmpty || areaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Please provide crop name and area'),
            ],
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    double area = double.tryParse(areaController.text) ?? 1.0;

    // ===== Take actual weather data from API + GPS =====
    final weather = weatherController.weatherData;
    if (weather.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.white),
              SizedBox(width: 8),
              Text('Weather data not loaded yet'),
            ],
          ),
          backgroundColor: Colors.blue[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    double temp = weather['main']?['temp']?.toDouble() ?? 0.0;
    double humidity = weather['main']?['humidity']?.toDouble() ?? 0.0;
    double wind = weather['wind']?['speed']?.toDouble() ?? 0.0;

    weatherController.predictYield(
      cropTamil: cropTamil,
      area: area,
      temp: temp,
      humidity: humidity,
      wind: wind,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.agriculture, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Crop Yield Predictor",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Optional: Add settings dialog if needed, but no logic change
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== Voice Input Section =====
            _buildSectionCard(
              title: "🎤 Voice Crop Input",
              icon: Icons.mic,
              color: Colors.green,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: isListening ? stopListening : startListening,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isListening ? Icons.mic_off : Icons.mic,
                        key: ValueKey(isListening),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    label: Text(
                      isListening ? "Stop Listening" : "Speak Crop Name (Tamil)",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isListening ? Colors.red[600] : Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (cropTamil.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600], size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Recognized: $cropTamil",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===== Area Input Section =====
            _buildSectionCard(
              title: "📏 Cultivation Area",
              icon: Icons.area_chart,
              color: Colors.blue,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  TextField(
                    controller: areaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Area in hectares (e.g., 2.5)",
                      prefixIcon: Icon(Icons.crop_free, color: Colors.blue[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                      ),
                      labelStyle: TextStyle(color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===== Predict Button =====
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: predict,
                icon: const Icon(Icons.calculate, color: Colors.white, size: 24),
                label: const Text(
                  "Predict Yield",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== Prediction Result =====
            Obx(() {
              if (weatherController.predictedYield.value > 0) {
                return _buildSectionCard(
                  title: "🌱 Prediction Result",
                  icon: Icons.trending_up,
                  color: Colors.green,
                  child: Column(
                    children: [
                      Icon(Icons.trending_up, size: 64, color: Colors.green[600]),
                      const SizedBox(height: 16),
                      Text(
                        "${weatherController.predictedYield.value} tons/ha",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Crop: ${weatherController.finalCropUsed.value}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 20),

            // ===== Weather Section =====
            Obx(() {
              if (weatherController.locationDenied.value) {
                return _buildSectionCard(
                  title: "📍 Location Access Needed",
                  icon: Icons.location_off,
                  color: Colors.orange,
                  child: Column(
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.orange[600]),
                      const SizedBox(height: 16),
                      const Text(
                        "Enable location for accurate weather & predictions",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => weatherController.fetchWeather(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Enable Location", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (weatherController.weatherData.isEmpty) {
                return _buildSectionCard(
                  title: "⛅ Loading Weather",
                  icon: Icons.cloud,
                  color: Colors.grey,
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: Colors.green),
                      const SizedBox(height: 16),
                      const Text("Fetching current weather...", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              } else {
                final data = weatherController.weatherData;
                final location = weatherController.locationName.value;
                return Column(
                  children: [
                    // Location Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue[600], size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Location: $location",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Weather Details
                    WeatherDetails(data: data),
                    const SizedBox(height: 16),
                    // Refresh Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => weatherController.fetchWeather(),
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text("Refresh", style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color? color,
    required Widget child,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color?.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}