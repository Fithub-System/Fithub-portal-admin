part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(
    this.profile, {
    this.restoredFromCache = false,
    this.deferOnboarding = false,
  });

  final EmployeeProfile profile;
  final bool restoredFromCache;
  final bool deferOnboarding;

  bool get showOnboardingWizard => profile.needsOnboarding && !deferOnboarding;

  @override
  List<Object?> get props => [profile, restoredFromCache, deferOnboarding];
}

final class AuthAwaitingEmailConfirmation extends AuthState {
  const AuthAwaitingEmailConfirmation(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}
