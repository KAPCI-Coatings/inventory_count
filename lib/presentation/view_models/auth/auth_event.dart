import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthInitializeRequested extends AuthEvent {
  const AuthInitializeRequested();
}

class AuthRoleSelected extends AuthEvent {
  final String role;

  const AuthRoleSelected(this.role);

  @override
  List<Object?> get props => [role];
}

class AuthLoginRequested extends AuthEvent {
  final String password;

  const AuthLoginRequested(this.password);

  @override
  List<Object?> get props => [password];
}

class AuthPasswordChangeRequested extends AuthEvent {
  final String actorRole;
  final String targetRole;
  final String newPassword;

  const AuthPasswordChangeRequested({
    required this.actorRole,
    required this.targetRole,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [actorRole, targetRole, newPassword];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
