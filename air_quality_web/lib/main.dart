import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;

void main() {
  runApp(const AirQualityApp());
}

class AirQualityApp extends StatelessWidget {
  const AirQualityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Air Quality Checker',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
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
  bool isLoading = false;

  Future<void> fetchPrediction() async {
    setState(() {
      isLoading = true;
      result = '';
    });

    try {
      // Get current geolocation
      html.window.navigator.geolocation.getCurrentPosition().then((position) async {
        final lat = position.coords?.latitude;
        final lon = position.coords?.longitude;

        if (lat != null && lon != null) {
          final url = Uri.parse('http://localhost:5000/predict');
          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'lat': lat, 'lon': lon}),
          );

          if (response.statusCode == 200) {
            final jsonData = jsonDecode(response.body);
            setState(() {
  result = 'Status: ${jsonData['status']}\n'
           'Pollutants: ${jsonData['data'].toString()}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Air Quality Checker')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Click below to check air quality at your location:',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : fetchPrediction,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Check Air Quality'),
              ),
              const SizedBox(height: 30),
              Text(result, style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
