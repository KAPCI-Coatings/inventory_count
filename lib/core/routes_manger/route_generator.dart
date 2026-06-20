import 'package:flutter/material.dart';
import 'package:inventory_count_flutter_app/features/auth/presentation/views/login_page.dart';

import 'routes.dart';

class RouteGenerator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic>? getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return _buildRoute(const LoginPage());
      case Routes.scanner:
        // For now, return a placeholder or LoginPage if scanner page is not ready
        return _buildRoute(const Scaffold(body: Center(child: Text('Scanner Page Placeholder'))));
      default:
        return _buildRoute(const LoginPage());
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}