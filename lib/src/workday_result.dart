import 'holiday_event.dart';

/// 某一天的工作日判断结果。
final class WorkdayResult {
  const WorkdayResult({
    required this.date,
    required this.isWorkday,
    required this.isWeekend,
    required this.isLegalHoliday,
    required this.isAdjustedWorkday,
    this.holidayEvent,
  });

  final DateTime date;
  final bool isWorkday;
  final bool isWeekend;
  final bool isLegalHoliday;
  final bool isAdjustedWorkday;
  final HolidayEvent? holidayEvent;

  String? get holidayName => holidayEvent?.name;
}
