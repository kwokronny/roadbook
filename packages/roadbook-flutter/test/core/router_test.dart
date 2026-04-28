// test/core/router_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/core/router.dart';

void main() {
  group('RouterGuard.redirect', () {
    test('unauthenticated user going to /travel redirects to /signin', () {
      final result = RouterGuard.computeRedirect(
        token: null,
        location: '/travel',
      );
      expect(result, '/signin');
    });

    test('unauthenticated user going to /signin is allowed', () {
      final result = RouterGuard.computeRedirect(
        token: null,
        location: '/signin',
      );
      expect(result, isNull);
    });

    test('authenticated user going to /signin redirects to /travel', () {
      final result = RouterGuard.computeRedirect(
        token: 'tok',
        location: '/signin',
      );
      expect(result, '/travel');
    });

    test('authenticated user going to /travel is allowed', () {
      final result = RouterGuard.computeRedirect(
        token: 'tok',
        location: '/travel',
      );
      expect(result, isNull);
    });

    test('/accept is public (no token required)', () {
      final result = RouterGuard.computeRedirect(
        token: null,
        location: '/accept',
      );
      expect(result, isNull);
    });

    test('unauthenticated user going to /discover redirects to /signin', () {
      final result = RouterGuard.computeRedirect(token: null, location: '/discover');
      expect(result, '/signin');
    });

    test('unauthenticated user going to /profile redirects to /signin', () {
      final result = RouterGuard.computeRedirect(token: null, location: '/profile');
      expect(result, '/signin');
    });

    test('authenticated user going to /discover is allowed', () {
      final result = RouterGuard.computeRedirect(token: 'tok', location: '/discover');
      expect(result, isNull);
    });

    test('authenticated user going to /profile is allowed', () {
      final result = RouterGuard.computeRedirect(token: 'tok', location: '/profile');
      expect(result, isNull);
    });
  });
}
