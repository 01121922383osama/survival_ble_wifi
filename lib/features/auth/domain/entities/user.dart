import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id; // Renamed from uid
  final String? email;
  final String? name; // Added name property
  final String? avatarUrl;
  final String? deviceToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    this.email,
    this.name,
    this.avatarUrl,
    this.deviceToken,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    avatarUrl,
    deviceToken,
    createdAt,
    updatedAt,
  ];

  // Optional: Add copyWith method for easier updates
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? deviceToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      deviceToken: deviceToken ?? this.deviceToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'deviceToken': deviceToken,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
