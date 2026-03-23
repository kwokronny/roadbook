// test/features/schedule/presentation/widgets/schedule_item_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/schedule/presentation/widgets/schedule_item.dart';
import 'package:roadbook_flutter/shared/models/schedule.dart';

Schedule _makeSchedule({String? screenshots}) => Schedule(
      id: 1,
      tId: 1,
      name: 'Test Stop',
      coordinate: '0,0',
      address: 'Test Address',
      isHotel: false,
      screenshots: screenshots,
    );

void main() {
  group('ScheduleItem thumbnails', () {
    testWidgets('no thumbnails when screenshotList is empty', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScheduleItem(
            schedule: _makeSchedule(),
            onTap: () {},
          ),
        ),
      ));

      expect(find.byType(Image), findsNothing);
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('renders 3 thumbnails when screenshotList has 3 items',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScheduleItem(
            schedule: _makeSchedule(
                screenshots:
                    'http://a.com/1.jpg,http://a.com/2.jpg,http://a.com/3.jpg'),
            onTap: () {},
          ),
        ),
      ));

      expect(find.byType(Image), findsNWidgets(3));
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('shows only 4 thumbnails and +N box when list has 6 items',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ScheduleItem(
            schedule: _makeSchedule(
                screenshots:
                    'http://a.com/1.jpg,http://a.com/2.jpg,http://a.com/3.jpg'
                    ',http://a.com/4.jpg,http://a.com/5.jpg,http://a.com/6.jpg'),
            onTap: () {},
          ),
        ),
      ));

      expect(find.byType(Image), findsNWidgets(4));
      expect(find.text('+2'), findsOneWidget);
    });
  });
}
