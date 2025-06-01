import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> createUserWithEmailPassword({
    required String name, // Add name parameter
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> logout();
  Stream<User?> get userChanges; // Renamed from 'user'
  Future<Either<Failure, User?>> getCurrentUser(); // Added missing method
}

