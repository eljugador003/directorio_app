import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_exception.dart';
import '../models/user.dart';

/// Fuente de datos local: guarda los usuarios favoritos en el telefono con
/// `shared_preferences` (almacenamiento clave-valor).
///
/// Se guarda el usuario completo en JSON, no solo su id, para poder mostrar
/// los favoritos sin conexion a Internet.
class FavoritesLocalDataSource {
  static const String _key = 'favorite_users';

  Future<List<User>> readFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const StorageException();
    }
  }

  Future<void> saveFavorites(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(users.map((user) => user.toJson()).toList());
      final saved = await prefs.setString(_key, raw);
      if (!saved) throw const StorageException();
    } catch (_) {
      throw const StorageException();
    }
  }
}
