import 'package:get_it/get_it.dart';
import 'package:inventory_count_flutter_app/core/services/api_service.dart';
import 'package:inventory_count_flutter_app/core/services/csv_export_service.dart';
import 'package:inventory_count_flutter_app/core/services/scanner_service.dart';
import 'package:inventory_count_flutter_app/core/services/zebra_scanner_service.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/search/search_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_bloc.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:inventory_count_flutter_app/data/datasources/auth_local_datasource.dart';
import 'package:inventory_count_flutter_app/data/datasources/barcode_local_datasource.dart';
import 'package:inventory_count_flutter_app/data/datasources/asset_local_datasource.dart';
import 'package:inventory_count_flutter_app/data/datasources/settings_local_datasource.dart';
import 'package:inventory_count_flutter_app/data/repositories/auth_repository_impl.dart';
import 'package:inventory_count_flutter_app/domain/repositories/auth_repository.dart';
import 'package:inventory_count_flutter_app/domain/uescases/get_last_role_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/initialize_auth_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/is_logged_in_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/login_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/logout_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/process_barcode_usecase.dart';
import 'package:inventory_count_flutter_app/domain/repositories/barcode_repository.dart';
import 'package:inventory_count_flutter_app/data/repositories/barcode_repository_impl.dart';

final GetIt instance = GetIt.instance;

/// The Android applicationId of this app — must match the value in
/// android/app/build.gradle (applicationId / namespace).
const String _androidPackageName = 'com.kapci.inventory';

Future<void> initAppModule() async {
  // ── Scanner Service ─────────────────────────────────────────────────────
  // Registered FIRST so it is available before anything else tries to use it.
  // The rest of the app depends on [ScannerService] (the abstract interface),
  // NOT on [ZebraScannerService] directly.
  // To swap the scanner package: just replace ZebraScannerService with your
  // new implementation — nothing else in the app changes.
  instance.registerLazySingleton<ScannerService>(
    () => ZebraScannerService(
      androidPackageName: _androidPackageName,
      profileName: 'KAPCI_INVENTORY_PROFILE',
    ),
  );

  instance.registerLazySingleton<CsvExportService>(() => CsvExportService());
  instance.registerLazySingleton<ApiService>(() => ApiService());

  // ── External ──────────────────────────────────────────────────────────────
  final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  instance.registerLazySingleton<SharedPreferences>(() => sharedPrefs);

  final String path = join(await getDatabasesPath(), 'inventory_count.db');
  final Database database = await openDatabase(
    path, 
    version: 2,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('DROP TABLE IF EXISTS barcodes');
      }
    },
  );

  // Ensure table exists even if DB was previously created (for auth)
  await database.execute('''
    CREATE TABLE IF NOT EXISTS barcodes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      barCodeNo TEXT,
      matnr TEXT,
      batchNo TEXT,
      serialNo TEXT,
      palletBox TEXT,
      qty INTEGER,
      isPallet INTEGER
    )
  ''');

  await database.execute('''
    CREATE TABLE IF NOT EXISTS asset_scans (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      barcode TEXT NOT NULL,
      scannedAt TEXT NOT NULL
    )
  ''');

  instance.registerLazySingleton<Database>(() => database);

  // Data Sources
  instance.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(database: instance(), prefs: instance()),
  );
  instance.registerLazySingleton<BarcodeLocalDataSource>(
    () => BarcodeLocalDataSourceImpl(instance()),
  );
  instance.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(instance()),
  );
  instance.registerLazySingleton<AssetLocalDataSource>(
    () => AssetLocalDataSourceImpl(instance()),
  );

  // Repositories
  instance.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: instance()),
  );
  instance.registerLazySingleton<BarcodeRepository>(
    () => BarcodeRepositoryImpl(instance()),
  );

  // Use Cases
  instance.registerLazySingleton<InitializeAuthUseCase>(
    () => InitializeAuthUseCase(instance()),
  );
  instance.registerLazySingleton<LoginUseCase>(() => LoginUseCase(instance()));
  instance.registerLazySingleton<GetLastRoleUseCase>(
    () => GetLastRoleUseCase(instance()),
  );
  instance.registerLazySingleton<ProcessBarcodeUseCase>(
    () => ProcessBarcodeUseCase(instance()),
  );
  instance.registerLazySingleton<IsLoggedInUseCase>(
    () => IsLoggedInUseCase(instance()),
  );
  instance.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(instance()),
  );

  // Blocs
  instance.registerFactory<AuthBloc>(
    () => AuthBloc(
      initializeAuth: instance<InitializeAuthUseCase>(),
      loginUseCase: instance<LoginUseCase>(),
      getLastRoleUseCase: instance<GetLastRoleUseCase>(),
      isLoggedInUseCase: instance<IsLoggedInUseCase>(),
      logoutUseCase: instance<LogoutUseCase>(),
    ),
  );

  instance.registerFactory<BarcodeBloc>(
    () => BarcodeBloc(
      instance<ScannerService>(),
      instance<ProcessBarcodeUseCase>(),
      instance<ApiService>(),
      instance<SettingsLocalDataSource>(),
      instance<BarcodeRepository>(),
    ),
  );

  instance.registerFactory<SettingsBloc>(
    () => SettingsBloc(instance()),
  );

  instance.registerFactory<SearchBloc>(() => SearchBloc(instance()));
}
