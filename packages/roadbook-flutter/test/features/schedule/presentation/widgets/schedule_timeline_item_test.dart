// test/features/schedule/presentation/widgets/schedule_timeline_item_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/schedule/presentation/widgets/schedule_timeline_item.dart';
import 'package:roadbook_flutter/shared/models/schedule.dart';

Schedule _make({bool isHotel = false, DateTime? start, String? screenshots}) =>
    Schedule(
      id: 1, tId: 1,
      name: 'Test Stop',
      coordinate: '116.4,39.9',
      address: 'Test Address long enough to potentially truncate',
      isHotel: isHotel,
      startTime: start,
      screenshots: screenshots,
    );

final _travel = DateTime(2026, 3, 23);

Widget _wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

void main() {
  group('ScheduleTimelineItem time label', () {
    testWidgets('shows formatted time for regular schedule', (tester) async {
      final s = _make(start: DateTime(2026, 3, 23, 9, 30));
      await tester.pumpWidget(_wrap(ScheduleTimelineItem(
        schedule: s,
        travelStartDate: _travel,
        canEdit: false,
      )));
      expect(find.text('09:30'), findsOneWidget);
    });

    testWidgets('shows 待规划 when startTime is null', (tester) async {
      final s = _make();
      await tester.pumpWidget(_wrap(ScheduleTimelineItem(
        schedule: s,
        travelStartDate: _travel,
        canEdit: false,
      )));
      expect(find.text('待规划'), findsOneWidget);
    });

    testWidgets('shows 住宿 for hotel schedule', (tester) async {
      final s = _make(isHotel: true);
      await tester.pumpWidget(_wrap(ScheduleTimelineItem(
        schedule: s,
        travelStartDate: _travel,
        canEdit: false,
      )));
      expect(find.text('住宿'), findsOneWidget);
    });
  });

  group('ScheduleTimelineItem edit icon visibility', () {
    testWidgets('edit icon hidden when canEdit is false', (tester) async {
      final s = _make(start: DateTime(2026, 3, 23, 9, 0));
      await tester.pumpWidget(_wrap(ScheduleTimelineItem(
        schedule: s,
        travelStartDate: _travel,
        canEdit: false,
      )));
      expect(find.byKey(const Key('editIcon')), findsNothing);
    });

    testWidgets('edit icon shown when canEdit is true', (tester) async {
      final s = _make(start: DateTime(2026, 3, 23, 9, 0));
      await tester.pumpWidget(_wrap(ScheduleTimelineItem(
        schedule: s,
        travelStartDate: _travel,
        canEdit: true,
        onEditTimeTap: () {},
      )));
      expect(find.byKey(const Key('editIcon')), findsOneWidget);
    });
  });

  group('ScheduleTimelineItem screenshots', () {
    testWidgets('shows 3 thumbnails for 3 screenshots', (tester) async {
      final s = _make(
          screenshots: 'http://a.com/1.jpg,http://a.com/2.jpg,http://a.com/3.jpg');
      await tester.pumpWidget(_wrap(ScheduleTimelineItem(
        schedule: s,
        travelStartDate: _travel,
        canEdit: false,
      )));
      expect(find.byKey(const Key('screenshotThumb')), findsNWidgets(3));
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('shows 4 thumbs + overflow when >4 screenshots', (tester) async {
      final s = _make(
          screenshots:
              'http://a.com/1.jpg,http://a.com/2.jpg,http://a.com/3.jpg'
              ',http://a.com/4.jpg,http://a.com/5.jpg,http://a.com/6.jpg');
      await tester.pumpWidget(_wrap(ScheduleTimelineItem(
        schedule: s,
        travelStartDate: _travel,
        canEdit: false,
      )));
      expect(find.byKey(const Key('screenshotThumb')), findsNWidgets(4));
      expect(find.text('+2'), findsOneWidget);
    });
  });
}
