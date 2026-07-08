import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asongan_app/features/auth/model/user_model_firebase.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _modeKey = 'active_mode'; // 'pembeli' atau 'pedagang'

  // Simpan data user (Firebase) dan mode default.
  // Session menyimpan UserModelFirebase agar uid Firebase ikut tersimpan,
  // sehingga CRUD produk pedagang bisa memakai uid sebagai pedagang_id.
  static Future<void> saveUserSession(UserModelFirebase user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));

    // Default mode saat login disesuaikan dengan role
    String mode = (user.role == 'pedagang' || user.role == 'pedagang_dan_pembeli') ? 'pedagang' : 'pembeli';
    await prefs.setString(_modeKey, mode);
  }

  // Ambil data user yang sedang login
  static Future<UserModelFirebase?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return UserModelFirebase.fromMap(
        jsonDecode(userString) as Map<String, dynamic>,
      );
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
