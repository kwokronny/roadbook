import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/luggage/domain/luggage_provider.dart';
import 'package:roadbook_flutter/features/luggage/presentation/luggage_screen.dart';
import 'package:roadbook_flutter/shared/models/luggage.dart';

LuggageState _state({
  List<LuggageCategory> cats = const [],
  Set<String> checked = const {},
  bool canEdit = true,
}) =>
    LuggageState(
        categories: cats, checkedIds: checked, isSaving: false, canEdit: canEdit);

class _StubLuggageNotifier extends LuggageNotifier {
  final LuggageState _fixed;
  _StubLuggageNotifier(this._fixed);

  @override
  Future<LuggageState> build(int arg) async => _fixed;
}

Widget _wrap(LuggageState s) => ProviderScope(
      overrides: [
        luggageProvider.overrideWith(() => _StubLuggageNotifier(s)),
      ],
      child: const MaterialApp(home: LuggageScreen(travelId: 1)),
    );

void main() {
  testWidgets('renders AppBar title 行李清单', (tester) async {
    await tester.pumpWidget(_wrap(_state()));
    await tester.pump();
    expect(find.text('行李清单'), findsOneWidget);
  });

  testWidgets('shows 0 / 0 已打包 when no items', (tester) async {
    await tester.pumpWidget(_wrap(_state()));
    await tester.pump();
    expect(find.text('0 / 0 已打包'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('shows category name when categories present', (tester) async {
    final cats = [
      LuggageCategory(
        id: 'c1', name: '证件', emoji: '📋',
        items: [const LuggageItem(id: 'i1', text: '护照')],
      ),
    ];
    await tester.pumpWidget(_wrap(_state(cats: cats)));
    await tester.pump();
    expect(find.text('证件'), findsOneWidget);
    expect(find.text('0 / 1 已打包'), findsOneWidget);
  });

  testWidgets('添加分类 button visible when canEdit=true', (tester) async {
    await tester.pumpWidget(_wrap(_state(canEdit: true)));
    await tester.pump();
    expect(find.text('添加分类'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('添加分类 button hidden when canEdit=false', (tester) async {
    await tester.pumpWidget(_wrap(_state(canEdit: false)));
    await tester.pump();
    expect(find.text('添加分类'), findsNothing);
  });

  testWidgets('导入模板 button visible when canEdit=true', (tester) async {
    await tester.pumpWidget(_wrap(_state(canEdit: true)));
    await tester.pump();
    expect(find.text('导入模板'), findsOneWidget);
  });

  testWidgets('导入模板 button hidden when canEdit=false', (tester) async {
    await tester.pumpWidget(_wrap(_state(canEdit: false)));
    await tester.pump();
    expect(find.text('导入模板'), findsNothing);
  });
}
