import 'holiday_event.dart';
import 'holiday_schedule_data.dart';
import 'workday_result.dart';

/// 中国大陆工作日历。
///
/// 《牛马日志》后续可以用它判断某天是否应该计入标准出勤日，避免把
/// 调休补班日误判为周末，或者把节假日误判为正常工作日。
final class CnWorkdayCalendar {
  CnWorkdayCalendar({Map<int, HolidaySchedule>? schedulesByYear})
    : _schedulesByYear = schedulesByYear ?? builtInHolidaySchedulesByYear;

  final Map<int, HolidaySchedule> _schedulesByYear;

  Set<int> get supportedYears => _schedulesByYear.keys.toSet();

  /// 判断指定日期是否为工作日。
  ///
  /// 在《牛马日志》的工时统计里，工作日判断会影响默认班次、应出勤天数和
  /// 加班归类，因此这里必须优先处理国务院调休数据，再回退到自然周末规则。
  bool isWorkday(DateTime targetDate) {
    return getWorkdayResult(targetDate).isWorkday;
  }

  /// 判断指定日期是否为节假日放假日。
  bool isHoliday(DateTime targetDate) {
    return !getWorkdayResult(targetDate).isWorkday;
  }

  /// 判断指定日期是否为国务院安排的调休补班日。
  bool isAdjustedWorkday(DateTime targetDate) {
    return getWorkdayResult(targetDate).isAdjustedWorkday;
  }

  /// 判断指定日期是否属于国务院公布的节假日放假区间。
  bool isLegalHoliday(DateTime targetDate) {
    return getWorkdayResult(targetDate).isLegalHoliday;
  }

  /// 获取指定日期所属节假日名称。
  String? getHolidayName(DateTime targetDate) {
    return getWorkdayResult(targetDate).holidayName;
  }

  /// 获取某一天完整的工作日判断结果。
  ///
  /// 在《牛马日志》里，单个布尔值不足以解释“为什么这天算工作日/休息日”。
  /// 这个方法会返回调休、周末、节假日名称等上下文，方便 UI 给用户展示可追溯原因。
  WorkdayResult getWorkdayResult(DateTime targetDate) {
    final normalizedTargetDate = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    final schedule = _schedulesByYear[normalizedTargetDate.year];

    if (schedule == null) {
      return _buildWeekendBasedResult(normalizedTargetDate);
    }

    final holidayEvent = schedule.findHolidayEvent(normalizedTargetDate);
    final isAdjustedWorkday = schedule.adjustedWorkdayDates.contains(
      normalizedTargetDate,
    );

    if (isAdjustedWorkday) {
      return WorkdayResult(
        date: normalizedTargetDate,
        isWorkday: true,
        isWeekend: _isWeekend(normalizedTargetDate),
        isLegalHoliday: false,
        isAdjustedWorkday: true,
        holidayEvent: holidayEvent,
      );
    }

    if (holidayEvent != null) {
      return WorkdayResult(
        date: normalizedTargetDate,
        isWorkday: false,
        isWeekend: _isWeekend(normalizedTargetDate),
        isLegalHoliday: true,
        isAdjustedWorkday: false,
        holidayEvent: holidayEvent,
      );
    }

    return _buildWeekendBasedResult(normalizedTargetDate);
  }

  /// 统计指定日期区间内的工作日数量。
  ///
  /// 《牛马日志》月度汇总需要计算应出勤天数。这里包含起止日期，符合用户
  /// 查询“1月1日到1月31日”时的直觉，也避免调用方反复处理边界日期。
  int countWorkdays({required DateTime startDate, required DateTime endDate}) {
    final normalizedStartDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedEndDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );

    if (normalizedStartDate.isAfter(normalizedEndDate)) {
      throw ArgumentError.value(endDate, 'endDate', '结束日期不能早于开始日期。');
    }

    var workdayCount = 0;
    var cursorDate = normalizedStartDate;

    while (!cursorDate.isAfter(normalizedEndDate)) {
      if (isWorkday(cursorDate)) {
        workdayCount += 1;
      }

      cursorDate = cursorDate.add(const Duration(days: 1));
    }

    return workdayCount;
  }

  /// 获取指定年份和节日的放假安排。
  HolidayEvent? getHolidayEvent({
    required int year,
    required HolidayEventId holidayEventId,
  }) {
    final schedule = _schedulesByYear[year];

    if (schedule == null) {
      return null;
    }

    return schedule.findHolidayEventById(holidayEventId);
  }

  WorkdayResult _buildWeekendBasedResult(DateTime normalizedTargetDate) {
    final isWeekend = _isWeekend(normalizedTargetDate);

    return WorkdayResult(
      date: normalizedTargetDate,
      isWorkday: !isWeekend,
      isWeekend: isWeekend,
      isLegalHoliday: false,
      isAdjustedWorkday: false,
    );
  }

  bool _isWeekend(DateTime normalizedTargetDate) {
    return normalizedTargetDate.weekday == DateTime.saturday ||
        normalizedTargetDate.weekday == DateTime.sunday;
  }
}
