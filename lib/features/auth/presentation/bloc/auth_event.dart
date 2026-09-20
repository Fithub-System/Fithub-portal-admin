part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthSignInSubmitted extends AuthEvent {
  const AuthSignInSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

final class AuthRegisterSubmitted extends AuthEvent {
  const AuthRegisterSubmitted({
    required this.email,
    required this.password,
    required this.tradingName,
  });

  final String email;
  final String password;
  final String tradingName;

  @override
  List<Object?> get props => [email, password, tradingName];
}

final class AuthOnboardingDeferred extends AuthEvent {
  const AuthOnboardingDeferred();
}

final class AuthOnboardingResumeRequested extends AuthEvent {
  const AuthOnboardingResumeRequested();
}

final class AuthProfileRefreshRequested extends AuthEvent {
  const AuthProfileRefreshRequested();
}
