import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Quality Checker v2.1',
      theme: ThemeData(
        primaryColor: const Color(0xFF00796B),
        scaffoldBackgroundColor: const Color(0xFFE0F7FA),
        cardColor: Colors.white,
        textTheme: GoogleFonts.montserratTextTheme().apply(
          bodyColor: const Color(0xFF37474F),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String result = '';
  Map<String, dynamic> pollutantData = {};
  bool isLoading = false;
  String locationName = '';
  String? expandedCardKey;
  Timer? _collapseTimer;

  final Map<String, String> pollutantInfo = {
    'CO': 'Carbon Monoxide: A colorless, odorless gas that can be harmful when inhaled in large amounts.',
    'SO2': 'Sulfur Dioxide: A toxic gas with a pungent smell; causes respiratory issues.',
    'NO2': 'Nitrogen Dioxide: A reddish-brown gas that can irritate lungs and worsen asthma.',
    'O3': 'Ozone: A reactive gas that can damage lung tissue and exacerbate respiratory diseases.',
    'PM10': 'Particulate Matter ≤10µm: Inhalable particles that affect lungs and heart.',
    'PM25': 'Particulate Matter ≤2.5µm: Fine particles that penetrate deep into lungs, dangerous for health.',
  };

  Future<void> fetchPrediction() async {
    setState(() {
      isLoading = true;
      result = '';
      pollutantData = {};
    });

    try {
      html.window.navigator.geolocation.getCurrentPosition().then((position) async {
        final lat = position.coords?.latitude;
        final lon = position.coords?.longitude;

        if (lat != null && lon != null) {
          await getLocationDetailsFromGoogle(lat.toDouble(), lon.toDouble());

          final url = Uri.parse('https://air-quality-backend-515068882272.asia-south1.run.app/predict');
          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'lat': lat, 'lon': lon}),
          );

          if (response.statusCode == 200) {
            final jsonData = jsonDecode(response.body);
            setState(() {
              result = jsonData['status'] ?? 'No status';
              pollutantData = jsonData['data'] ?? {};
            });
          } else {
            setState(() {
              result = 'Error: ${response.statusCode}';
            });
          }
        } else {
          setState(() {
            result = 'Could not get location.';
          });
        }
      });
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getLocationDetailsFromGoogle(double lat, double lon) async {
    const apiKey = 'AIzaSyC_58Ce3BYw70LHHVZsxGpKYkQT9pMOyNY';
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'OK') {
          final results = jsonData['results'] as List;
          if (results.isNotEmpty) {
            setState(() {
              locationName = results[0]['formatted_address'];
            });
          } else {
            setState(() {
              locationName = 'Unknown location';
            });
          }
        }
      }
    } catch (_) {
      setState(() {
        locationName = 'Unknown location';
      });
    }
  }

  Color getStatusColor() => result.toLowerCase() == 'safe' ? Colors.green : Colors.red;
  LinearGradient getPollutantColorGradient(String key, double value) {
  Color startColor = Colors.white;
  Color endColor;

  switch (key.toUpperCase()) {
    case 'CO':
      // Safe < 4000 ug/m3
      endColor = value <= 4000 ? Colors.green : (value <= 10000 ? Colors.orange : Colors.red);
      break;
    case 'SO2':
      // Safe < 40 ug/m3
      endColor = value <= 40 ? Colors.green : (value <= 100 ? Colors.orange : Colors.red);
      break;
    case 'NO2':
      // Safe < 25 ug/m3
      endColor = value <= 25 ? Colors.green : (value <= 100 ? Colors.orange : Colors.red);
      break;
    case 'O3':
      // Safe < 100 ug/m3
      endColor = value <= 100 ? Colors.green : (value <= 200 ? Colors.orange : Colors.red);
      break;
    case 'PM10':
      // Safe < 45 ug/m3
      endColor = value <= 45 ? Colors.green : (value <= 100 ? Colors.orange : Colors.red);
      break;
    case 'PM25':
      // Safe < 15 ug/m3
      endColor = value <= 15 ? Colors.green : (value <= 35 ? Colors.orange : Colors.red);
      break;
    default:
      endColor = Colors.grey;
  }

  return LinearGradient(
    colors: [startColor, endColor.withOpacity(0.5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}


  Color getPollutantColor(String key, double value) {
  switch (key.toUpperCase()) {
    case 'CO':
      if (value <= 4) return Colors.green[300]!;
      if (value <= 10) return Colors.orange[300]!;
      return Colors.red[300]!;

    case 'SO2':
      if (value <= 40) return Colors.green[300]!;
      if (value <= 100) return Colors.orange[300]!;
      return Colors.red[300]!;

    case 'NO2':
      if (value <= 25) return Colors.green[300]!;
      if (value <= 100) return Colors.orange[300]!;
      return Colors.red[300]!;

    case 'O3':
      if (value <= 100) return Colors.green[300]!;
      if (value <= 200) return Colors.orange[300]!;
      return Colors.red[300]!;

    case 'PM10':
      if (value <= 45) return Colors.green[300]!;
      if (value <= 100) return Colors.orange[300]!;
      return Colors.red[300]!;

    case 'PM25':
      if (value <= 15) return Colors.green[300]!;
      if (value <= 35) return Colors.orange[300]!;
      return Colors.red[300]!;

    default:
      return Colors.grey;
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00796B), Color(0xFF26A69A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Icon(Icons.cloud_outlined, color: Colors.white, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    'Air Quality Checker',
                    style: GoogleFonts.montserrat(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Breathe Safer. Live Better.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (locationName.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      locationName,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 14),
            if (result.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: getStatusColor().withOpacity(0.1),
                  border: Border.all(color: getStatusColor(), width: 2.5),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: getStatusColor().withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Status: ${result.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: getStatusColor(),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ElevatedButton.icon(
              onPressed: isLoading ? null : fetchPrediction,
              icon: const Icon(Icons.cloud_outlined, color: Colors.white),
              label: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Check Air Quality', style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
  spacing: 16,
  runSpacing: 16,
  alignment: WrapAlignment.center,
  children: pollutantData.entries.map((entry) {
    final key = entry.key.toUpperCase();
    final value = double.tryParse(entry.value.toString()) ?? 0.0;
    final isExpanded = expandedCardKey == key;

    IconData icon;
    switch (key) {
      case 'CO':
        icon = Icons.local_fire_department;
        break;
      case 'NO2':
        icon = Icons.warning;
        break;
      case 'O3':
        icon = Icons.bubble_chart;
        break;
      case 'PM10':
        icon = Icons.blur_on;
        break;
      case 'PM25':
        icon = Icons.grain;
        break;
      case 'SO2':
        icon = Icons.factory;
        break;
      default:
        icon = Icons.cloud;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (expandedCardKey == key) {
            expandedCardKey = null;
            _collapseTimer?.cancel();
          } else {
            expandedCardKey = key;
            _collapseTimer?.cancel();
            _collapseTimer = Timer(const Duration(seconds: 6), () {
              setState(() {
                expandedCardKey = null;
              });
            });
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: getPollutantColorGradient(key, value),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.teal.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.teal, size: 30),
            const SizedBox(height: 10),
            Text(
              key,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
  key == 'CO'
      ? '${(value / 1000).toStringAsFixed(2)} mg/m³' // CO in mg/m³
      : '${value.toStringAsFixed(1)} µg/m³',         // Others in µg/m³
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.teal[700],
  ),
),

            if (isExpanded && pollutantInfo.containsKey(key)) ...[
              const Divider(height: 16, color: Colors.teal),
              Text(
                pollutantInfo[key]!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      ),
    );
  }).toList(),
),
          ],
        ),
      ),
    );
  }
}
