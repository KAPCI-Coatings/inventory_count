import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:inventory_count_flutter_app/features/auth/data/models/auth_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

String hashAuthPin(String value) {
  return sha256.convert(utf8.encode(value)).toString();
}

abstract class AuthLocalDataSource {
  Future<void> initializeUsers();

  Future<AuthUserModel?> getUserByRole(String role);

  Future<bool> updatePassword({required String role, required String password});

  Future<void> saveSession({required String role});

  Future<String?> getLastRole();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _usersTable = 'auth_users';
  static const String _columnRole = 'role';
  static const String _columnPasswordHash = 'password_hash';

  static const String _prefLastRole = 'auth_last_role';
  static const String _prefIsLoggedIn = 'auth_is_logged_in';
  static const String _prefLastLoginAt = 'auth_last_login_at';

  final Database _database;
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl({
    required Database database,
    required SharedPreferences prefs,
  }) : _database = database,
       _prefs = prefs;

  @override
  Future<void> initializeUsers() async {
    await _database.execute(
      'CREATE TABLE IF NOT EXISTS $_usersTable ('
      '$_columnRole TEXT PRIMARY KEY, '
      '$_columnPasswordHash TEXT NOT NULL'
      ')',
    );

    final Batch batch = _database.batch();

    batch.insert(
      _usersTable,
      AuthUserModel(
        role: 'Admin',
        passwordHash: hashAuthPin('123456789'),
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    batch.insert(
      _usersTable,
      AuthUserModel(role: 'User', passwordHash: hashAuthPin('11')).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await batch.commit(noResult: true);
  }

  @override
  Future<AuthUserModel?> getUserByRole(String role) async {
    final List<Map<String, Object?>> rows = await _database.query(
      _usersTable,
      columns: <String>[_columnRole, _columnPasswordHash],
      where: '$_columnRole = ?',
      whereArgs: <Object?>[role],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return AuthUserModel.fromMap(rows.first);
  }

  @override
  Future<bool> updatePassword({
    required String role,
    required String password,
  }) async {
    if (role != 'Admin' && role != 'User') {
      return false;
    }

    if (password.trim().isEmpty) {
      return false;
    }

    final int updated = await _database.update(
      _usersTable,
      <String, Object?>{_columnPasswordHash: hashAuthPin(password)},
      where: '$_columnRole = ?',
      whereArgs: <Object?>[role],
    );

    return updated > 0;
  }

  @override
  Future<void> saveSession({required String role}) async {
    await _prefs.setString(_prefLastRole, role);
    await _prefs.setBool(_prefIsLoggedIn, true);
    await _prefs.setString(_prefLastLoginAt, DateTime.now().toIso8601String());
  }

  @override
  Future<String?> getLastRole() async {
    return _prefs.getString(_prefLastRole);
  }
}
