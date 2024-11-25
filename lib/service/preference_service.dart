import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AppPreferences {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static final AppPreferences _instance = AppPreferences._internal();
  factory AppPreferences() => _instance;
  AppPreferences._internal();

  SharedPreferences? prefs;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    print('AppPreferences initialized: ${prefs != null}');
  }
  Future<void> save(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      print('SecureStorage saved $key: $value');
    } catch (e) {
      print('Error saving to SecureStorage: $e');
    }
  }

  Future<String?> get(String key) async {
    try {
      final value = await _storage.read(key: key);
      print('SecureStorage get $key: $value');
      return value;
    } catch (e) {
      print('Error reading from SecureStorage: $e');
      return null;
    }
  }
  Future<void> remove(String key) async {
    await _storage.delete(key: key);
    print('SecureStorage removed $key');
  }
}
