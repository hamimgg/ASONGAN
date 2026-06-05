import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asongan_app/features/auth/model/user_model_sql.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _modeKey = 'active_mode'; // 'pembeli' atau 'pedagang'

  // Simpan data user dan mode default
  static Future<void> saveUserSession(UserModelSql user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
    
    // Default mode saat login disesuaikan dengan role
    String mode = (user.role == 'pedagang' || user.role == 'pedagang_dan_pembeli') ? 'pedagang' : 'pembeli';
    await prefs.setString(_modeKey, mode);
  }

  // Ambil data user yang sedang login
  static Future<UserModelSql?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return UserModelSql.fromMap(jsonDecode(userString));
    }
    return null;
  }

  // Hapus session (Logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_modeKey);
  }

  // Simpan mode aktif
  static Future<void> setActiveMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode);
  }

  // Ambil mode aktif
  static Future<String?> getActiveMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_modeKey);
  }
}
