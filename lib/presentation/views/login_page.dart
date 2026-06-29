import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/core/routes_manger/routes.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_state.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/auth/login_form.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/auth/login_header.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/auth/version.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_state.dart';
import 'package:inventory_count_flutter_app/core/widgets/numeric_keypad.dart';

import '../view_models/auth/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _passwordFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _onDigitPressed(String digit) {
    final text = _passwordController.text;
    final selection = _passwordController.selection;
    
    if (selection.start >= 0 && selection.end >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, digit);
      _passwordController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + 1),
      );
    } else {
      _passwordController.text = text + digit;
    }
  }

  void _onDeletePressed() {
    final text = _passwordController.text;
    final selection = _passwordController.selection;
    
    if (selection.start > 0 && selection.start == selection.end) {
      final newText = text.replaceRange(selection.start - 1, selection.end, '');
      _passwordController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start - 1),
      );
    } else if (selection.start >= 0 && selection.end > selection.start) {
      final newText = text.replaceRange(selection.start, selection.end, '');
      _passwordController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (AuthState previous, AuthState current) {
          return previous.status != current.status ||
              previous.message != current.message;
        },
        buildWhen: (AuthState previous, AuthState current) {
          return previous.status != current.status ||
              previous.message != current.message;
        },
        listener: (BuildContext context, AuthState state) {
          if (state.status == AuthStatus.authenticated) {
            final SettingsState settingsState = context.read<SettingsBloc>().state;
            if (settingsState.selectedOption == SettingsOption.asset) {
              Navigator.of(context).pushReplacementNamed(Routes.assets);
            } else {
              Navigator.of(context).pushReplacementNamed(Routes.barcode);
            }
            return;
          }
        },
        builder: (BuildContext context, AuthState state) {
          final double pagePadding = ResponsiveUtils.responsiveSpacing(
            context,
            30,
          );
          final bool isKeyboardOpen =
              MediaQuery.of(context).viewInsets.bottom > 0 || _passwordFocus.hasFocus;

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool isCompactLayout =
                  isKeyboardOpen || constraints.maxHeight < 620;
              final double contentPadding = isCompactLayout
                  ? ResponsiveUtils.responsiveSpacing(context, 16)
                  : pagePadding;
              final double loadingGap = isCompactLayout
                  ? ResponsiveUtils.responsiveSpacing(context, 10)
                  : ResponsiveUtils.responsiveHeight(context, 0.02);

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(contentPadding),
                  child: Column(
                    children: <Widget>[
                      if (!isKeyboardOpen)
                        LoginHeader(compact: isCompactLayout),
                      Expanded(
                        child: Align(
                          alignment: isKeyboardOpen
                              ? Alignment.topCenter
                              : Alignment.center,
                          child: SingleChildScrollView(
                            physics: isKeyboardOpen
                                ? const NeverScrollableScrollPhysics()
                                : null,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LoginForm(
                                  formKey: _formKey,
                                  passwordController: _passwordController,
                                  passwordFocusNode: _passwordFocus,
                                  compact: isCompactLayout,
                                ),
                                if (state.status == AuthStatus.loading)
                                  Padding(
                                    padding: EdgeInsets.only(top: loadingGap),
                                    child: const CircularProgressIndicator(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!isKeyboardOpen && !_passwordFocus.hasFocus)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: ResponsiveUtils.responsiveHeight(context, 0.01),
                          ),
                          child: const AuthVersionText(),
                        ),
                      if (_passwordFocus.hasFocus)
                        NumericKeypad(
                          onDigitPressed: _onDigitPressed,
                          onDeletePressed: _onDeletePressed,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
