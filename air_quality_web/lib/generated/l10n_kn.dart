// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get headerTitle => 'ವಾಯು ಗುಣಮಟ್ಟ ಪರಿಶೀಲನೆ';

  @override
  String get subtitle => 'ಸುರಕ್ಷಿತವಾಗಿ ಉಸಿರೆಳೆ. ಉತ್ತಮವಾಗಿ ಬದುಕಿ.';

  @override
  String get checkAirQuality => 'ವಾಯು ಗುಣಮಟ್ಟವನ್ನು ಪರಿಶೀಲಿಸಿ';

  @override
  String statusLabel(Object status) {
    return 'ಸ್ಥಿತಿ: $status';
  }

  @override
  String get switchToEnglish => 'ಇಂಗ್ಲಿಷ್‌ಗೆ ಬದಲಿಸಿ';

  @override
  String get switchToKannada => 'ಕನ್ನಡಕ್ಕೆ ಬದಲಿಸಿ';

  @override
  String get coInfo =>
      'ಕಾರ್ಬನ್ ಮೋನಾಕ್ಸೈಡ್: ಬಣ್ಣವಿಲ್ಲದ, ವಾಸನೆ ಇಲ್ಲದ ಅನಿಲ — ಹೆಚ್ಚು ಉಸಿರಿದರೆ ಹಾನಿಕರ.';

  @override
  String get so2Info =>
      'ಸಲ್ಫರ್ ಡಯಾಕ್ಸೈಡ್: ಹಾನಿಕರ ವಾಸನೆ ಹೊಂದಿರುವ ಅನಿಲ; ಉಸಿರಾಟದ ಸಮಸ್ಯೆ ಉಂಟುಮಾಡುತ್ತದೆ.';

  @override
  String get no2Info =>
      'ನೈಟ್ರೋಜನ್ ಡಯಾಕ್ಸೈಡ್: ಕಂದುಬಣ್ಣದ ಅನಿಲ; ಶ್ವಾಸಕೋಶವನ್ನು ಕಿರಿಕಿರಿ ಮಾಡುತ್ತದೆ.';

  @override
  String get o3Info =>
      'ಓಜೋನ್: ಪ್ರತಿಕ್ರಿಯಾಶೀಲ ಅನಿಲ; ಉಸಿರಾಟದ ಕಾಯಿಲೆ ತೀವ್ರಗೊಳಿಸುತ್ತದೆ.';

  @override
  String get pm10Info =>
      'ದಟ್ಟ ಕಣಗಳು ≤10µm: ಶ್ವಾಸಕೋಶ ಮತ್ತು ಹೃದಯದ ಮೇಲೆ ಪರಿಣಾಮ ಬೀರುತ್ತವೆ.';

  @override
  String get pm25Info =>
      'ಸೂಕ್ಷ್ಮ ಕಣಗಳು ≤2.5µm: ಶ್ವಾಸಕೋಶದೊಳಗೆ ಹೊಕ್ಕು ಆರೋಗ್ಯಕ್ಕೆ ಅಪಾಯಕಾರಿ.';

  @override
  String get locationUnavailable => 'ಸ್ಥಳ ಮಾಹಿತಿ ಲಭ್ಯವಿಲ್ಲ';

  @override
  String get unknownLocation => 'ಅಪರಿಚಿತ ಸ್ಥಳ';
}
