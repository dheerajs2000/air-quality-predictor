import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Quality Checker v2.1',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: GoogleFonts.montserratTextTheme(),
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

  Future<void> fetchPrediction() async {
    setState(() {
      isLoading = true;
      result = '';
      pollutantData = {};
    });
  html.window.navigator.permissions?.query({"name": "geolocation"}).then((result) {
  print("Permission status: ${result.state}");
    });

    try {
      html.window.navigator.geolocation.getCurrentPosition().then((position) async {
        final lat = position.coords?.latitude;
        final lon = position.coords?.longitude;  

        if (lat != null && lon != null) {
          await getLocationDetailsFromGoogle(lat.toDouble(), lon.toDouble());  // Use Google API for location name

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
            final formattedAddress = results[0]['formatted_address'];
            setState(() {
              locationName = formattedAddress;
            });
          } else {
            setState(() {
              locationName = 'Unknown location';
            });
          }
        } else {
          print("Google Geocoding error: ${jsonData['status']}");
          setState(() {
            locationName = 'Unknown location';
          });
        }
      } else {
        print("HTTP error: ${response.statusCode}");
        setState(() {
          locationName = 'Unknown location';
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        locationName = 'Unknown location';
      });
    }
  }

  Color getStatusColor() {
    return result.toLowerCase() == 'safe' ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          'Air Quality Checker',
          style: GoogleFonts.montserrat(
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFFCE4EC)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Click below to check air quality at your location:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                if (locationName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 24),
                    child: Text(
                      '📍 $locationName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : fetchPrediction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.cloud),
                  label: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Check Air Quality'),
                ),
                const SizedBox(height: 40),
                if (result.isNotEmpty)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: result.toLowerCase() == 'safe' ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Status: $result',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: pollutantData.entries.map((entry) {
                          return Container(
                            width: 100,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  entry.key.toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  entry.value.toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
