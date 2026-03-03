class User {
  final String id;
  final String email;
  final String? displayName;
  final bool isAuthenticated;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.isAuthenticated = true,
  });

  factory User.guest() {
    return User(
      id: 'guest',
      email: 'guest@example.com',
      displayName: 'Гость',
      isAuthenticated: false,
    );
  }
}






