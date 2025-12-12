import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String _nameKey = 'user_name';
  static const String _photoKey = 'user_photo';

  // Simpan nama user
  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  // Ambil nama user
  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  // Simpan foto user (base64)
  Future<void> savePhoto(String photoBase64) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_photoKey, photoBase64);
  }

  // Ambil foto user
  Future<String?> getPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_photoKey);
  }

  // Hapus foto user
  Future<void> deletePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_photoKey);
  }

  // Clear semua data profile
  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_photoKey);
  }
}