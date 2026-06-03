import 'package:flutter/foundation.dart';

class AppConfig {
  // Ganti IP ini dengan IPv4 laptop kamu (bisa cek pakai command 'ipconfig' di CMD)
  // Contoh: '192.168.1.10'
  static const String _localIp = '192.168.1.5'; 

  // URL Backend untuk Production (bisa diganti nanti setelah deploy)
  static const String _productionUrl = 'https://api.riskmaster.com/api';

  // Toggle mode production
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
