import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/widgets/default_button.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:inventory_count_flutter_app/core/routes_manger/routes.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/core/widgets/custom_text_field.dart';
import 'package:inventory_count_flutter_app/core/widgets/screen_title.dart';
import 'package:flutter/services.dart';
import 'package:inventory_count_flutter_app/core/widgets/numeric_keypad.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_state.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _devIdController = TextEditingController();
  final FocusNode _devIdFocus = FocusNode();

  final TextEditingController _baseUrlController = TextEditingController();
  final FocusNode _baseUrlFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _devIdFocus.addListener(_onFocusChange);
    _baseUrlFocus.addListener(_onFocusChange);
    context.read<SettingsBloc>().add(SettingsLoaded());
  }

  void _onFocusChange() {
    setState(() {});
  }

  void _onDigitPressed(String digit) {
    final text = _devIdController.text;
    final selection = _devIdController.selection;

    if (selection.start >= 0 && selection.end >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, digit);
      _devIdController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + 1),
      );
    } else {
      _devIdController.text = text + digit;
    }
    context.read<SettingsBloc>().add(SettingsDevIdChanged(_devIdController.text));
  }

  void _onDeletePressed() {
    final text = _devIdController.text;
    final selection = _devIdController.selection;

    if (selection.start > 0 && selection.start == selection.end) {
      final newText = text.replaceRange(selection.start - 1, selection.end, '');
      _devIdController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start - 1),
      );
    } else if (selection.start >= 0 && selection.end > selection.start) {
      final newText = text.replaceRange(selection.start, selection.end, '');
      _devIdController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
    }
    context.read<SettingsBloc>().add(SettingsDevIdChanged(_devIdController.text));
  }

  @override
  void dispose() {
    _devIdController.dispose();
    _devIdFocus.dispose();
    _baseUrlController.dispose();
    _baseUrlFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.responsiveSpacing(context, 28.0),
            vertical: ResponsiveUtils.responsiveSpacing(context, 16.0),
          ),
          child: BlocConsumer<SettingsBloc, SettingsState>(
            listenWhen: (previous, current) {
              if (previous.status == SettingsStatus.loading &&
                  current.status == SettingsStatus.initial) {
                if (_devIdController.text != current.devId) {
                  _devIdController.text = current.devId;
                }
                if (_baseUrlController.text != current.baseUrl) {
                  _baseUrlController.text = current.baseUrl;
                }
              }
              return previous.status != current.status;
            },
            listener: (context, state) {
              if (!mounted || !context.mounted) return;
              try {
                final route = ModalRoute.of(context);
                if (route != null && !route.isCurrent) return;
              } catch (_) {
                return;
              }

              if (state.status == SettingsStatus.error) {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.errorMessage ??
                            AppLocalizations.of(context)!.error_save_settings,
                      ),
                    ),
                  );
                } catch (_) {}
              } else if (state.status == SettingsStatus.saved) {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.settingsSavedSuccessfully,
                      ),
                    ),
                  );
                } catch (_) {}
                if (state.selectedOption == SettingsOption.asset) {
                  Navigator.of(context).pushNamedAndRemoveUntil(Routes.assets, (route) => false);
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(Routes.barcode, (route) => false);
                }
              }
            },
            builder: (context, state) {
              final bool keypadVisible = _devIdFocus.hasFocus;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // ── Title ──────────────────────────────────────────────────
                          ScreenTitle(title: AppLocalizations.of(context)!.settings),
                  const SizedBox(height: 12),

                  // ── Dev ID ─────────────────────────────────────────────────
                  CustomTextField(
                    controller: _devIdController,
                    focusNode: _devIdFocus,
                    labelText: AppLocalizations.of(context)!.devId,
                    keyboardType: TextInputType.none,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    height: 44,
                    onChanged: (String value) {
                      context
                          .read<SettingsBloc>()
                          .add(SettingsDevIdChanged(value));
                    },
                  ),
                  const SizedBox(height: 10),

                  // ── Base URL ───────────────────────────────────────────────
                  CustomTextField(
                    controller: _baseUrlController,
                    focusNode: _baseUrlFocus,
                    labelText: AppLocalizations.of(context)!.baseUrl,
                    keyboardType: TextInputType.url,
                    hintText: 'http://10.10.30.47:2604',

                    height: 44,
                    onChanged: (String value) {
                      context
                          .read<SettingsBloc>()
                          .add(SettingsBaseUrlChanged(value));
                    },
                  ),
                  const SizedBox(height: 10),

                  // ── Radio Options (Row 1: Inventory + Asset) ───────────────
                  Row(
                    children: <Widget>[
                      _buildRadioOption(
                        context: context,
                        title: AppLocalizations.of(context)!.inventory,
                        value: SettingsOption.inventory,
                        groupValue: state.selectedOption,
                      ),
                      const SizedBox(width: 8),
                      _buildRadioOption(
                        context: context,
                        title: AppLocalizations.of(context)!.asset,
                        value: SettingsOption.asset,
                        groupValue: state.selectedOption,
                      ),
                    ],
                  ),

                  // ── Radio Options (Row 2: Raw Material) ───────────────────
                  _buildRadioOption(
                    context: context,
                    title: AppLocalizations.of(context)!.rowMaterial,
                    value: SettingsOption.rawMaterial,
                    groupValue: state.selectedOption,
                  ),
                  const SizedBox(height: 12),

                  // ── Submit ─────────────────────────────────────────────────
                  Center(
                    child: DefaultButton(
                      text: AppLocalizations.of(context)!.submit,
                      width: 140,
                      height: 48,
                      textSize: 20,
                      backgroundColor: const Color(0xFF9E9E9E),
                      textColor: Colors.black,
                      borderColor: Colors.black,
                      isLoading: state.status == SettingsStatus.loading,
                      onPressed: () {
                        _devIdFocus.unfocus();
                        _baseUrlFocus.unfocus();
                        context.read<SettingsBloc>().add(SettingsSubmitted());
                      },
                    ),
                  ),
                        ],
                      ),
                    ),
                  ),

                  // ── Numeric Keypad (only when Dev ID is focused) ───────────
                  if (keypadVisible) ...[
                    const SizedBox(height: 8),
                    NumericKeypad(
                      onDigitPressed: _onDigitPressed,
                      onDeletePressed: _onDeletePressed,
                      onSubmitPressed: () => _devIdFocus.unfocus(),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required BuildContext context,
    required String title,
    required SettingsOption value,
    required SettingsOption groupValue,
  }) {
    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        onTap: () {
          context.read<SettingsBloc>().add(SettingsDataTypeChanged(value));
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Radio<SettingsOption>(
                value: value,
                groupValue: groupValue,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (val) {
                  if (val != null) {
                    context.read<SettingsBloc>().add(SettingsDataTypeChanged(val));
                  }
                },
                activeColor: Colors.black,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
