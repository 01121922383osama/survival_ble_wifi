import 'dart:async';
import 'package:survival/core/usecases/usecase.dart';
import 'package:survival/features/auth/domain/entities/user.dart';
import 'package:survival/features/auth/domain/repositories/auth_repository.dart';

class UserChanges implements StreamUseCase<User?, NoParams> {
  final AuthRepository repository;

  UserChanges(this.repository);

  @override
  Stream<User?> call(NoParams params) {
    // FIX: Use the correct getter 'userChanges' from the repository interface
    return repository.userChanges;
  }
}

