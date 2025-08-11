// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get headerTitle => 'Air Quality Checker';

  @override
  String get subtitle => 'Breathe Safer. Live Better.';

  @override
  String get checkAirQuality => 'Check Air Quality';

  @override
  String statusLabel(Object status) {
    return 'Status: $status';
  }

  @override
  String get switchToEnglish => 'Switch to English';

  @override
  String get switchToKannada => 'Switch to Kannada';

  @override
  String get coInfo =>
      'Carbon Monoxide: A colorless, odorless gas that can be harmful when inhaled in large amounts.';

  @override
  String get so2Info =>
      'Sulfur Dioxide: A toxic gas with a pungent smell; causes respiratory issues.';

  @override
  String get no2Info =>
      'Nitrogen Dioxide: A reddish-brown gas that can irritate lungs and worsen asthma.';

  @override
  String get o3Info =>
      'Ozone: A reactive gas that can damage lung tissue and exacerbate respiratory diseases.';

  @override
  String get pm10Info =>
      'Particulate Matter ≤10µm: Inhalable particles that affect lungs and heart.';

  @override
  String get pm25Info =>
      'Particulate Matter ≤2.5µm: Fine particles that penetrate deep into lungs, dangerous for health.';

  @override
  String get locationUnavailable => 'Location unavailable';

  @override
  String get unknownLocation => 'Unknown location';
}
