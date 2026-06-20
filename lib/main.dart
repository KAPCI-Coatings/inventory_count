import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/di/di.dart';
import 'package:inventory_count_flutter_app/core/routes_manger/route_generator.dart';
import 'package:inventory_count_flutter_app/core/routes_manger/routes.dart';
import 'package:inventory_count_flutter_app/features/auth/presentation/view%20models/auth_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'features/auth/presentation/view models/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await initAppModule();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (BuildContext context) => instance<AuthBloc>()..add(const AuthInitializeRequested()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inventory Count',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        onGenerateRoute: RouteGenerator.getRoute,
        initialRoute: Routes.login,
        navigatorKey: RouteGenerator.navigatorKey,
      ),
    );
  }
}
