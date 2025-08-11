// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Air Quality Checker';

  @override
  String get checkAirQuality => 'Check Air Quality';

  @override
  String get statusSafe => 'Status: SAFE';

  @override
  String get statusHazardous => 'Status: HAZARDOUS';
}
