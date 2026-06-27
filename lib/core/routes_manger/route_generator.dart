import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/presentation/views/login_page.dart';
import 'package:inventory_count_flutter_app/presentation/views/scanner_screen.dart';
import 'package:inventory_count_flutter_app/presentation/views/settings_screen.dart';
import 'package:inventory_count_flutter_app/presentation/views/assets_screen.dart';
import 'package:inventory_count_flutter_app/presentation/views/search_screen.dart';

import 'routes.dart';

class RouteGenerator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic>? getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return _buildRoute(const LoginPage());
      case Routes.scanner:
        return _buildRoute(const ScannerScreen());
      case Routes.settings:
        return _buildRoute(const SettingsScreen());
      case Routes.assets:
        return _buildRoute(const AssetsScreen());
      case Routes.search:
        return _buildRoute(const SearchScreen());
      default:
        return _buildRoute(const LoginPage());
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
