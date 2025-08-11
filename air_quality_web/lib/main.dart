import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'generated/l10n.dart';
import 'package:provider/provider.dart';
import 'locale_provider.dart';
import 'dart:math' as math;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
      locale: localeProvider.locale,
      title: 'Air Quality App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667EEA),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667EEA),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String result = '';
  Map<String, dynamic> pollutantData = {};
  bool isLoading = false;
  String locationName = '';
  String? expandedCardKey;
  Timer? _collapseTimer;
  
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _pulseController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _pulseAnimation;

  final Map<String, String> pollutantInfo = {
    'CO': 'Carbon Monoxide: A colorless, odorless gas that can be harmful when inhaled in large amounts.',
    'SO2': 'Sulfur Dioxide: A toxic gas with a pungent smell; causes respiratory issues.',
    'NO2': 'Nitrogen Dioxide: A reddish-brown gas that can irritate lungs and worsen asthma.',
    'O3': 'Ozone: A reactive gas that can damage lung tissue and exacerbate respiratory diseases.',
    'PM10': 'Particulate Matter ≤10µm: Inhalable particles that affect lungs and heart.',
    'PM25': 'Particulate Matter ≤2.5µm: Fine particles that penetrate deep into lungs, dangerous for health.',
  };

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutBack,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _headerAnimationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    _pulseController.dispose();
    _collapseTimer?.cancel();
    super.dispose();
  }

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
            _cardAnimationController.forward();
          } else {
            setState(() {
              result = 'Error: ${response.statusCode}';
            });
          }
        } else {
          setState(() {
            result = AppLocalizations.of(context)!.locationUnavailable;
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
              locationName = AppLocalizations.of(context)!.unknownLocation;
            });
          }
        }
      }
    } catch (_) {
      setState(() {
        locationName = AppLocalizations.of(context)!.unknownLocation;
      });
    }
  }

  Color getStatusColor() => result.toLowerCase() == 'safe' 
    ? const Color(0xFF10B981) 
    : const Color(0xFFEF4444);

  LinearGradient getStatusGradient() => result.toLowerCase() == 'safe'
    ? const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF34D399)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
    : const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFF87171)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient getPollutantGradient(String key, double value) {
    Color primaryColor;
    Color secondaryColor;
    
    switch (key.toUpperCase()) {
      case 'CO':
        if (value <= 4) {
          primaryColor = const Color(0xFF10B981);
          secondaryColor = const Color(0xFF34D399);
        } else if (value <= 10) {
          primaryColor = const Color(0xFFF59E0B);
          secondaryColor = const Color(0xFFFBBF24);
        } else {
          primaryColor = const Color(0xFFEF4444);
          secondaryColor = const Color(0xFFF87171);
        }
        break;
      case 'SO2':
        if (value <= 40) {
          primaryColor = const Color(0xFF10B981);
          secondaryColor = const Color(0xFF34D399);
        } else if (value <= 100) {
          primaryColor = const Color(0xFFF59E0B);
          secondaryColor = const Color(0xFFFBBF24);
        } else {
          primaryColor = const Color(0xFFEF4444);
          secondaryColor = const Color(0xFFF87171);
        }
        break;
      case 'NO2':
        if (value <= 25) {
          primaryColor = const Color(0xFF10B981);
          secondaryColor = const Color(0xFF34D399);
        } else if (value <= 100) {
          primaryColor = const Color(0xFFF59E0B);
          secondaryColor = const Color(0xFFFBBF24);
        } else {
          primaryColor = const Color(0xFFEF4444);
          secondaryColor = const Color(0xFFF87171);
        }
        break;
      case 'O3':
        if (value <= 100) {
          primaryColor = const Color(0xFF10B981);
          secondaryColor = const Color(0xFF34D399);
        } else if (value <= 200) {
          primaryColor = const Color(0xFFF59E0B);
          secondaryColor = const Color(0xFFFBBF24);
        } else {
          primaryColor = const Color(0xFFEF4444);
          secondaryColor = const Color(0xFFF87171);
        }
        break;
      case 'PM10':
        if (value <= 45) {
          primaryColor = const Color(0xFF10B981);
          secondaryColor = const Color(0xFF34D399);
        } else if (value <= 100) {
          primaryColor = const Color(0xFFF59E0B);
          secondaryColor = const Color(0xFFFBBF24);
        } else {
          primaryColor = const Color(0xFFEF4444);
          secondaryColor = const Color(0xFFF87171);
        }
        break;
      case 'PM25':
        if (value <= 15) {
          primaryColor = const Color(0xFF10B981);
          secondaryColor = const Color(0xFF34D399);
        } else if (value <= 35) {
          primaryColor = const Color(0xFFF59E0B);
          secondaryColor = const Color(0xFFFBBF24);
        } else {
          primaryColor = const Color(0xFFEF4444);
          secondaryColor = const Color(0xFFF87171);
        }
        break;
      default:
        primaryColor = const Color(0xFF6B7280);
        secondaryColor = const Color(0xFF9CA3AF);
    }

    return LinearGradient(
      colors: [primaryColor, secondaryColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  IconData getPollutantIcon(String key) {
    switch (key.toUpperCase()) {
      case 'CO':
        return Icons.local_fire_department_rounded;
      case 'NO2':
        return Icons.warning_rounded;
      case 'O3':
        return Icons.bubble_chart_rounded;
      case 'PM10':
        return Icons.blur_on_rounded;
      case 'PM25':
        return Icons.grain_rounded;
      case 'SO2':
        return Icons.factory_rounded;
      default:
        return Icons.cloud_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [
                  const Color(0xFF1F2937),
                  const Color(0xFF111827),
                ]
              : [
                  const Color(0xFF667EEA),
                  const Color(0xFF764BA2),
                  const Color(0xFFF093FB),
                ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Modern Header
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _headerAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - _headerAnimation.value)),
                      child: Opacity(
                        opacity: _headerAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              // Floating Cloud Icon with Glassmorphism
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.2),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: const Icon(
                                        Icons.cloud_rounded,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // App Title with Modern Typography
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Colors.white, Colors.white70],
                                ).createShader(bounds),
                                child: Text(
                                  AppLocalizations.of(context)!.headerTitle,
                                  style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              Text(
                                AppLocalizations.of(context)!.subtitle,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withOpacity(0.8),
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Content Section with Glassmorphism
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(32)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(isDark ? 0.1 : 0.9),
                        Colors.white.withOpacity(isDark ? 0.05 : 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Location Display with Modern Design
                        if (locationName.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    locationName,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Status Display with Enhanced Design
                        if (result.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            decoration: BoxDecoration(
                              gradient: getStatusGradient(),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: getStatusColor().withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  result.toLowerCase() == 'safe' 
                                    ? Icons.check_circle_rounded
                                    : Icons.warning_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Status: ${result.toUpperCase()}',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Modern Action Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(28),
                              onTap: isLoading ? null : fetchPrediction,
                              child: Center(
                                child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.refresh_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Check Air Quality',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                              ),
                            ),
                          ),
                        ),

                        if (pollutantData.isNotEmpty) ...[
                          const SizedBox(height: 40),
                          
                          // Section Title
                          Text(
                            'Air Quality Metrics',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Enhanced Pollutant Cards
                          AnimatedBuilder(
                            animation: _cardAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - _cardAnimation.value)),
                                child: Opacity(
                                  opacity: _cardAnimation.value,
                                  child: Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    alignment: WrapAlignment.center,
                                    children: pollutantData.entries.map((entry) {
                                      return _buildModernPollutantCard(entry);
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom Padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      
      // Modern FAB
      floatingActionButton: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () => localeProvider.toggleLocale(),
            tooltip: localeProvider.locale.languageCode == 'en'
                ? AppLocalizations.of(context)!.switchToKannada
                : AppLocalizations.of(context)!.switchToEnglish,
            child: const Icon(
              Icons.translate_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernPollutantCard(MapEntry<String, dynamic> entry) {
    final key = entry.key.toUpperCase();
    final value = double.tryParse(entry.value.toString()) ?? 0.0;
    final isExpanded = expandedCardKey == key;
    final icon = getPollutantIcon(key);
    final gradient = getPollutantGradient(key, value);

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
        curve: Curves.easeInOut,
        width: 160,
        constraints: BoxConstraints(
          minHeight: isExpanded ? 200 : 140,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with Background
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            
            // Pollutant Name
            Text(
              key,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            
            // Value
            Text(
              key == 'CO'
                  ? '${(value / 1000).toStringAsFixed(2)} mg/m³'
                  : '${value.toStringAsFixed(1)} µg/m³',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),

            // Expanded Information
            if (isExpanded && pollutantInfo.containsKey(key)) ...[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
              Text(
                pollutantInfo[key]!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}