import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/core/routes_manger/routes.dart';
import 'package:inventory_count_flutter_app/features/auth/presentation/view%20models/auth_bloc.dart';
import 'package:inventory_count_flutter_app/features/auth/presentation/view%20models/auth_state.dart';
import 'package:inventory_count_flutter_app/features/auth/presentation/widgets/login_form.dart';
import 'package:inventory_count_flutter_app/features/auth/presentation/widgets/login_header.dart';
import 'package:inventory_count_flutter_app/features/auth/presentation/widgets/version.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (AuthState previous, AuthState current) {
          return previous.status != current.status ||
              previous.message != current.message;
        },
        listener: (BuildContext context, AuthState state) {
          if (state.status == AuthStatus.authenticated) {
            Navigator.of(context).pushReplacementNamed(Routes.scanner);
            return;
          }


        },
        builder: (BuildContext context, AuthState state) {
          final double pagePadding = ResponsiveUtils.responsiveSpacing(
            context,
            25,
          );
          final double bottomVersionSpace = ResponsiveUtils.responsiveHeight(
            context,
            0.07,
          );
          final bool isKeyboardOpen =
              MediaQuery.of(context).viewInsets.bottom > 0;

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool isCompactLayout =
                  isKeyboardOpen || constraints.maxHeight < 620;
              final bool showVersion = !isCompactLayout && !isKeyboardOpen;
              final double contentPadding = isCompactLayout
                  ? ResponsiveUtils.responsiveSpacing(context, 16)
                  : pagePadding;
              final double sectionGap = isCompactLayout
                  ? ResponsiveUtils.responsiveSpacing(context, 12)
                  : ResponsiveUtils.responsiveHeight(context, 0.08);
              final double loadingGap = isCompactLayout
                  ? ResponsiveUtils.responsiveSpacing(context, 10)
                  : ResponsiveUtils.responsiveHeight(context, 0.02);
              final double reservedBottomSpace = showVersion
                  ? bottomVersionSpace
                  : 0;

              return SafeArea(
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        contentPadding,
                        contentPadding,
                        contentPadding,
                        contentPadding + reservedBottomSpace,
                      ),
                      child: LayoutBuilder(
                        builder:
                            (
                            BuildContext context,
                            BoxConstraints innerConstraints,
                            ) {
                          return ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: innerConstraints.maxHeight,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: isCompactLayout
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.center,
                                children: <Widget>[
                                  LoginHeader(compact: isCompactLayout),
                                  SizedBox(height: sectionGap),
                                  LoginForm(
                                    formKey: _formKey,
                                    passwordController: _passwordController,
                                    compact: isCompactLayout,
                                  ),
                                  if (state.status == AuthStatus.loading)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: loadingGap,
                                      ),
                                      child:
                                      const CircularProgressIndicator(),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (showVersion)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: ResponsiveUtils.responsiveHeight(context, 0.02),
                        child: const Center(child: AuthVersionText()),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
