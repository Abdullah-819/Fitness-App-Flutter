import 'dart:async';
import '../domain/models/user_model.dart';

/// Exception thrown during authentication failures.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Team member credentials definition for quick login & demo testing.
class TeamMemberCredentials {
  final String name;
  final String email;
  final String password;
  final String role;
  final String initials;

  const TeamMemberCredentials({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.initials,
  });
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

  /// Predefined project team members
  static const List<TeamMemberCredentials> teamMembers = [
    TeamMemberCredentials(
      name: 'Abdullah Rana',
      email: 'abdullah.rana@trackfit.com',
      password: '696969',
      role: 'Full Stack Engineer',
      initials: 'AR',
    ),
    TeamMemberCredentials(
      name: 'Ahmad Ali',
      email: 'ahmad.ali@trackfit.com',
      password: '696969',
      role: 'Frontend Developer',
      initials: 'AA',
    ),
    TeamMemberCredentials(
      name: 'Abdullah Qureshi',
      email: 'abdullah.qureshi@trackfit.com',
      password: '696969',
      role: 'Frontend Developer',
      initials: 'AQ',
    ),
  ];

  /// Sign in with email and password.
  /// Throws [AuthException] on invalid credentials.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // Simulate network delay to display loading state
    await Future.delayed(const Duration(milliseconds: 1000));

    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    // 1. Check Team Members
    for (final member in teamMembers) {
      final isMemberEmail = normalizedEmail == member.email.toLowerCase() ||
          normalizedEmail == '${member.email.split('@')[0]}@fitness.com' ||
          normalizedEmail == '${member.email.split('@')[0]}@yourdomain.com' ||
          normalizedEmail == member.name.toLowerCase();

      final isMemberPass = trimmedPassword == '696969' ||
          trimmedPassword == 'pass: 696969' ||
          trimmedPassword == member.password;

      if (isMemberEmail) {
        if (isMemberPass) {
          _currentUser = UserModel(
            id: 'user_${member.name.toLowerCase().replaceAll(' ', '_')}',
            email: member.email,
            name: member.name,
          );
          return _currentUser!;
        } else {
          throw const AuthException('Incorrect password. Use password: 696969');
        }
      }
    }

    // 2. Check Default Legacy / Demo Credentials
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
        'User not found. Use a valid team member or default account.',
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
