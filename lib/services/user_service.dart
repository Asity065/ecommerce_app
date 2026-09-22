import '../models/user.dart';

class UserService {
  const UserService();

  Future<AppUser> fetchCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const AppUser(
      id: 'u1',
      name: 'Aïcha Koné',
      email: 'aicha.kone@example.com',
      avatarEmoji: '🙋🏾‍♀️',
      memberSince: 'Membre depuis 2023',
    );
  }
}
