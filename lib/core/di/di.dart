import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:inventory_count_flutter_app/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:inventory_count_flutter_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:inventory_count_flutter_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:inventory_count_flutter_app/features/auth/domain/uescases/change_password_usecase.dart';
import 'package:inventory_count_flutter_app/features/auth/domain/uescases/get_last_role_usecase.dart';
import 'package:inventory_count_flutter_app/features/auth/domain/uescases/initialize_auth_usecase.dart';
import 'package:inventory_count_flutter_app/features/auth/domain/uescases/login_usecase.dart';
import 'package:inventory_count_flutter_app/features/auth/presentation/view%20models/auth_bloc.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

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
    instance.registerLazySingleton<ChangePasswordUseCase>(
      () => ChangePasswordUseCase(instance()),
    );

    // Blocs
    instance.registerFactory<AuthBloc>(
      () => AuthBloc(
        initializeAuth: instance(),
        loginUseCase: instance(),
        getLastRoleUseCase: instance(),
        changePasswordUseCase: instance(),
      ),
    );
  } catch (e) {
    debugPrint("DI Initialization Error: $e");
    rethrow;
  }
}
