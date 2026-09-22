import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../providers/favorites_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/async_value_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final favoritesCount = ref.watch(favoritesProvider).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: AsyncValueWidget<AppUser>(
        value: userAsync,
        onRetry: () => ref.invalidate(currentUserProvider),
        data: (user) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                child: Text(user.avatarEmoji, style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
            ),
            Center(
              child: Text(user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(user.memberSince,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ),
            const SizedBox(height: 32),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.favorite_outline),
                    title: const Text('Favoris'),
                    trailing: Text('$favoritesCount'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.location_on_outlined),
                    title: Text('Adresses de livraison'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.credit_card_outlined),
                    title: Text('Moyens de paiement'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text('Paramètres'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
            ),
          ],
        ),
      ),
    );
  }
}
