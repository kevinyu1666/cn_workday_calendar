/// 节假日事件编号。
///
/// 使用稳定英文 ID 是为了让上层 App 可以安全持久化，不被中文展示名变化影响。
enum HolidayEventId {
  newYear,
  springFestival,
  qingmingFestival,
  laborDay,
  dragonBoatFestival,
  midAutumnFestival,
  nationalDay,
}

/// 某一年的单个全国性节假日安排。
final class HolidayEvent {
  const HolidayEvent({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.legalHolidayDates,
    required this.adjustedWorkdayDates,
  });

  final HolidayEventId id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final Set<DateTime> legalHolidayDates;
  final Set<DateTime> adjustedWorkdayDates;

  /// 判断目标日期是否落在本节假日的放假区间内。
  bool containsDate(DateTime targetDate) {
    final normalizedTargetDate = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    if (normalizedTargetDate.isBefore(startDate)) {
      return false;
    }

    if (normalizedTargetDate.isAfter(endDate)) {
      return false;
    }

    return true;
  }
}
