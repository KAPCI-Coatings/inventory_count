import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/core/widgets/custom_text_field.dart';
import 'package:inventory_count_flutter_app/core/widgets/numeric_keypad.dart';
import 'package:inventory_count_flutter_app/core/widgets/default_button.dart';
import 'package:inventory_count_flutter_app/core/widgets/screen_title.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/search/search_results_table.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SearchContentView();
  }
}

class _SearchContentView extends StatefulWidget {
  const _SearchContentView();

  @override
  State<_SearchContentView> createState() => _SearchContentViewState();
}

class _SearchContentViewState extends State<_SearchContentView> {
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  
  final FocusNode _materialFocus = FocusNode();
  final FocusNode _batchFocus = FocusNode();
  TextEditingController? _activeController;

  @override
  void initState() {
    super.initState();
    _materialFocus.addListener(_onFocusChange);
    _batchFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_materialFocus.hasFocus) {
      setState(() => _activeController = _materialController);
    } else if (_batchFocus.hasFocus) {
      setState(() => _activeController = _batchController);
    } else {
      setState(() => _activeController = null);
    }
  }

  @override
  void dispose() {
    _materialController.dispose();
    _batchController.dispose();
    _materialFocus.dispose();
    _batchFocus.dispose();
    super.dispose();
  }

  void _onDigitPressed(String digit) {
    final controller = _activeController;
    if (controller == null) return;
    
    final text = controller.text;
    final selection = controller.selection;
    
    if (selection.start >= 0 && selection.end >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, digit);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + 1),
      );
    } else {
      controller.text = text + digit;
    }
  }

  void _onDeletePressed() {
    final controller = _activeController;
    if (controller == null) return;
    
    final text = controller.text;
    final selection = controller.selection;
    
    if (selection.start > 0 && selection.start == selection.end) {
      final newText = text.replaceRange(selection.start - 1, selection.end, '');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start - 1),
      );
    } else if (selection.start >= 0 && selection.end > selection.start) {
      final newText = text.replaceRange(selection.start, selection.end, '');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.responsiveSpacing(context, 12.0),
            vertical: ResponsiveUtils.responsiveSpacing(context, 12.0),
          ),
          child: Column(
            children: [
              // 1. Title with Back Arrow
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 30,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: ScreenTitle(
                        title: AppLocalizations.of(context)!.search,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: ResponsiveUtils.responsiveSpacing(context, 12),
              ),

              // 2. Material Input and Batch Dropdown Side-by-Side
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      controller: _materialController,
                      focusNode: _materialFocus,
                      labelText: AppLocalizations.of(context)!.material,
                      keyboardType: TextInputType.none,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      height: 45,
                      onChanged: (value) {},
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.responsiveSpacing(context, 12),
                  ),
                  Expanded(
                    flex: 5,
                    child: CustomTextField(
                      controller: _batchController,
                      focusNode: _batchFocus,
                      labelText: AppLocalizations.of(context)!.filterPatch,
                      keyboardType: TextInputType.none,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      height: 45,
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: ResponsiveUtils.responsiveSpacing(context, 12),
              ),

              // 4. Table
              const Expanded(
                child: SearchResultsTable(
                  items: [],
                  totalQty: 0,
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.responsiveSpacing(context, 8),
              ),

              // 5. Buttons Row
              Row(
                children: [
                  Expanded(
                    child: DefaultButton(
                      text: AppLocalizations.of(context)!.clear,
                      height: ResponsiveUtils.responsiveHeight(
                        context,
                        0.06,
                      ).clamp(36, 48),
                      textSize: ResponsiveUtils.responsiveFontSize(
                        context,
                        18,
                      ),
                      backgroundColor: Colors.grey.shade400,
                      textColor: Colors.black,
                      onPressed: () {
                        _materialController.clear();
                        _batchController.clear();
                      },
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.responsiveSpacing(context, 16),
                  ),
                  Expanded(
                    child: DefaultButton(
                      text: AppLocalizations.of(context)!.search,
                      height: ResponsiveUtils.responsiveHeight(
                        context,
                        0.06,
                      ).clamp(36, 48),
                      textSize: ResponsiveUtils.responsiveFontSize(
                        context,
                        18,
                      ),
                      backgroundColor: const Color(
                        0xFFAFAFAF,
                      ), // Grey button
                      textColor: Colors.black,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              if (_activeController != null) ...[
                SizedBox(
                  height: ResponsiveUtils.responsiveSpacing(context, 16),
                ),
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
}
