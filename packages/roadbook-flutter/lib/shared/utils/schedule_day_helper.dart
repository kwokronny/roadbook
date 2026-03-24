// lib/shared/utils/schedule_day_helper.dart
import '../models/schedule.dart';

/// 返回指定天的行程列表（与 ScheduleListPanel 逻辑一致）。
/// [day] 0 = 待规划，1-N = 第 N 天
/// [travelStart] 旅程开始日期（本地时间）
List<Schedule> schedulesForDay(
  int day,
  List<Schedule> all,
  DateTime travelStart,
) {
  if (day == 0) {
    return all.where((s) => s.startTime == null).toList();
  }
  return all.where((s) {
    if (s.startTime == null) return false;
    final startDay =
        s.startTime!.toLocal().difference(travelStart).inDays + 1;
    if (s.isHotel && s.endTime != null) {
      final endDay =
          s.endTime!.toLocal().difference(travelStart).inDays + 1;
      return day >= startDay && day <= endDay;
    }
    return startDay == day;
  }).toList()
    ..sort((a, b) =>
        (a.startTime ?? DateTime(0)).compareTo(b.startTime ?? DateTime(0)));
}
