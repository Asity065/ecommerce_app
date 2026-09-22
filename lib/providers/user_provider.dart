import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return const UserService();
});

final currentUserProvider = FutureProvider<AppUser>((ref) async {
  final service = ref.watch(userServiceProvider);
  return service.fetchCurrentUser();
});
