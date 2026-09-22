import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorageService {
  static const _storageKey = 'favorite_product_ids';

  const FavoritesStorageService();

  Future<Set<String>> loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_storageKey) ?? [];
    return stored.toSet();
  }

  Future<void> saveFavoriteIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, ids.toList());
  }
}
