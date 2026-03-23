// test/shared/models/user_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/user.dart';

void main() {
  group('User', () {
    final json = {
      'id': 1,
      'username': 'testuser',
      'avatar': 'https://example.com/avatar.png',
    };

    test('fromJson parses all fields', () {
      final user = User.fromJson(json);
      expect(user.id, 1);
      expect(user.username, 'testuser');
      expect(user.avatar, 'https://example.com/avatar.png');
    });

    test('fromJson handles null avatar', () {
      final user = User.fromJson({'id': 2, 'username': 'x', 'avatar': null});
      expect(user.avatar, isNull);
    });

    test('toJson round-trips', () {
      final user = User.fromJson(json);
      expect(user.toJson(), equals({...json, 'name': null}));
    });

    test('fromJson parses name field', () {
      final user = User.fromJson({
        'id': 1,
        'username': 'testuser',
        'avatar': null,
        'name': 'Test User',
      });
      expect(user.name, 'Test User');
    });

    test('fromJson handles null name', () {
      final user = User.fromJson({'id': 2, 'username': 'x', 'avatar': null});
      expect(user.name, isNull);
    });
  });
}
