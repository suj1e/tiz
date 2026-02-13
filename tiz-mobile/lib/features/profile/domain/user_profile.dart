class UserProfile {
  final String id;
  final String email;
  final String nickname;

  const UserProfile({
    required this.id,
    required this.email,
    required this.nickname,
  });

  static UserProfile mock() {
    return const UserProfile(
      id: 'mock-user-1',
      email: 'user@tiz.dev',
      nickname: 'Tiz User',
    );
  }
}
