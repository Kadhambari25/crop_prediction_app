import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherController extends GetxController {
  // ===== Observable Variables =====
  var locationName = ''.obs;                     // Town/District name
  var weatherData = <String, dynamic>{}.obs;    // Weather info
  var locationDenied = false.obs;               // Track if location permission denied
  var predictedYield = 0.0.obs;                 // Predicted yield
  var finalCropUsed = ''.obs;                   // Final crop name used for prediction

  // ===== Constants =====
  final String apiKey = 'b76947971eb74672a3f9e50d84e56198'; // OpenWeatherMap API Key
  final String flaskUrl = "http://10.161.80.130:5000/predict"; // Corrected URL

  // ===== Fallback Coordinates (if GPS fails) =====
  final double fallbackLat = 22.7196;  // Indore lat
  final double fallbackLon = 75.8577;  // Indore lon

  @override
  void onInit() {
    super.onInit();
    fetchWeather();
  }

  // ===== Fetch current weather based on GPS location =====
  Future<void> fetchWeather() async {
    double lat = fallbackLat;
    double lon = fallbackLon;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        locationDenied.value = true;
        print("Location services disabled. Using fallback coordinates.");
      } else {
        LocationPermission permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            locationDenied.value = true;
            print("Location permission denied. Using fallback coordinates.");
          }
        }

        if (permission == LocationPermission.deniedForever) {
          locationDenied.value = true;
          print("Location permission denied forever. Using fallback coordinates.");
        }

        if (!locationDenied.value) {
          Position pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);
          lat = pos.latitude;
          lon = pos.longitude;

          // Get location name
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
            if (placemarks.isNotEmpty) {
              locationName.value = placemarks.first.locality ??
                  placemarks.first.subAdministrativeArea ??
                  'Unknown';
            }
          } catch (e) {
            print("Placemark error: $e");
            locationName.value = "Unknown";
          }
        }
      }

      print("Fetching weather for lat=$lat, lon=$lon");

      // Fetch weather data
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric'));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // Convert sunrise/sunset timestamps
        int sunriseTs = data['sys']['sunrise'] * 1000;
        int sunsetTs = data['sys']['sunset'] * 1000;
        data['sys']['sunrise_formatted'] =
            DateTime.fromMillisecondsSinceEpoch(sunriseTs).toLocal().toString();
        data['sys']['sunset_formatted'] =
            DateTime.fromMillisecondsSinceEpoch(sunsetTs).toLocal().toString();

        // Ensure numeric values
        data['main']['temp'] = (data['main']['temp'] ?? 0).toDouble();
        data['main']['humidity'] = (data['main']['humidity'] ?? 0).toDouble();
        data['wind']['speed'] = (data['wind']['speed'] ?? 0).toDouble();

        weatherData.value = data;
        print("✅ Weather fetched successfully");
      } else {
        print("Weather API error, status code: ${res.statusCode}");
      }
    } catch (e) {
      print("Error fetching weather: $e");
    }
  }

  // ===== Predict crop yield using backend =====
  Future<void> predictYield({
    required String cropTamil,
    required double area,
    required double temp,
    required double humidity,
    required double wind,
    int districtEncoded = 3,
    int seasonEncoded = 2,
  }) async {
    try {
      var data = {
        "Year": DateTime.now().year,
        "District_Encoded": districtEncoded,
        "Crop_Tamil": cropTamil,
        "Season_Encoded": seasonEncoded,
        "Area": area,
        "Temp": temp,
        "Humidity": humidity,
        "Wind": wind,
        "PAR": 200,
        "SW_DWN": 10,
        "SoilWetness": 0.5,
        "Rainfall": 50
      };

      final response = await http.post(
        Uri.parse(flaskUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        predictedYield.value = (jsonData["predicted_yield"] as num).toDouble();
        finalCropUsed.value = jsonData["final_crop_used"].toString();
        print("✅ Prediction successful: ${predictedYield.value} tons/ha");
      } else {
        print("Error predicting yield, status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error predicting yield: $e");
    }
  }
}
