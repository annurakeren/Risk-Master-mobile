// lib/config/app_config.dart
// Ganti baseUrl dengan IP Laravel kamu saat development
// Contoh: 'http://192.168.1.5:8000/api'
class AppConfig {
  static const String baseUrl = 'http://YOUR_LARAVEL_IP:8000/api';
  static const String appName = 'Risk Master';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
}
