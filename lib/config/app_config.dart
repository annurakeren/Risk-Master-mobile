import 'package:flutter/foundation.dart';

class AppConfig {
  // Ganti IP ini dengan IPv4 laptop kamu (bisa cek pakai command 'ipconfig' di CMD)
  // Contoh: '192.168.1.10'
  // IP WiFi laptop kamu (dari ipconfig)
  static const String _localIp = '10.24.38.225';

  // URL Backend untuk Production (isi setelah deploy ke Railway)
  static const String _productionUrl = 'https://api.riskmaster.com/api';

  // Toggle mode: false = pakai local, true = pakai production
  static const bool isProduction = false;

  static String get baseUrl {
    if (isProduction) return _productionUrl;
    
    // Jika run di Chrome/Web, otomatis pakai localhost
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    
    // Jika run di HP fisik, gunakan IP laptop
    return 'http://$_localIp:8000/api';
  }

  static const String appName = 'Risk Master';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}
