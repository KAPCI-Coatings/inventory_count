import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthState extends Equatable {
  static const Object _noValue = Object();

  final AuthStatus status;
  final String selectedRole;
  final String? message;

  const AuthState({
    this.status = AuthStatus.initial,
    this.selectedRole = 'Admin',
    this.message,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? selectedRole,
    Object? message = _noValue,
  }) {
    return AuthState(
      status: status ?? this.status,
      selectedRole: selectedRole ?? this.selectedRole,
      message: identical(message, _noValue) ? this.message : message as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, selectedRole, message];
}
