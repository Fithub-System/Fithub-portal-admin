import 'dart:async';

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
    on<AuthRegisterSubmitted>(_onRegister);
    on<AuthRegisterRequested>(_onShowRegister);
    on<AuthLoginRequested>(_onShowLogin);
    on<AuthOnboardingDeferred>(_onDeferred);
    on<AuthOnboardingResumeRequested>(_onResume);
    on<AuthProfileRefreshRequested>(_onRefresh);
    on<AuthSignOutRequested>(_onSignOut);
  }

  final AuthRepository _authRepository;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final session = _authRepository.currentSession;
    if (session != null) {
      try {
        final profile = await _authRepository.resolveEmployeeProfile().timeout(
          const Duration(seconds: 20),
        );
        emit(AuthAuthenticated(profile));
        return;
      } on AuthFailure catch (e) {
        final cached = await _authRepository.readCachedProfile();
        if (cached != null && cached.isPortalRole) {
          emit(AuthAuthenticated(cached, restoredFromCache: true));
          return;
        }
        emit(AuthUnauthenticated(message: e.message));
        return;
      } catch (_) {
        final cached = await _authRepository.readCachedProfile();
        if (cached != null && cached.isPortalRole) {
          emit(AuthAuthenticated(cached, restoredFromCache: true));
          return;
        }
        emit(const AuthUnauthenticated());
        return;
      }
    }

    // FEAT-01 AC1 — offline restart: bypass login when secure profile cache valid.
    final cached = await _authRepository.readCachedProfile();
    if (cached != null && cached.isPortalRole) {
      emit(AuthAuthenticated(cached, restoredFromCache: true));
      return;
    }

    emit(const AuthUnauthenticated());
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
      emit(const AuthUnauthenticated(message: 'auth.error.unknown'));
    }
  }

  Future<void> _onShowRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthRegisterForm());
  }

  Future<void> _onShowLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthUnauthenticated());
  }

  Future<void> _onRegister(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthRegisterForm(submitting: true));
    try {
      final profile = await _authRepository
          .signUpGymFounder(
            email: event.email,
            password: event.password,
            tradingName: event.tradingName,
          )
          .timeout(const Duration(seconds: 25));
      if (profile == null) {
        emit(AuthAwaitingEmailConfirmation(event.email));
        return;
      }
      emit(AuthAuthenticated(profile));
    } on TimeoutException {
      emit(const AuthRegisterForm(message: 'onboarding.register.timeout'));
    } on AuthFailure catch (e) {
      emit(AuthRegisterForm(message: e.message));
    } catch (_) {
      emit(const AuthRegisterForm(message: 'auth.error.unknown'));
    }
  }

  Future<void> _onDeferred(
    AuthOnboardingDeferred event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is AuthAuthenticated) {
      emit(
        AuthAuthenticated(
          current.profile,
          restoredFromCache: current.restoredFromCache,
          deferOnboarding: true,
        ),
      );
    }
  }

  Future<void> _onResume(
    AuthOnboardingResumeRequested event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is AuthAuthenticated) {
      emit(
        AuthAuthenticated(
          current.profile,
          restoredFromCache: current.restoredFromCache,
        ),
      );
    }
  }

  Future<void> _onRefresh(
    AuthProfileRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final profile = await _authRepository.resolveEmployeeProfile();
      emit(AuthAuthenticated(profile));
    } on AuthFailure catch (e) {
      emit(AuthUnauthenticated(message: e.message));
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
