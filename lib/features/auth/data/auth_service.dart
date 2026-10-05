import 'dart:async';

import '../../../core/config/app_config.dart';
import '../domain/models/user_model.dart';
import 'phone_account_store.dart';
import 'session_store.dart';

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

  UserModel? _user;
  UserModel? get currentUser => _user;
  bool get isAuthenticated => _user != null;

  UserModel? get _currentUser => _user;

  /// Every assignment keeps the saved session in sync: signing in or up
  /// saves it, signing out (null) clears it.
  set _currentUser(UserModel? value) {
    _user = value;
    if (value == null) {
      SessionStore.instance.clearSession();
    } else {
      SessionStore.instance.saveSession(value);
    }
  }

  /// Loads the user saved by a previous run, if they never logged out.
  Future<UserModel?> restoreSession() async {
    _user = await SessionStore.instance.loadSession();
    return _user;
  }

  /// Replaces the current user (e.g. after onboarding) and remembers their
  /// profile for future sign-ins.
  Future<void> updateCurrentUser(UserModel user) async {
    _currentUser = user;
    await SessionStore.instance.saveProfile(user);
  }

  /// Restores a previously saved profile (gender, age, goal...) onto a
  /// freshly signed-in user.
  Future<UserModel> _mergeProfile(UserModel user) async {
    final saved = await SessionStore.instance.loadProfile(user.id);
    final merged = saved == null
        ? user
        : user.copyWith(
            avatarUrl: saved.avatarUrl,
            gender: saved.gender,
            isSedentary: saved.isSedentary,
            age: saved.age,
            heightCm: saved.heightCm,
            weightKg: saved.weightKg,
            dailyStepGoal: saved.dailyStepGoal,
          );
    _currentUser = merged;
    await SessionStore.instance.saveProfile(merged);
    return merged;
  }

  static String _emailId(String normalizedEmail) =>
      'user_${normalizedEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}';

  static String _nameFromEmail(String normalizedEmail) {
    final name = normalizedEmail
        .split('@')[0]
        .replaceAll(RegExp(r'[._]'), ' ')
        .split(' ')
        .where((s) => s.isNotEmpty)
        .map((s) => '${s[0].toUpperCase()}${s.substring(1)}')
        .join(' ');
    return name.isNotEmpty ? name : 'TrackFit User';
  }

  /// Default demo credentials
  static const String defaultEmail = 'andrew.ainsley@yourdomain.com';
  static const String defaultPassword = 'password123';
  static const String defaultName = 'Andrew Ainsley';

  /// Static OTP code for testing until Firebase is connected
  static const String staticOtp = '1234';

  /// Dynamic storage for updated user passwords
  final Map<String, String> _customPasswords = {};

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

  /// Verifies an OTP code (checks against static OTP '1234')
  bool verifyOtp({required String email, required String otp}) {
    // The fixed demo code only exists in the staging build.
    return AppConfig.isStaging && otp.trim() == staticOtp;
  }

  /// Updates the password for a given user email so subsequent logins work with this password
  void updatePassword({required String email, required String newPassword}) {
    _customPasswords[email.trim().toLowerCase()] = newPassword.trim();
  }

  /// Sign in with email and password.
  /// Throws [AuthException] on invalid credentials.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final accountKey = 'email:$normalizedEmail';
    final store = PhoneAccountStore.instance;

    // 1. Accounts created through Sign Up (both builds).
    if (await store.exists(accountKey)) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!await store.verify(accountKey, password.trim())) {
        throw const AuthException('Incorrect password. Please try again.');
      }
      _currentUser = UserModel(
        id: _emailId(normalizedEmail),
        email: normalizedEmail,
        name: _nameFromEmail(normalizedEmail),
      );
      return _mergeProfile(_currentUser!);
    }

    // 2. Demo / team accounts exist only in the staging build.
    if (AppConfig.isStaging) {
      return _mergeProfile(await _signInDemo(email: email, password: password));
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    throw const AuthException(
      'No account found for this email. Please sign up first.',
    );
  }

  /// Staging-only sign in against the built-in demo and team accounts.
  Future<UserModel> _signInDemo({
    required String email,
    required String password,
  }) async {
    // Simulate network delay to display loading state
    await Future.delayed(const Duration(milliseconds: 1000));

    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    // 0. Check custom updated passwords first (from forgot password flow)
    if (_customPasswords.containsKey(normalizedEmail)) {
      if (trimmedPassword == _customPasswords[normalizedEmail]) {
        // Derive or lookup name
        String userName = defaultName;
        for (final m in teamMembers) {
          if (m.email.toLowerCase() == normalizedEmail) {
            userName = m.name;
            break;
          }
        }
        _currentUser = UserModel(
          id: 'user_${normalizedEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
          email: normalizedEmail,
          name: userName,
        );
        return _currentUser!;
      } else {
        throw const AuthException('Incorrect password. Please try again.');
      }
    }

    // 1. Check Team Members
    for (final member in teamMembers) {
      final isMemberEmail =
          normalizedEmail == member.email.toLowerCase() ||
          normalizedEmail == '${member.email.split('@')[0]}@fitness.com' ||
          normalizedEmail == '${member.email.split('@')[0]}@yourdomain.com' ||
          normalizedEmail == member.name.toLowerCase();

      final isMemberPass =
          trimmedPassword == '696969' ||
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
    final isDefaultEmail =
        normalizedEmail == defaultEmail.toLowerCase() ||
        normalizedEmail == 'user@fitness.com' ||
        normalizedEmail == 'admin@fitness.com';

    final isDefaultPassword =
        trimmedPassword == defaultPassword ||
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

  /// Sign up / register a new user with email and password.
  /// Throws [AuthException] on invalid input.
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    // Simulate network delay to match design 8_Light_sign up loading.png
    await Future.delayed(const Duration(milliseconds: 1000));

    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    if (normalizedEmail.isEmpty) {
      throw const AuthException('Please enter your email address.');
    }

    if (!normalizedEmail.contains('@') || !normalizedEmail.contains('.')) {
      throw const AuthException('Please enter a valid email address.');
    }

    if (trimmedPassword.isEmpty) {
      throw const AuthException('Please enter a password.');
    }

    if (trimmedPassword.length < 6) {
      throw const AuthException('Password must be at least 6 characters long.');
    }

    final accountKey = 'email:$normalizedEmail';
    if (AppConfig.isProduction &&
        await PhoneAccountStore.instance.exists(accountKey)) {
      throw const AuthException(
        'An account with this email already exists. Please sign in.',
      );
    }
    await PhoneAccountStore.instance.register(accountKey, trimmedPassword);

    // Determine user name from email or provided name
    final derivedName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : normalizedEmail
              .split('@')[0]
              .replaceAll(RegExp(r'[._]'), ' ')
              .split(' ')
              .where((s) => s.isNotEmpty)
              .map((s) => '${s[0].toUpperCase()}${s.substring(1)}')
              .join(' ');

    _currentUser = UserModel(
      id: _emailId(normalizedEmail),
      email: normalizedEmail,
      name: derivedName.isNotEmpty ? derivedName : 'TrackFit User',
    );

    return _currentUser!;
  }

  /// Sign up with a phone number (already validated/normalised, e.g.
  /// +923006789089) and password.
  /// Throws [AuthException] on invalid input.
  Future<UserModel> signUpWithPhone({
    required String phone,
    required String password,
    String? name,
  }) async {
    // Simulate network delay to match design 8_Light_sign up loading.png
    await Future.delayed(const Duration(milliseconds: 1000));

    final trimmedPassword = password.trim();

    if (!RegExp(r'^\+923\d{9}$').hasMatch(phone)) {
      throw const AuthException('Please enter a valid Pakistani phone number.');
    }

    if (trimmedPassword.length < 6) {
      throw const AuthException('Password must be at least 6 characters long.');
    }

    if (AppConfig.isProduction &&
        await PhoneAccountStore.instance.exists(phone)) {
      throw const AuthException(
        'An account with this number already exists. Please sign in.',
      );
    }
    await PhoneAccountStore.instance.register(phone, trimmedPassword);

    _currentUser = UserModel(
      id: 'user_phone_${phone.replaceAll('+', '')}',
      email: '',
      phone: phone,
      name: (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : 'TrackFit User',
    );

    return _currentUser!;
  }

  /// Sign in with a phone number (normalised, e.g. +923006789089) and
  /// password. Throws [AuthException] if the account is unknown or the
  /// password is wrong.
  Future<UserModel> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    // Simulate network delay to display loading state
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!RegExp(r'^\+923\d{9}$').hasMatch(phone)) {
      throw const AuthException('Please enter a valid Pakistani phone number.');
    }

    final store = PhoneAccountStore.instance;
    if (!await store.exists(phone)) {
      throw const AuthException(
        'No account found for this number. Please sign up first.',
      );
    }
    if (!await store.verify(phone, password.trim())) {
      throw const AuthException('Incorrect password. Please try again.');
    }

    _currentUser = UserModel(
      id: 'user_phone_${phone.replaceAll('+', '')}',
      email: '',
      phone: phone,
      name: 'TrackFit User',
    );
    return _mergeProfile(_currentUser!);
  }

  /// Checks if an email corresponds to a registered account (demo or team members).
  bool isEmailRegistered(String email) {
    final normalized = email.trim().toLowerCase();
    if (normalized == defaultEmail.toLowerCase() ||
        normalized == 'user@fitness.com' ||
        normalized == 'admin@fitness.com') {
      return true;
    }
    for (final member in teamMembers) {
      if (normalized == member.email.toLowerCase() ||
          normalized == '${member.email.split('@')[0]}@fitness.com' ||
          normalized == '${member.email.split('@')[0]}@yourdomain.com' ||
          normalized == member.name.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  /// Sends password reset OTP to registered email.
  Future<void> sendPasswordResetOtp(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 900));

    final normalized = email.trim().toLowerCase();

    if (normalized.isEmpty) {
      throw const AuthException('Please enter your email address.');
    }

    if (!normalized.contains('@') || !normalized.contains('.')) {
      throw const AuthException('Please enter a valid email address.');
    }

    if (!isEmailRegistered(normalized)) {
      throw const AuthException(
        'No account found with this email. Please check and try again.',
      );
    }
  }

  /// Sign out the current user
  void signOut() {
    _currentUser = null;
  }
}
