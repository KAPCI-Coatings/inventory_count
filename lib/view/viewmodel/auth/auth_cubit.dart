import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/domain/usecase/change_password_usecase.dart';
import 'package:inventory_count_flutter_app/domain/usecase/get_last_role_usecase.dart';
import 'package:inventory_count_flutter_app/domain/usecase/initialize_auth_usecase.dart';
import 'package:inventory_count_flutter_app/domain/usecase/login_usecase.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final InitializeAuthUseCase _initializeAuth;
  final LoginUseCase _loginUseCase;
  final GetLastRoleUseCase _getLastRoleUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;

  bool _isInitialized = false;

  AuthCubit({
    required InitializeAuthUseCase initializeAuth,
    required LoginUseCase loginUseCase,
    required GetLastRoleUseCase getLastRoleUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
  }) : _initializeAuth = initializeAuth,
       _loginUseCase = loginUseCase,
       _getLastRoleUseCase = getLastRoleUseCase,
       _changePasswordUseCase = changePasswordUseCase,
       super(const AuthState());

  Future<void> initialize() async {
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

  void selectRole(String role) {
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

  Future<void> login({required String password}) async {
    final String normalizedPassword = password.trim();
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

  Future<bool> changePassword({
    required String actorRole,
    required String targetRole,
    required String newPassword,
  }) async {
    final String normalized = newPassword.trim();
    if (normalized.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          message: 'كلمة المرور لا يمكن أن تكون فارغة.',
        ),
      );
      return false;
    }

    final bool changed = await _changePasswordUseCase(
      ChangePasswordParams(
        actorRole: actorRole,
        targetRole: targetRole,
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
      return false;
    }

    emit(
      state.copyWith(
        status: AuthStatus.initial,
        message: 'تم تحديث كلمة مرور $targetRole بنجاح.',
      ),
    );
    return true;
  }
}
