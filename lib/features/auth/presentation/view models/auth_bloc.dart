import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/features/auth/domain/uescases/change_password_usecase.dart';
import 'package:inventory_count_flutter_app/features/auth/domain/uescases/get_last_role_usecase.dart';
import 'package:inventory_count_flutter_app/features/auth/domain/uescases/initialize_auth_usecase.dart';
import 'package:inventory_count_flutter_app/features/auth/domain/uescases/login_usecase.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final InitializeAuthUseCase _initializeAuth;
  final LoginUseCase _loginUseCase;
  final GetLastRoleUseCase _getLastRoleUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;

  bool _isInitialized = false;

  AuthBloc({
    required InitializeAuthUseCase initializeAuth,
    required LoginUseCase loginUseCase,
    required GetLastRoleUseCase getLastRoleUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
  }) : _initializeAuth = initializeAuth,
       _loginUseCase = loginUseCase,
       _getLastRoleUseCase = getLastRoleUseCase,
       _changePasswordUseCase = changePasswordUseCase,
       super(const AuthState()) {
    on<AuthInitializeRequested>(_onInitializeRequested);
    on<AuthRoleSelected>(_onRoleSelected);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthPasswordChangeRequested>(_onPasswordChangeRequested);
  }

  Future<void> _onInitializeRequested(
    AuthInitializeRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_isInitialized) {
      return;
    }

    await _initializeAuth();

    final String? lastRole = await _getLastRoleUseCase();
    if (lastRole == 'Admin' || lastRole == 'User') {
      emit(state.copyWith(selectedRole: lastRole, message: null));
    }

    _isInitialized = true;
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
          message: 'يرجى إدخال كلمة المرور.',
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
            message: 'بيانات الدخول غير صحيحة.',
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
    } catch (_) {
      emit(
        state.copyWith(status: AuthStatus.error, message: 'فشل تسجيل الدخول.'),
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
          message: 'كلمة المرور لا يمكن أن تكون فارغة.',
        ),
      );
      return;
    }

    final bool changed = await _changePasswordUseCase(
      ChangePasswordParams(
        actorRole: event.actorRole,
        targetRole: event.targetRole,
        newPassword: normalized,
      ),
    );

    if (!changed) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          message: 'فشل تحديث كلمة المرور. يلزم صلاحية الأدمن.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AuthStatus.initial,
        message: 'تم تحديث كلمة مرور ${event.targetRole} بنجاح.',
      ),
    );
  }
}
