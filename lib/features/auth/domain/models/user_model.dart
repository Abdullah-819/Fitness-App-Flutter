class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? phone;
  final String? gender;
  final bool? isSedentary;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final int? dailyStepGoal;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.phone,
    this.gender,
    this.isSedentary,
    this.age,
    this.heightCm,
    this.weightKg,
    this.dailyStepGoal,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? phone,
    String? gender,
    bool? isSedentary,
    int? age,
    double? heightCm,
    double? weightKg,
    int? dailyStepGoal,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      isSedentary: isSedentary ?? this.isSedentary,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, email: $email, name: $name, goal: $dailyStepGoal)';
}

