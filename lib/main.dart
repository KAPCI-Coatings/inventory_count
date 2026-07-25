import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_count_flutter_app/core/di/di.dart';
import 'package:inventory_count_flutter_app/core/services/scanner_service.dart';
import 'package:inventory_count_flutter_app/core/routes_manger/route_generator.dart';
import 'package:inventory_count_flutter_app/core/routes_manger/routes.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/search/search_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/search/search_event.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_event.dart';
import 'package:inventory_count_flutter_app/l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await initAppModule();
  
  try {
    await instance<ScannerService>().initialize();
  } on ScannerUnavailableException catch (e) {
    debugPrint(e.message);
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (BuildContext context) =>
              instance<AuthBloc>()..add(const AuthInitializeRequested()),
        ),
        BlocProvider<BarcodeBloc>(
          create: (BuildContext context) =>
              instance<BarcodeBloc>()..add(BarcodeInitializeRequested()),
        ),
        BlocProvider<SettingsBloc>(
          create: (BuildContext context) =>
              instance<SettingsBloc>()..add(SettingsLoaded()),
        ),
        BlocProvider<SearchBloc>(
          create: (BuildContext context) =>
              instance<SearchBloc>()..add(SearchInitialized()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inventory Count',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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
