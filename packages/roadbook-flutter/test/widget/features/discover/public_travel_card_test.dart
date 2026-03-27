import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/discover/presentation/widgets/public_travel_card.dart';
import 'package:roadbook_flutter/shared/models/public_travel.dart';

final _owner = PublicTravelOwner(id: 1, username: 'u', name: '达人小李', avatar: null);
final _travel = PublicTravel(
  id: 10,
  name: '东京7日游',
  cities: ['东京', '大阪'],
  startDate: DateTime(2026, 4, 1),
  endDate: DateTime(2026, 4, 7),
  viewCount: 1200,
  owner: _owner,
);

void main() {
  testWidgets('renders travel name', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PublicTravelCard(travel: _travel)),
    ));
    expect(find.text('东京7日游'), findsOneWidget);
  });

  testWidgets('renders city label and days', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PublicTravelCard(travel: _travel)),
    ));
    expect(find.text('东京 · 大阪 · 7天'), findsOneWidget);
  });

  testWidgets('renders owner name', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PublicTravelCard(travel: _travel)),
    ));
    expect(find.text('达人小李'), findsOneWidget);
  });

  testWidgets('renders formatted view count', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PublicTravelCard(travel: _travel)),
    ));
    // 1200 → "1.2k"
    expect(find.textContaining('1.2k'), findsOneWidget);
  });
}
