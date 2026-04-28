// test/shared/models/user_travel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/user_travel.dart';

void main() {
  group('UserWithRole', () {
    // Sequelize join format: user fields at top level, role in UserTravel.role
    final json = {
      'id': 1,
      'username': 'alice',
      'avatar': null,
      'name': 'Alice',
      'UserTravel': {'role': 'manage'},
    };

    test('fromJson parses user fields from top level', () {
      final uwr = UserWithRole.fromJson(json);
      expect(uwr.user.id, 1);
      expect(uwr.user.username, 'alice');
      expect(uwr.user.name, 'Alice');
    });

    test('fromJson parses role from UserTravel', () {
      final uwr = UserWithRole.fromJson(json);
      expect(uwr.role, RoleType.manage);
    });

    test('fromJson parses edit role', () {
      final j = Map<String, dynamic>.from(json)
        ..['UserTravel'] = {'role': 'edit'};
      expect(UserWithRole.fromJson(j).role, RoleType.edit);
    });

    test('fromJson falls back to view for unknown role', () {
      final j = Map<String, dynamic>.from(json)
        ..['UserTravel'] = {'role': 'unknown'};
      expect(UserWithRole.fromJson(j).role, RoleType.view);
    });
  });
}
