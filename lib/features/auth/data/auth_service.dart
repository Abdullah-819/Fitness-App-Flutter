import 'dart:async';
import '../domain/models/user_model.dart';

/// Exception thrown during authentication failures.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Authentication service managing sign-in and default mock credentials.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Default demo credentials
  static const String defaultEmail = 'andrew.ainsley@yourdomain.com';
  static const String defaultPassword = 'password123';
  static const String defaultName = 'Andrew Ainsley';

  /// Sign in with email and password.
  /// Throws [AuthException] on invalid credentials.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // Simulate network delay to display loading state
    await Future.delayed(const Duration(milliseconds: 1200));

    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    final isDefaultEmail = normalizedEmail == defaultEmail.toLowerCase() ||
        normalizedEmail == 'user@fitness.com' ||
        normalizedEmail == 'admin@fitness.com';

    final isDefaultPassword = trimmedPassword == defaultPassword ||
        trimmedPassword == '123456' ||
        trimmedPassword == 'Andrew@123';

    if (isDefaultEmail && isDefaultPassword) {
      _currentUser = const UserModel(
        id: 'user_001',
        email: defaultEmail,
        name: defaultName,
      );
      return _currentUser!;
    }

    if (!isDefaultEmail) {
      throw const AuthException(
        'User not found. Use default email: andrew.ainsley@yourdomain.com',
      );
    }

    throw const AuthException(
      'Incorrect password. Use default password: password123',
    );
  }

  /// Sign out the current user
  void signOut() {
    _currentUser = null;
  }
}
