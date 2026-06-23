import 'package:get_it/get_it.dart';
import 'package:inventory_count_flutter_app/data/datasource/auth_local_datasource.dart';
import 'package:inventory_count_flutter_app/data/datasource/datawedge_datasource.dart';
import 'package:inventory_count_flutter_app/data/repositories/auth_repository_impl.dart';
import 'package:inventory_count_flutter_app/domain/repositories/auth_repository.dart';
import 'package:inventory_count_flutter_app/domain/uescases/change_password_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/get_last_role_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/get_scanner_settings_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/initialize_auth_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/initialize_scanner_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/login_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/observe_scans_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/save_scanner_cache_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/save_scanner_settings_usecase.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_bloc.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:zebra_wedge_scanner/zebra_datawedge.dart';

import 'package:inventory_count_flutter_app/data/datasource/scanner_datasource.dart';
import 'package:inventory_count_flutter_app/data/datasource/scanner_remote_datasource.dart';
import 'package:inventory_count_flutter_app/data/repositories/scanner_repository_impl.dart';
import 'package:inventory_count_flutter_app/domain/repositories/scanner_repository.dart';
import 'package:inventory_count_flutter_app/domain/uescases/clear_scanner_cache_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/disable_scanner_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/enable_scanner_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/load_scanner_cache_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/post_handling_details_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/switch_profile_usecase.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/scanner/scanner_bloc.dart';

final GetIt instance = GetIt.instance;

Future<void> initAppModule() async {
  try {
    // External
    final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    instance.registerLazySingleton<SharedPreferences>(() => sharedPrefs);

    final String path = join(await getDatabasesPath(), 'inventory_count.db');
    final Database database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Tables will be created by DataSources if they use CREATE TABLE IF NOT EXISTS
      },
    );
    instance.registerLazySingleton<Database>(() => database);

    // Data Sources
    instance.registerLazySingleton<AuthLocalDataSource>(
          () =>
          AuthLocalDataSourceImpl(database: instance(), prefs: instance()),
    );

    // Repositories
    instance.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(localDataSource: instance()),
    );

    // Use Cases
    instance.registerLazySingleton<InitializeAuthUseCase>(
          () => InitializeAuthUseCase(instance()),
    );
    instance.registerLazySingleton<LoginUseCase>(
          () => LoginUseCase(instance()),
    );
    instance.registerLazySingleton<GetLastRoleUseCase>(
          () => GetLastRoleUseCase(instance()),
    );
    instance.registerLazySingleton<ChangePasswordUseCase>(
          () => ChangePasswordUseCase(instance()),
    );

    // Blocs
    instance.registerFactory<AuthBloc>(
          () =>
          AuthBloc(
            initializeAuth: instance(),
            loginUseCase: instance(),
            getLastRoleUseCase: instance(),
            changePasswordUseCase: instance(),
          ),
    );

    // --- Scanner Feature ---

    // External
    instance.registerLazySingleton<http.Client>(() => http.Client());
    instance.registerLazySingleton<ZebraDataWedge>(() => ZebraDataWedge());

    // Data Sources
    instance.registerLazySingleton<DataWedgeDataSource>(
          () => DataWedgeDataSourceImpl(instance()),
    );
    instance.registerLazySingleton<ScannerPrefsDataSource>(
          () => ScannerDataSourceImpl(instance()),
    );
    instance.registerLazySingleton<ScannerRemoteDataSource>(
          () => ScannerRemoteDataSourceImpl(instance()),
    );

    // Repository
    instance.registerLazySingleton<ScannerRepository>(
          () => ScannerRepositoryImpl(
        dwDataSource: instance(),
        prefsDataSource: instance(),
        remoteDataSource: instance(),
      ),
    );

    // Use Cases
    instance.registerLazySingleton<ClearScannerCacheUseCase>(
          () => ClearScannerCacheUseCase(instance()),
    );
    instance.registerLazySingleton<DisableScannerUseCase>(
          () => DisableScannerUseCase(instance()),
    );
    instance.registerLazySingleton<EnableScannerUseCase>(
          () => EnableScannerUseCase(instance()),
    );
    instance.registerLazySingleton<GetScannerSettingsUseCase>(
          () => GetScannerSettingsUseCase(instance()),
    );
    instance.registerLazySingleton<InitializeScannerUseCase>(
          () => InitializeScannerUseCase(instance()),
    );
    instance.registerLazySingleton<LoadScannerCacheUseCase>(
          () => LoadScannerCacheUseCase(instance()),
    );
    instance.registerLazySingleton<ObserveScansUseCase>(
          () => ObserveScansUseCase(instance()),
    );
    instance.registerLazySingleton<PostHandlingDetailsUseCase>(
          () => PostHandlingDetailsUseCase(instance()),
    );
    instance.registerLazySingleton<SaveScannerCacheUseCase>(
          () => SaveScannerCacheUseCase(instance()),
    );
    instance.registerLazySingleton<SaveScannerSettingsUseCase>(
          () => SaveScannerSettingsUseCase(instance()),
    );
    instance.registerLazySingleton<SwitchProfileUseCase>(
          () => SwitchProfileUseCase(instance()),
    );

    // Scanner Bloc
    instance.registerFactory<ScannerBloc>(
          () => ScannerBloc(
        initializeScanner: instance(),
        observeScans: instance(),
        enableScanner: instance(),
        disableScanner: instance(),
        switchProfile: instance(),
        getScannerSettings: instance(),
        saveScannerSettings: instance(),
        loadScannerCache: instance(),
        saveScannerCache: instance(),
        clearScannerCache: instance(),
        postHandlingDetails: instance(),
      ),
    );
  } catch (e) {
    // Handle or log initialization error
    rethrow;
  }
}
