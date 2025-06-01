import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailPassword implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginWithEmailPassword(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    // FIX: Pass parameters using named arguments as required by the repository method
    return await repository.loginWithEmailPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

