import 'holiday_event.dart';

const _dateSeparator = '-';

/// 某一年的全国性节假日安排。
final class HolidaySchedule {
  const HolidaySchedule({
    required this.year,
    required this.sourceName,
    required this.sourceUrl,
    required this.events,
  });

  final int year;
  final String sourceName;
  final String sourceUrl;
  final List<HolidayEvent> events;

  Set<DateTime> get adjustedWorkdayDates {
    return events
        .expand((holidayEvent) => holidayEvent.adjustedWorkdayDates)
        .toSet();
  }

  /// 查找目标日期关联的节假日。
  ///
  /// 《牛马日志》需要在详情页解释“这天为什么休息或补班”。使用节日事件反查，
  /// 可以避免调用方只拿到布尔值后再手动拼接一套不可信的展示文案。
  HolidayEvent? findHolidayEvent(DateTime normalizedTargetDate) {
    for (final holidayEvent in events) {
      if (holidayEvent.containsDate(normalizedTargetDate)) {
        return holidayEvent;
      }

      // 调休补班日不在放假区间内，但它依然属于某个节日安排的一部分。
      if (holidayEvent.adjustedWorkdayDates.contains(normalizedTargetDate)) {
        return holidayEvent;
      }
    }

    return null;
  }

  HolidayEvent? findHolidayEventById(HolidayEventId holidayEventId) {
    for (final holidayEvent in events) {
      if (holidayEvent.id == holidayEventId) {
        return holidayEvent;
      }
    }

    return null;
  }
}

final builtInHolidaySchedulesByYear = <int, HolidaySchedule>{
  2024: HolidaySchedule(
    year: 2024,
    sourceName: '国务院办公厅关于2024年部分节假日安排的通知',
    sourceUrl:
        'https://www.kashi.gov.cn/ksdqxzgs/c115966/202310/c37344d547094e6e8ec8506dc07e7673.shtml',
    events: [
      _holidayEvent(
        id: HolidayEventId.newYear,
        name: '元旦',
        startDate: '2024-01-01',
        endDate: '2024-01-01',
      ),
      _holidayEvent(
        id: HolidayEventId.springFestival,
        name: '春节',
        startDate: '2024-02-10',
        endDate: '2024-02-17',
        adjustedWorkdayDates: ['2024-02-04', '2024-02-18'],
      ),
      _holidayEvent(
        id: HolidayEventId.qingmingFestival,
        name: '清明节',
        startDate: '2024-04-04',
        endDate: '2024-04-06',
        adjustedWorkdayDates: ['2024-04-07'],
      ),
      _holidayEvent(
        id: HolidayEventId.laborDay,
        name: '劳动节',
        startDate: '2024-05-01',
        endDate: '2024-05-05',
        adjustedWorkdayDates: ['2024-04-28', '2024-05-11'],
      ),
      _holidayEvent(
        id: HolidayEventId.dragonBoatFestival,
        name: '端午节',
        startDate: '2024-06-10',
        endDate: '2024-06-10',
      ),
      _holidayEvent(
        id: HolidayEventId.midAutumnFestival,
        name: '中秋节',
        startDate: '2024-09-15',
        endDate: '2024-09-17',
        adjustedWorkdayDates: ['2024-09-14'],
      ),
      _holidayEvent(
        id: HolidayEventId.nationalDay,
        name: '国庆节',
        startDate: '2024-10-01',
        endDate: '2024-10-07',
        adjustedWorkdayDates: ['2024-09-29', '2024-10-12'],
      ),
    ],
  ),
  2025: HolidaySchedule(
    year: 2025,
    sourceName: '国务院办公厅关于2025年部分节假日安排的通知',
    sourceUrl: 'https://www.forestry.gov.cn/c/www/szxx/594663.jhtml',
    events: [
      _holidayEvent(
        id: HolidayEventId.newYear,
        name: '元旦',
        startDate: '2025-01-01',
        endDate: '2025-01-01',
      ),
      _holidayEvent(
        id: HolidayEventId.springFestival,
        name: '春节',
        startDate: '2025-01-28',
        endDate: '2025-02-04',
        adjustedWorkdayDates: ['2025-01-26', '2025-02-08'],
      ),
      _holidayEvent(
        id: HolidayEventId.qingmingFestival,
        name: '清明节',
        startDate: '2025-04-04',
        endDate: '2025-04-06',
      ),
      _holidayEvent(
        id: HolidayEventId.laborDay,
        name: '劳动节',
        startDate: '2025-05-01',
        endDate: '2025-05-05',
        adjustedWorkdayDates: ['2025-04-27'],
      ),
      _holidayEvent(
        id: HolidayEventId.dragonBoatFestival,
        name: '端午节',
        startDate: '2025-05-31',
        endDate: '2025-06-02',
      ),
      _holidayEvent(
        id: HolidayEventId.nationalDay,
        name: '国庆节、中秋节',
        startDate: '2025-10-01',
        endDate: '2025-10-08',
        adjustedWorkdayDates: ['2025-09-28', '2025-10-11'],
      ),
      _holidayEvent(
        id: HolidayEventId.midAutumnFestival,
        name: '国庆节、中秋节',
        startDate: '2025-10-01',
        endDate: '2025-10-08',
        adjustedWorkdayDates: ['2025-09-28', '2025-10-11'],
      ),
    ],
  ),
  2026: HolidaySchedule(
    year: 2026,
    sourceName: '国务院办公厅关于2026年部分节假日安排的通知',
    sourceUrl:
        'https://news.cctv.com/2025/11/04/ARTIzBycPZbvvPD4uW0iYbKR251104.shtml',
    events: [
      _holidayEvent(
        id: HolidayEventId.newYear,
        name: '元旦',
        startDate: '2026-01-01',
        endDate: '2026-01-03',
        adjustedWorkdayDates: ['2026-01-04'],
      ),
      _holidayEvent(
        id: HolidayEventId.springFestival,
        name: '春节',
        startDate: '2026-02-15',
        endDate: '2026-02-23',
        adjustedWorkdayDates: ['2026-02-14', '2026-02-28'],
      ),
      _holidayEvent(
        id: HolidayEventId.qingmingFestival,
        name: '清明节',
        startDate: '2026-04-04',
        endDate: '2026-04-06',
      ),
      _holidayEvent(
        id: HolidayEventId.laborDay,
        name: '劳动节',
        startDate: '2026-05-01',
        endDate: '2026-05-05',
        adjustedWorkdayDates: ['2026-05-09'],
      ),
      _holidayEvent(
        id: HolidayEventId.dragonBoatFestival,
        name: '端午节',
        startDate: '2026-06-19',
        endDate: '2026-06-21',
      ),
      _holidayEvent(
        id: HolidayEventId.midAutumnFestival,
        name: '中秋节',
        startDate: '2026-09-25',
        endDate: '2026-09-27',
      ),
      _holidayEvent(
        id: HolidayEventId.nationalDay,
        name: '国庆节',
        startDate: '2026-10-01',
        endDate: '2026-10-07',
        adjustedWorkdayDates: ['2026-09-20', '2026-10-10'],
      ),
    ],
  ),
};

HolidayEvent _holidayEvent({
  required HolidayEventId id,
  required String name,
  required String startDate,
  required String endDate,
  List<String> adjustedWorkdayDates = const [],
}) {
  return HolidayEvent(
    id: id,
    name: name,
    startDate: _parseIsoDate(startDate),
    endDate: _parseIsoDate(endDate),
    legalHolidayDates: _buildInclusiveDateSet(startDate, endDate),
    adjustedWorkdayDates: adjustedWorkdayDates.map(_parseIsoDate).toSet(),
  );
}

/// 构建包含起止日期的日期集合。
///
/// 国务院通知使用“X日至Y日”表达放假范围，业务含义天然包含两端日期。
/// 这里集中处理边界，防止调用方在每个节日上重复写容易出错的日期展开逻辑。
Set<DateTime> _buildInclusiveDateSet(String startDate, String endDate) {
  final normalizedStartDate = _parseIsoDate(startDate);
  final normalizedEndDate = _parseIsoDate(endDate);

  if (normalizedStartDate.isAfter(normalizedEndDate)) {
    throw ArgumentError.value(endDate, 'endDate', '节假日结束日期不能早于开始日期。');
  }

  final dates = <DateTime>{};
  var cursorDate = normalizedStartDate;

  while (!cursorDate.isAfter(normalizedEndDate)) {
    dates.add(cursorDate);
    cursorDate = cursorDate.add(const Duration(days: 1));
  }

  return dates;
}

DateTime _parseIsoDate(String isoDate) {
  final dateParts = isoDate.split(_dateSeparator);

  if (dateParts.length != 3) {
    throw ArgumentError.value(isoDate, 'isoDate', '日期必须使用 yyyy-MM-dd 格式。');
  }

  return DateTime(
    int.parse(dateParts[0]),
    int.parse(dateParts[1]),
    int.parse(dateParts[2]),
  );
}
