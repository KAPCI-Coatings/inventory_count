import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/domain/uescases/get_last_role_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/initialize_auth_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/login_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/is_logged_in_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/logout_usecase.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final InitializeAuthUseCase _initializeAuth;
  final LoginUseCase _loginUseCase;
  final GetLastRoleUseCase _getLastRoleUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;
  final LogoutUseCase _logoutUseCase;

  bool _isInitialized = false;

  AuthBloc({
    required InitializeAuthUseCase initializeAuth,
    required LoginUseCase loginUseCase,
    required GetLastRoleUseCase getLastRoleUseCase,
    required IsLoggedInUseCase isLoggedInUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _initializeAuth = initializeAuth,
       _loginUseCase = loginUseCase,
       _getLastRoleUseCase = getLastRoleUseCase,
       _isLoggedInUseCase = isLoggedInUseCase,
       _logoutUseCase = logoutUseCase,
       super(const AuthState()) {
    on<AuthInitializeRequested>(_onInitializeRequested);
    on<AuthRoleSelected>(_onRoleSelected);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthPasswordChangeRequested>(_onPasswordChangeRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onInitializeRequested(
    AuthInitializeRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_isInitialized) {
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, message: null));

    try {
      await _initializeAuth();

      final bool isLoggedIn = await _isLoggedInUseCase();
      final String? lastRole = await _getLastRoleUseCase();

      if (isLoggedIn && lastRole != null && (lastRole == 'Admin' || lastRole == 'User')) {
        emit(state.copyWith(selectedRole: lastRole, status: AuthStatus.authenticated, message: null));
      } else {
        if (lastRole == 'Admin' || lastRole == 'User') {
          emit(state.copyWith(selectedRole: lastRole, status: AuthStatus.initial, message: null));
        } else {
          emit(state.copyWith(status: AuthStatus.initial, message: null));
        }
      }

      _isInitialized = true;
    } catch (e, stackTrace) {
      debugPrint('Auth initialization error: $e\n$stackTrace');
      emit(state.copyWith(status: AuthStatus.error, message: 'error_initialization'));
    }
  }

  void _onRoleSelected(AuthRoleSelected event, Emitter<AuthState> emit) {
    final role = event.role;
    if (role != 'Admin' && role != 'User') {
      return;
    }

    emit(
      state.copyWith(
        selectedRole: role,
        status: AuthStatus.initial,
        message: null,
      ),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final String normalizedPassword = event.password.trim();
    if (normalizedPassword.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          message: 'error_empty_password',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, message: null));

    try {
      final user = await _loginUseCase(
        LoginParams(role: state.selectedRole, password: normalizedPassword),
      );

      if (user == null) {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            message: 'error_invalid_credentials',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          selectedRole: user.role,
          message: null,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Login error: $e\n$stackTrace');
      emit(
        state.copyWith(status: AuthStatus.error, message: 'error_login_failed'),
      );
    }
  }

  Future<void> _onPasswordChangeRequested(
    AuthPasswordChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    final String normalized = event.newPassword.trim();
    if (normalized.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          message: 'error_empty_password',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading, message: null));

    try {
      emit(
        state.copyWith(
          status: AuthStatus.initial,
          message: 'success_password_updated',
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Password change error: $e\n$stackTrace');
      emit(
        state.copyWith(status: AuthStatus.error, message: 'error_password_update_failed'),
      );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, message: null));
    try {
      await _logoutUseCase();
      emit(
        state.copyWith(
          status: AuthStatus.initial,
          message: null,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Logout error: $e\n$stackTrace');
      emit(state.copyWith(status: AuthStatus.error, message: 'error_logout_failed'));
    }
  }
}
