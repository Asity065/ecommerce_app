import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/favorites_storage_service.dart';

final favoritesStorageServiceProvider = Provider<FavoritesStorageService>((ref) {
  return const FavoritesStorageService();
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final FavoritesStorageService _storage;

  FavoritesNotifier(this._storage) : super({}) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final saved = await _storage.loadFavoriteIds();
    state = saved;
  }

  void toggle(String productId) {
    final updated = Set<String>.from(state);
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    state = updated;
    _storage.saveFavoriteIds(updated);
  }

  bool isFavorite(String productId) => state.contains(productId);
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final storage = ref.watch(favoritesStorageServiceProvider);
  return FavoritesNotifier(storage);
});
