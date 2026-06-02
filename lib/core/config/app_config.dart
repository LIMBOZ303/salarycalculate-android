/// Cấu hình base URL API.
///
/// Emulator Android: dùng [emulatorBaseUrl] (10.0.2.2 trỏ về localhost máy host).
/// Điện thoại thật: đổi [deviceBaseUrl] thành IP máy tính chạy backend (cùng WiFi).
class AppConfig {
  AppConfig._();

  /// true = emulator, false = điện thoại thật
  static const bool useEmulator = false;

  static const String emulatorBaseUrl = 'http://10.0.2.2:5000';
  static const String deviceBaseUrl = 'https://salarycalculate-be.onrender.com';

  static String get baseUrl => useEmulator ? emulatorBaseUrl : deviceBaseUrl;
}
