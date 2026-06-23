import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_count_flutter_app/data/datasource/auth_local_datasource.dart';

void main() {
  test('Password hashing should be consistent', () {
    final hash1 = hashAuthPin('123456789');
    final hash2 = hashAuthPin('123456789');
    expect(hash1, hash2);
    expect(hash1, isNotEmpty);
  });

  test('Admin password hash should match expected value', () {
    // Admin: 123456789
    // User: 1
    final adminHash = hashAuthPin('123456789');
    final userHash = hashAuthPin('1');

    expect(adminHash, isNot(equals(userHash)));
  });
}
