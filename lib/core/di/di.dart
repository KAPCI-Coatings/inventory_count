import 'package:get_it/get_it.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/auth/auth_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/barcode/barcode_bloc.dart';
import 'package:inventory_count_flutter_app/presentation/view_models/settings/settings_bloc.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:inventory_count_flutter_app/data/datasources/auth_local_datasource.dart';
import 'package:inventory_count_flutter_app/data/repositories/auth_repository_impl.dart';
import 'package:inventory_count_flutter_app/domain/repositories/auth_repository.dart';
import 'package:inventory_count_flutter_app/domain/uescases/get_last_role_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/initialize_auth_usecase.dart';
import 'package:inventory_count_flutter_app/domain/uescases/login_usecase.dart';

final GetIt instance = GetIt.instance;

Future<void> initAppModule() async {
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
    () => AuthLocalDataSourceImpl(database: instance(), prefs: instance()),
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

  // Blocs
  instance.registerFactory<AuthBloc>(
    () => AuthBloc(
      initializeAuth: instance<InitializeAuthUseCase>(),
      loginUseCase: instance<LoginUseCase>(),
      getLastRoleUseCase: instance<GetLastRoleUseCase>(),
    ),
  );
  
  instance.registerFactory<BarcodeBloc>(
    () => BarcodeBloc(),
  );

  instance.registerFactory<SettingsBloc>(
    () => SettingsBloc(),
  );
}
