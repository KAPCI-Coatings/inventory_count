import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/utils/colors.dart';
import 'package:inventory_count_flutter_app/view/viewmodel/auth/auth_cubit.dart';
import 'package:inventory_count_flutter_app/view/viewmodel/auth/auth_state.dart';

import '../../../../core/resources/responsive_utils.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final bool compact;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.passwordController,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double fieldFont = ResponsiveUtils.responsiveFontSize(
      context,
      compact ? 16 : 19,
    );
    final double fieldGap = compact
        ? ResponsiveUtils.responsiveSpacing(context, 10)
        : ResponsiveUtils.responsiveHeight(context, 0.02);
    final double buttonGap = compact
        ? ResponsiveUtils.responsiveSpacing(context, 10)
        : ResponsiveUtils.responsiveHeight(context, 0.02);
    final double buttonHeight = compact
        ? 56
        : ResponsiveUtils.responsiveHeight(context, 0.09).clamp(56, 76);
    final double buttonTextSize = ResponsiveUtils.responsiveFontSize(
      context,
      compact ? 20 : 25,
    );

    return Form(
      key: formKey,
      child: BlocBuilder<AuthCubit, AuthState>(
        buildWhen: (AuthState previous, AuthState current) {
          return previous.selectedRole != current.selectedRole ||
              previous.status != current.status;
        },
        builder: (BuildContext context, AuthState state) {
          final bool isLoading = state.status == AuthStatus.loading;

          return Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: state.selectedRole,
                style: textTheme.bodyMedium?.copyWith(fontSize: fieldFont),
                decoration: InputDecoration(
                  isDense: compact,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.responsiveSpacing(context, 12),
                    vertical: compact
                        ? ResponsiveUtils.responsiveSpacing(context, 12)
                        : ResponsiveUtils.responsiveSpacing(context, 16),
                  ),
                  labelText: 'Username',
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    fontSize: fieldFont,
                  ),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: AppColors.infoBlue,
                  ),
                ),
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: 'Admin',
                    child: Text(
                      'Admin',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: fieldFont,
                      ),
                    ),
                  ),
                  DropdownMenuItem<String>(
                    value: 'User',
                    child: Text(
                      'User',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: fieldFont,
                      ),
                    ),
                  ),
                ],
                onChanged: isLoading
                    ? null
                    : (String? value) {
                        if (value == null) {
                          return;
                        }
                        context.read<AuthCubit>().selectRole(value);
                      },
              ),
              SizedBox(height: fieldGap),
              TextFormField(
                controller: passwordController,
                enabled: !isLoading,
                obscureText: true,
                keyboardType: TextInputType.number,
                style: textTheme.bodyMedium?.copyWith(fontSize: fieldFont),
                decoration: InputDecoration(
                  isDense: compact,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.responsiveSpacing(context, 12),
                    vertical: compact
                        ? ResponsiveUtils.responsiveSpacing(context, 12)
                        : ResponsiveUtils.responsiveSpacing(context, 16),
                  ),
                  labelText: 'كلمة المرور',
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    fontSize: fieldFont,
                  ),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock, color: AppColors.infoBlue),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور.';
                  }
                  return null;
                },
              ),
              SizedBox(height: buttonGap),
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.infoBlue,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.greyLight300,
                    disabledForegroundColor: AppColors.greyDark700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.responsiveRadius(context, 12),
                      ),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          if (formKey.currentState?.validate() ?? false) {
                            context.read<AuthCubit>().login(
                              password: passwordController.text,
                            );
                          }
                        },
                  child: Text(
                    'دخول',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: buttonTextSize,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
