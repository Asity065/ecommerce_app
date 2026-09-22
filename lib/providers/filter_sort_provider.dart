import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SortOption { none, priceAsc, priceDesc, ratingDesc }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.none:
        return 'Pertinence';
      case SortOption.priceAsc:
        return 'Prix croissant';
      case SortOption.priceDesc:
        return 'Prix décroissant';
      case SortOption.ratingDesc:
        return 'Meilleures notes';
    }
  }
}

final searchQueryProvider = StateProvider<String>((ref) => '');

final selectedCategoryProvider = StateProvider<String>((ref) => 'Tous');

final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.none);
