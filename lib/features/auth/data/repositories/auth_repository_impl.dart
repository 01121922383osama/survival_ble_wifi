import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:survival/features/auth/domain/entities/user.dart';
import 'package:survival/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:survival/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  @override
  Future<Either<Failure, User>> createUserWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        // Update user profile with name (optional but good practice)
        await userCredential.user!.updateDisplayName(name);
        // Return custom User entity
        return Right(User(
          id: userCredential.user!.uid, // Use uid from firebase user for id
          email: userCredential.user!.email!,
          name: name, // Use the provided name
        ));
      } else {
        // FIX: Use correct constructor call for ServerFailure
        return Left(ServerFailure("Failed to create user account."));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      // FIX: Use correct constructor call for ServerFailure
      return Left(ServerFailure(e.message ?? "An unknown error occurred during signup."));
    } catch (e) {
      // FIX: Use correct constructor call for ServerFailure
      return Left(ServerFailure("An unexpected error occurred during signup: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        // Return custom User entity
        return Right(User(
          id: userCredential.user!.uid, // Use uid from firebase user for id
          email: userCredential.user!.email!,
          name: userCredential.user!.displayName, // Get name from Firebase profile
        ));
      } else {
        // FIX: Use correct constructor call for ServerFailure
        return Left(ServerFailure("Failed to log in."));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      // FIX: Use correct constructor call for ServerFailure
      return Left(ServerFailure(e.message ?? "An unknown error occurred during login."));
    } catch (e) {
      // FIX: Use correct constructor call for ServerFailure
      return Left(ServerFailure("An unexpected error occurred during login: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      // FIX: Use correct constructor call for ServerFailure
      return Left(ServerFailure(e.message ?? "An unknown error occurred during logout."));
    } catch (e) {
      // FIX: Use correct constructor call for ServerFailure
      return Left(ServerFailure("An unexpected error occurred during logout: ${e.toString()}"));
    }
  }

  @override // Correctly overrides the getter from the interface
  Stream<User?> get userChanges => _firebaseAuth.authStateChanges().map((firebaseUser) {
        if (firebaseUser == null) {
          return null;
        } else {
          // Map FirebaseUser to custom User entity
          return User(
            id: firebaseUser.uid,
            email: firebaseUser.email!,
            name: firebaseUser.displayName,
          );
        }
      });

  @override // Correctly overrides the method from the interface
  Future<Either<Failure, User?>> getCurrentUser() async {
     try {
      final firebaseUser = _firebaseAuth.currentUser;
       if (firebaseUser == null) {
          return const Right(null);
        } else {
          // Map FirebaseUser to custom User entity
          return Right(User(
            id: firebaseUser.uid,
            email: firebaseUser.email!,
            name: firebaseUser.displayName,
          ));
        }
    } catch (e) {
      // FIX: Use correct constructor call for ServerFailure
      return Left(ServerFailure("Failed to get current user: ${e.toString()}"));
    }
  }
}

