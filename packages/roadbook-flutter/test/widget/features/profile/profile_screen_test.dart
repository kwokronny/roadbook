import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/providers/auth_state_provider.dart';
import 'package:roadbook_flutter/shared/models/user.dart';
import 'package:roadbook_flutter/features/profile/presentation/profile_screen.dart';

void main() {
  testWidgets('shows Large Title 我的', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('我的'), findsOneWidget);
  });
}
