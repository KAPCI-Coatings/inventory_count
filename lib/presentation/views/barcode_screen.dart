import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/barcode/barcode_actions_section.dart';
import 'package:inventory_count_flutter_app/presentation/widgets/barcode/barcode_status_section.dart';
import '../../core/resources/responsive_utils.dart';
import '../widgets/barcode/barcode_app_bar.dart';

class BarcodeScreen extends StatelessWidget {
  const BarcodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarcodeAppBar(),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final double pagePadding = ResponsiveUtils.responsiveSpacing(
              context,
              16,
            );

            return Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(pagePadding),
                  child: Column(
                    children: <Widget>[
                      const BarcodeStatusSection(),
                      const Spacer(),
                      const BarcodeActionsSection(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
