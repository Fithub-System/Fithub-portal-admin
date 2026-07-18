import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fithub_portal_admin/features/auth/domain/auth_failure.dart';
import 'package:fithub_portal_admin/features/auth/domain/entities/employee_profile.dart';
import 'package:fithub_portal_admin/features/auth/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInSubmitted>(_onSignIn);
    on<AuthSignOutRequested>(_onSignOut);
  }

  final AuthRepository _authRepository;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final session = _authRepository.currentSession;
    if (session == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      final profile = await _authRepository.resolveEmployeeProfile();
      emit(AuthAuthenticated(profile));
    } on AuthFailure catch (e) {
      emit(AuthUnauthenticated(message: e.message));
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignIn(
    AuthSignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final profile = await _authRepository.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(profile));
    } on AuthFailure catch (e) {
      emit(AuthUnauthenticated(message: e.message));
    } catch (_) {
      emit(const AuthUnauthenticated(message: 'Authentication failed.'));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(const AuthUnauthenticated());
  }
}
