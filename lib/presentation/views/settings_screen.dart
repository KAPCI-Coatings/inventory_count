import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/core/widgets/custom_dropdown_field.dart';
import 'package:inventory_count_flutter_app/core/widgets/default_button.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:inventory_count_flutter_app/core/routes_manger/routes.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/core/widgets/custom_text_field.dart';
import 'package:inventory_count_flutter_app/core/widgets/screen_title.dart';
import 'package:flutter/services.dart';
import 'package:inventory_count_flutter_app/core/widgets/numeric_keypad.dart';

enum SettingsOption { inventory, asset, rawMaterial }

class _AppInputDecoration {
  static InputDecoration standard() {
    return InputDecoration(
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
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _devIdController = TextEditingController();
  final FocusNode _devIdFocus = FocusNode();

  String _language = 'en';
  SettingsOption _selectedOption = SettingsOption.inventory;

  @override
  void initState() {
    super.initState();
    _devIdFocus.addListener(_onFocusChange);
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
  }

  @override
  void dispose() {
    _devIdController.dispose();
    _devIdFocus.dispose();
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
                value: _language,
                items: const <String>['en', 'ar'],
                itemLabelBuilder: (String value) => value == 'ar'
                    ? AppLocalizations.of(context)!.arabic
                    : AppLocalizations.of(context)!.english,
                labelText: AppLocalizations.of(context)!.language,
                fontSize: 20,
                decoration: _AppInputDecoration.standard(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _language = newValue;
                    });
                  }
                },
              ),
              const Spacer(),

              // 3. Dev_ID input field
              CustomTextField(
                controller: _devIdController,
                focusNode: _devIdFocus,
                labelText: AppLocalizations.of(context)!.devId,
                keyboardType: TextInputType.none,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (String value) {},
              ),
              if (!_devIdFocus.hasFocus) const Spacer(),

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
                      groupValue: _selectedOption,
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
                    _buildRadioOption(
                      context: context,
                      title: AppLocalizations.of(context)!.asset,
                      value: SettingsOption.asset,
                      groupValue: _selectedOption,
                    ),
                    SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 12)),
                    _buildRadioOption(
                      context: context,
                      title: AppLocalizations.of(context)!.rowMaterial,
                      value: SettingsOption.rawMaterial,
                      groupValue: _selectedOption,
                    ),
                  ],
                ),
              ),
              if (!_devIdFocus.hasFocus) const Spacer(flex: 2),

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
                  isLoading: false,
                  onPressed: () {
                    if (_selectedOption == SettingsOption.asset) {
                      Navigator.of(context).pushNamed(Routes.assets);
                    } else {
                      Navigator.of(context).pushNamed(Routes.barcode);
                    }
                  },
                ),
              ),
              if (_devIdFocus.hasFocus) ...[
                SizedBox(height: ResponsiveUtils.responsiveSpacing(context, 16)),
                NumericKeypad(
                  onDigitPressed: _onDigitPressed,
                  onDeletePressed: _onDeletePressed,
                ),
              ],
            ],
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
          setState(() {
            _selectedOption = value;
          });
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Radio<SettingsOption>(
              value: value,
              groupValue: groupValue,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedOption = val;
                  });
                }
              },
              activeColor: Colors.black,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
