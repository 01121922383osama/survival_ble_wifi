import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class CreateUserWithEmailPassword implements UseCase<User, CreateUserParams> {
  final AuthRepository repository;

  CreateUserWithEmailPassword(this.repository);

  @override
  Future<Either<Failure, User>> call(CreateUserParams params) async {
    // FIX: Pass parameters using named arguments as required by the repository method
    return await repository.createUserWithEmailPassword(
      name: params.name, // Pass name
      email: params.email,
      password: params.password,
    );
  }
}

class CreateUserParams extends Equatable {
  final String name; // FIX: Add name field
  final String email;
  final String password;

  // FIX: Update constructor to include name
  const CreateUserParams({required this.name, required this.email, required this.password});

  @override
  // FIX: Update props to include name
  List<Object> get props => [name, email, password];
}

