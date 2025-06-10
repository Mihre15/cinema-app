import 'dart:convert';

class UserState {
  final bool isLoggedIn;
  final String name;
  final String email;

  const UserState({
    this.isLoggedIn = false,
    this.name = '',
    this.email = '',
  });

  factory UserState.empty() => const UserState();

  factory UserState.fromJson(Map<String, dynamic> json) {
    return UserState(
      isLoggedIn: json['isLoggedIn'] ?? false,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'isLoggedIn': isLoggedIn,
    'name': name,
    'email': email,
  };
}