import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/utils/colors.dart';
import 'package:inventory_count_flutter_app/core/widgets/custom_dropdown_field.dart';
import 'package:inventory_count_flutter_app/core/widgets/default_button.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_state.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';

import '../../../../../../../core/resources/responsive_utils.dart';
import '../../view_models/auth/auth_bloc.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final FocusNode? passwordFocusNode;
  final bool compact;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.passwordController,
    this.passwordFocusNode,
    this.compact = false,
  });

  String _getLocalizedMessage(BuildContext context, String? message) {
    if (message == null) return '';
    final l10n = AppLocalizations.of(context);
    switch (message) {
      case 'error_initialization': return l10n?.errorInitialization ?? message;
      case 'error_empty_password': return l10n?.errorEmptyPassword ?? message;
      case 'error_invalid_credentials': return l10n?.errorInvalidCredentials ?? message;
      case 'error_login_failed': return l10n?.errorLoginFailed ?? message;
      case 'error_password_update_failed': return l10n?.errorPasswordUpdateFailed ?? message;
      case 'success_password_updated': return l10n?.successPasswordUpdated ?? message;
      default: return message;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double fieldFont = ResponsiveUtils.responsiveFontSize(
      context,
      compact ? 18 : 22,
    );
    final double fieldGap = compact
        ? ResponsiveUtils.responsiveSpacing(context, 12)
        : ResponsiveUtils.responsiveHeight(context, 0.02);
    final double buttonGap = compact
        ? ResponsiveUtils.responsiveSpacing(context, 12)
        : ResponsiveUtils.responsiveHeight(context, 0.03);
    final double buttonHeight = compact
        ? 40
        : ResponsiveUtils.responsiveHeight(context, 0.07).clamp(48, 64);
    final double buttonTextSize = ResponsiveUtils.responsiveFontSize(
      context,
      compact ? 20 : 24,
    );

    final InputDecoration inputDecorationTemplate = InputDecoration(
      isDense: compact,
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.responsiveSpacing(context, 16),
        vertical: compact
            ? ResponsiveUtils.responsiveSpacing(context, 8)
            : ResponsiveUtils.responsiveSpacing(context, 12),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 3),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        fontSize: fieldFont,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );

    return Form(
      key: formKey,
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (AuthState previous, AuthState current) {
          return previous.selectedRole != current.selectedRole ||
              previous.status != current.status ||
              previous.message != current.message;
        },
        builder: (BuildContext context, AuthState state) {
          final bool isLoading = state.status == AuthStatus.loading;
          final bool isError = state.status == AuthStatus.error;

          final Color borderColor = isError ? AppColors.errorRed : Colors.black;

          final InputDecoration dynamicDecoration = inputDecorationTemplate
              .copyWith(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderColor, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: borderColor, width: 2),
                ),
              );

          return Column(
            children: <Widget>[
              CustomDropdownField<String>(
                value: state.selectedRole,
                items: const <String>['Admin', 'User'],
                itemLabelBuilder: (String role) => role,
                onChanged: (String? value) {
                  if (value != null) {
                    context.read<AuthBloc>().add(AuthRoleSelected(value));
                  }
                },
                labelText: l10n?.username ?? 'Username',
                fontSize: fieldFont,
                decoration: dynamicDecoration,
                isLoading: isLoading,
              ),
              SizedBox(height: fieldGap),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  enabled: !isLoading,
                  readOnly: true,
                  showCursor: true,
                  obscureText: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: fieldFont,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: dynamicDecoration.copyWith(labelText: l10n?.password ?? 'Password'),
                ),
              ),
              if (isError && state.message != null)
                Padding(
                  padding: EdgeInsets.only(
                    top: ResponsiveUtils.responsiveSpacing(context, 9),
                  ),
                  child: Text(
                    _getLocalizedMessage(context, state.message),
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.errorRed,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtils.responsiveFontSize(context, 14),
                    ),
                  ),
                ),
              SizedBox(height: buttonGap),
              DefaultButton(
                text: l10n?.login ?? 'Login',
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    context.read<AuthBloc>().add(
                      AuthLoginRequested(passwordController.text),
                    );
                  }
                },
                isLoading: isLoading,
                width: ResponsiveUtils.responsiveWidth(context, 0.4),
                height: buttonHeight,
                textSize: buttonTextSize,
              ),
            ],
          );
        },
      ),
    );
  }
}
