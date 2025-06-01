import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:survival/core/error/failures.dart';
import 'package:survival/core/usecases/usecase.dart';
import 'package:survival/features/auth/domain/entities/user.dart';
import 'package:survival/features/auth/domain/usecases/create_user_with_email_password.dart';
import 'package:survival/features/auth/domain/usecases/get_current_user.dart';
import 'package:survival/features/auth/domain/usecases/login_with_email_password.dart';
import 'package:survival/features/auth/domain/usecases/logout.dart';
import 'package:survival/features/auth/domain/usecases/user_changes.dart';
import 'package:survival/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final CreateUserWithEmailPassword _createUserWithEmailPassword;
  final LoginWithEmailPassword _loginWithEmailPassword;
  final Logout _logout;
  final GetCurrentUser _getCurrentUser;
  final UserChanges _userChanges;
  StreamSubscription<User?>? _userSubscription;

  AuthCubit({
    required CreateUserWithEmailPassword createUserWithEmailPassword,
    required LoginWithEmailPassword loginWithEmailPassword,
    required Logout logout,
    required GetCurrentUser getCurrentUser,
    required UserChanges userChanges,
  }) : _createUserWithEmailPassword = createUserWithEmailPassword,
       _loginWithEmailPassword = loginWithEmailPassword,
       _logout = logout,
       _getCurrentUser = getCurrentUser,
       _userChanges = userChanges,
       super(AuthInitial());

  Future<void> appStarted() async {
    emit(AuthLoading());
    // Listen to user changes stream
    _userSubscription?.cancel();
    _userSubscription = _userChanges(NoParams()).listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });

    // Check current user status immediately
    final result = await _getCurrentUser(NoParams());
    result.fold(
      (failure) => emit(
        Unauthenticated(),
      ), // If error getting user, assume unauthenticated
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> createUserWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await _createUserWithEmailPassword(
      CreateUserParams(name: name, email: email, password: password),
    );
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await _loginWithEmailPassword(
      LoginParams(email: email, password: password),
    );
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> logoutUser() async {
    emit(AuthLoading());
    final result = await _logout(NoParams());
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (_) => emit(Unauthenticated()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message;
      // Add other failure types if needed
      default:
        return 'An unexpected error occurred';
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
