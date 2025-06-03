import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:survival/core/error/failures.dart';
import 'package:survival/core/services/notification_service.dart';
import 'package:survival/features/auth/domain/entities/user.dart';
import 'package:survival/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._firebaseAuth, [FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

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
        final user = userCredential.user!;

        // Update user profile with name
        await user.updateDisplayName(name);

        // get the fcm token
        final fcmToken = await NotificationService().getFcmTokenAndroidAndIos();

        // Create user data map for Firestore
        final userData = User(
          id: user.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          avatarUrl: '',
          deviceToken: fcmToken,
        );

        // Save user data to Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userData.toFirestore(), SetOptions(merge: true));

        // Return custom User entity
        return Right(User(id: user.uid, email: user.email!, name: name));
      } else {
        // FIX: Use correct constructor call for ServerFailure
        return Left(ServerFailure("Failed to create user account."));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      // FIX: Use correct constructor call for ServerFailure
      return Left(
        ServerFailure(e.message ?? "An unknown error occurred during signup."),
      );
    } catch (e) {
      // FIX: Use correct constructor call for ServerFailure
      return Left(
        ServerFailure(
          "An unexpected error occurred during signup: ${e.toString()}",
        ),
      );
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
        return Right(
          User(
            id: userCredential.user!.uid, // Use uid from firebase user for id
            email: userCredential.user!.email!,
            name: userCredential
                .user!
                .displayName, // Get name from Firebase profile
          ),
        );
      } else {
        // FIX: Use correct constructor call for ServerFailure
        return Left(ServerFailure("Failed to log in."));
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      // FIX: Use correct constructor call for ServerFailure
      return Left(
        ServerFailure(e.message ?? "An unknown error occurred during login."),
      );
    } catch (e) {
      // FIX: Use correct constructor call for ServerFailure
      return Left(
        ServerFailure(
          "An unexpected error occurred during login: ${e.toString()}",
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      // FIX: Use correct constructor call for ServerFailure
      return Left(
        ServerFailure(e.message ?? "An unknown error occurred during logout."),
      );
    } catch (e) {
      // FIX: Use correct constructor call for ServerFailure
      return Left(
        ServerFailure(
          "An unexpected error occurred during logout: ${e.toString()}",
        ),
      );
    }
  }

  @override // Correctly overrides the getter from the interface
  Stream<User?> get userChanges =>
      _firebaseAuth.authStateChanges().map((firebaseUser) {
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
        return Right(
          User(
            id: firebaseUser.uid,
            email: firebaseUser.email!,
            name: firebaseUser.displayName,
          ),
        );
      }
    } catch (e) {
      // FIX: Use correct constructor call for ServerFailure
      return Left(ServerFailure("Failed to get current user: ${e.toString()}"));
    }
  }
}
