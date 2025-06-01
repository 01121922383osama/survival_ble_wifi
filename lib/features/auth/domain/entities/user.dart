import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id; // Renamed from uid
  final String? email;
  final String? name; // Added name property
  final String? avatarUrl;

  const User({required this.id, this.email, this.name, this.avatarUrl});

  @override
  List<Object?> get props => [id, email, name, avatarUrl];

  // Optional: Add copyWith method for easier updates
  User copyWith({String? id, String? email, String? name, String? avatarUrl}) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
