import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/widgets/custom_dropdown_field.dart';
import 'package:inventory_count_flutter_app/core/widgets/default_button.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_state.dart';
import 'package:inventory_count_flutter_app/core/routes_manger/routes.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/core/widgets/custom_text_field.dart';
import 'package:inventory_count_flutter_app/core/widgets/screen_title.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _devIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(SettingsLoaded());
  }

  @override
  void dispose() {
    _devIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BlocConsumer<SettingsBloc, SettingsState>(
          listenWhen: (SettingsState previous, SettingsState current) {
            return previous.status != current.status ||
                previous.devId != current.devId;
          },
          listener: (BuildContext context, SettingsState state) {
            if ((state.status == SettingsStatus.success ||
                    state.status == SettingsStatus.initial) &&
                _devIdController.text != state.devId) {
              _devIdController.text = state.devId;
            }

            if (state.status == SettingsStatus.navigateToAssets) {
              Navigator.of(context).pushNamed(Routes.assets);
            } else if (state.status == SettingsStatus.navigateToScanner) {
              Navigator.of(context).pushNamed(Routes.scanner);
            } else if (state.status == SettingsStatus.submitSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.settingsSavedSuccessfully,
                  ),
                ),
              );
            }
          },
          builder: (BuildContext context, SettingsState state) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.responsiveSpacing(context, 32.0),
                vertical: ResponsiveUtils.responsiveSpacing(context, 24.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Title "Settings" (bold, large) at top
                  ScreenTitle(title: AppLocalizations.of(context)!.settings),
                  const Spacer(flex: 2),

                  // 2. Language dropdown field
                  CustomDropdownField<String>(
                    value: state.language,
                    items: const <String>['en', 'ar'],
                    itemLabelBuilder: (String value) => value == 'ar'
                        ? AppLocalizations.of(context)!.arabic
                        : AppLocalizations.of(context)!.english,
                    labelText: AppLocalizations.of(context)!.language,
                    fontSize: 20,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        context.read<SettingsBloc>().add(
                          SettingsLanguageChanged(newValue),
                        );
                      }
                    },
                  ),
                  const Spacer(),

                  // 3. Dev_ID input field
                  CustomTextField(
                    controller: _devIdController,
                    labelText: AppLocalizations.of(context)!.devId,
                    onChanged: (String value) {
                      context.read<SettingsBloc>().add(
                        SettingsDevIdChanged(value),
                      );
                    },
                  ),
                  const Spacer(),

                  // 4. Radio button group
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildRadioOption(
                          context: context,
                          title: AppLocalizations.of(context)!.inventory,
                          value: SettingsOption.inventory,
                          groupValue: state.selectedOption,
                        ),
                        SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
                        _buildRadioOption(
                          context: context,
                          title: AppLocalizations.of(context)!.asset,
                          value: SettingsOption.asset,
                          groupValue: state.selectedOption,
                        ),
                        SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
                        _buildRadioOption(
                          context: context,
                          title: AppLocalizations.of(context)!.rowMaterial,
                          value: SettingsOption.rowMaterial,
                          groupValue: state.selectedOption,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),

                  // 5. Submit button
                  Center(
                    child: DefaultButton(
                      text: AppLocalizations.of(context)!.submit,
                      width: 160,
                      height: 55,
                      textSize: 24,
                      backgroundColor: const Color(0xFF9E9E9E),
                      textColor: Colors.black,
                      borderColor: Colors.black,
                      isLoading: state.status == SettingsStatus.loading,
                      onPressed: () {
                        context.read<SettingsBloc>().add(SettingsSubmitted());
                      },
                    ),
                  ),
                ],
              ),
            );
          },
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
    final bool isSelected = value == groupValue;

    return InkWell(
      onTap: () {
        context.read<SettingsBloc>().add(SettingsOptionChanged(value));
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: isSelected
                ? Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
