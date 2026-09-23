import 'package:shared_preferences/shared_preferences.dart';

abstract class FavoritesStorage {
  Future<Set<String>> loadFavoriteIds();
  Future<void> saveFavoriteIds(Set<String> ids);
}

class FavoritesStorageService implements FavoritesStorage {
  static const _storageKey = 'favorite_product_ids';

  const FavoritesStorageService();

  @override
  Future<Set<String>> loadFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_storageKey) ?? [];
    return stored.toSet();
  }

  @override
  Future<void> saveFavoriteIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, ids.toList());
  }
}
