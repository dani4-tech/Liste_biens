import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Gère la liste des identifiants de produits favoris, persistée en local.
class FavoritesService {
  static const _key = 'favorite_product_ids';

  static Future<Set<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    final List<dynamic> ids = json.decode(raw);
    return ids.map((e) => e as int).toSet();
  }

  static Future<void> _save(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(ids.toList()));
  }

  /// Ajoute ou retire un produit des favoris. Retourne le nouvel état (true = favori).
  static Future<bool> toggle(int productId) async {
    final favorites = await getFavorites();
    final isNowFavorite = !favorites.contains(productId);
    if (isNowFavorite) {
      favorites.add(productId);
    } else {
      favorites.remove(productId);
    }
    await _save(favorites);
    return isNowFavorite;
  }
}