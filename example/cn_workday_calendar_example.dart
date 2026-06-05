import 'package:cn_workday_calendar/cn_workday_calendar.dart';

void main() {
  final calendar = CnWorkdayCalendar();
  final targetDate = DateTime(2026, 2, 14);
  final workdayResult = calendar.getWorkdayResult(targetDate);

  print('date: ${workdayResult.date}');
  print('isWorkday: ${workdayResult.isWorkday}');
  print('isAdjustedWorkday: ${workdayResult.isAdjustedWorkday}');
  print('holidayName: ${workdayResult.holidayName}');
}
