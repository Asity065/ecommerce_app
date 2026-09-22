import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/filter_sort_provider.dart';
import '../providers/product_providers.dart';
import '../widgets/async_value_widget.dart';

class FilterSortBar extends ConsumerWidget implements PreferredSizeWidget {
  const FilterSortBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final sortOption = ref.watch(sortOptionProvider);

    return PreferredSize(
      preferredSize: preferredSize,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un produit…',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: Row(
                children: [
                  Expanded(
                    child: AsyncValueWidget<List<String>>(
                      value: categoriesAsync,
                      data: (categories) => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final selected = category == selectedCategory;
                          return ChoiceChip(
                            label: Text(category),
                            selected: selected,
                            onSelected: (_) =>
                                ref.read(selectedCategoryProvider.notifier).state = category,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<SortOption>(
                    icon: const Icon(Icons.sort),
                    tooltip: 'Trier',
                    initialValue: sortOption,
                    onSelected: (value) => ref.read(sortOptionProvider.notifier).state = value,
                    itemBuilder: (context) => SortOption.values
                        .map((option) => PopupMenuItem(value: option, child: Text(option.label)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
