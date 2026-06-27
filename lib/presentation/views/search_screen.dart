import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/di/di.dart';
import 'package:inventory_count_flutter_app/core/resources/responsive_utils.dart';
import 'package:inventory_count_flutter_app/core/widgets/custom_dropdown_field.dart';
import 'package:inventory_count_flutter_app/core/widgets/custom_text_field.dart';
import 'package:inventory_count_flutter_app/core/widgets/default_button.dart';
import 'package:inventory_count_flutter_app/core/widgets/screen_title.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/search/search_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/search/search_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/search/search_state.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/search/search_results_table.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>(
      create: (context) => instance<SearchBloc>()..add(SearchDataLoaded()),
      child: const _SearchContentView(),
    );
  }
}

class _SearchContentView extends StatefulWidget {
  const _SearchContentView();

  @override
  State<_SearchContentView> createState() => _SearchContentViewState();
}

class _SearchContentViewState extends State<_SearchContentView> {
  final TextEditingController _materialController = TextEditingController();

  @override
  void dispose() {
    _materialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset:
          false, // Prevents overflow when keyboard is open
      body: SafeArea(
        child: BlocConsumer<SearchBloc, SearchState>(
          listenWhen: (previous, current) =>
              previous.material != current.material && current.material.isEmpty,
          listener: (context, state) {
            _materialController.clear();
          },
          builder: (context, state) {
            return Padding(
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
                          labelText: AppLocalizations.of(context)!.material,
                          keyboardType: TextInputType.number,
                          height: 45,
                          onChanged: (value) {
                            context.read<SearchBloc>().add(
                              SearchMaterialChanged(value),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveUtils.responsiveSpacing(context, 12),
                      ),
                      Expanded(
                        flex: 5,
                        child: CustomDropdownField<String>(
                          value: state.selectedBatch ?? 'All',
                          items: [
                            'All',
                            ...state.availableBatches.where((b) => b != 'All'),
                          ],
                          itemLabelBuilder: (value) => value == 'All'
                              ? AppLocalizations.of(context)!.selectedPatch
                              : value,
                          labelText: AppLocalizations.of(context)!.filterPatch,
                          fontSize: 16,
                          height: 45,
                          decoration: InputDecoration(
                            isDense: true,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
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
                          onChanged: (value) {
                            if (value != null) {
                              context.read<SearchBloc>().add(
                                SearchBatchFilterChanged(value),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ResponsiveUtils.responsiveSpacing(context, 12),
                  ),

                  // 4. Table
                  Expanded(
                    child: state.status == SearchStatus.loading
                        ? const Center(child: CircularProgressIndicator())
                        : SearchResultsTable(
                            items: state.filteredItems,
                            totalQty: state.totalQty,
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
                            context.read<SearchBloc>().add(
                              SearchClearRequested(),
                            );
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
                          onPressed: () {
                            context.read<SearchBloc>().add(
                              SearchSubmitClicked(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
