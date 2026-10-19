import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String role;

  const AuthUser({required this.role});

  @override
  List<Object?> get props => <Object?>[role];
}
