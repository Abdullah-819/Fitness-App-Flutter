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

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'avatarUrl': avatarUrl,
    'phone': phone,
    'gender': gender,
    'isSedentary': isSedentary,
    'age': age,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'dailyStepGoal': dailyStepGoal,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    email: json['email'] as String? ?? '',
    name: json['name'] as String? ?? 'TrackFit User',
    avatarUrl: json['avatarUrl'] as String?,
    phone: json['phone'] as String?,
    gender: json['gender'] as String?,
    isSedentary: json['isSedentary'] as bool?,
    age: (json['age'] as num?)?.toInt(),
    heightCm: (json['heightCm'] as num?)?.toDouble(),
    weightKg: (json['weightKg'] as num?)?.toDouble(),
    dailyStepGoal: (json['dailyStepGoal'] as num?)?.toInt(),
  );

  /// True once onboarding (gender, goal, ...) has been completed.
  bool get isProfileComplete => gender != null && dailyStepGoal != null;

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
  String toString() =>
      'UserModel(id: $id, email: $email, name: $name, goal: $dailyStepGoal)';
}
