import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/travel/presentation/map/map_search_bar.dart';

void main() {
  Widget build({
    List<String> cities = const ['北京', '上海'],
    String selectedCity = '全国',
    ValueChanged<String>? onCityChanged,
    ValueChanged<String>? onSearch,
    VoidCallback? onClose,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: MapSearchBar(
            cities: cities,
            selectedCity: selectedCity,
            onCityChanged: onCityChanged ?? (_) {},
            onSearch: onSearch ?? (_) {},
            onClose: onClose ?? () {},
          ),
        ),
      );

  testWidgets('城市选项包含全国和旅程城市', (tester) async {
    await tester.pumpWidget(build());
    expect(find.text('全国'), findsOneWidget);
  });

  testWidgets('点击关闭按钮触发 onClose', (tester) async {
    bool closed = false;
    await tester.pumpWidget(build(onClose: () => closed = true));
    await tester.tap(find.byIcon(Icons.arrow_back));
    expect(closed, isTrue);
  });

  testWidgets('提交搜索框触发 onSearch', (tester) async {
    String? searched;
    await tester.pumpWidget(build(onSearch: (v) => searched = v));
    await tester.enterText(find.byType(TextField), '故宫');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    expect(searched, '故宫');
  });
}
