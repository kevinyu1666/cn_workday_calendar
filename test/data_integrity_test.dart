import 'dart:convert';
import 'dart:io';

import 'package:cn_workday_calendar/cn_workday_calendar.dart';
import 'package:cn_workday_calendar/src/holiday_schedule_data.dart';
import 'package:test/test.dart';

const _holidaySchedulesDataPath = 'data/holiday_schedules.json';

void main() {
  group('Holiday schedule data integrity', () {
    final calendar = CnWorkdayCalendar();

    test('keeps supported years explicit and predictable', () {
      expect(calendar.supportedYears, equals({2024, 2025, 2026}));
    });

    test('marks every built-in holiday date as non-workday', () {
      for (final schedule in builtInHolidaySchedulesByYear.values) {
        for (final holidayEvent in schedule.events) {
          for (final legalHolidayDate in holidayEvent.legalHolidayDates) {
            final result = calendar.getWorkdayResult(legalHolidayDate);

            expect(
              result.isWorkday,
              isFalse,
              reason:
                  '${holidayEvent.name} ${_formatDate(legalHolidayDate)} should be holiday.',
            );
            expect(result.isLegalHoliday, isTrue);
          }
        }
      }
    });

    test('marks every adjusted workday as workday with holiday context', () {
      for (final schedule in builtInHolidaySchedulesByYear.values) {
        for (final holidayEvent in schedule.events) {
          for (final adjustedWorkdayDate in holidayEvent.adjustedWorkdayDates) {
            final result = calendar.getWorkdayResult(adjustedWorkdayDate);

            expect(
              result.isWorkday,
              isTrue,
              reason:
                  '${holidayEvent.name} ${_formatDate(adjustedWorkdayDate)} should be adjusted workday.',
            );
            expect(result.isAdjustedWorkday, isTrue);
            expect(result.holidayEvent, isNotNull);
          }
        }
      }
    });

    test('normalizes input time when judging dates', () {
      final result = calendar.getWorkdayResult(DateTime(2026, 10, 1, 23, 59));

      expect(result.date, equals(DateTime(2026, 10, 1)));
      expect(result.isWorkday, isFalse);
      expect(result.holidayName, equals('国庆节'));
    });

    test('keeps JSON data aligned with Dart built-in data', () {
      final jsonSchedulesByYear = _loadJsonSchedulesByYear();

      expect(
        jsonSchedulesByYear.keys.toSet(),
        equals(builtInHolidaySchedulesByYear.keys.toSet()),
      );

      for (final builtInSchedule in builtInHolidaySchedulesByYear.values) {
        final jsonSchedule = jsonSchedulesByYear[builtInSchedule.year]!;

        expect(jsonSchedule['sourceName'], equals(builtInSchedule.sourceName));
        expect(jsonSchedule['sourceUrl'], equals(builtInSchedule.sourceUrl));
        _expectJsonEventsMatchBuiltInEvents(
          jsonSchedule: jsonSchedule,
          builtInSchedule: builtInSchedule,
        );
      }
    });
  });
}

/// 校验 JSON 节日列表与 Dart 内置节日列表一致。
///
/// 这个测试服务于《牛马日志》的长期维护：未来新增年份时，JSON 是跨语言 SDK
/// 的事实数据源，Dart 内置数据是运行期实现，两者一旦漂移就会造成平台间判断不一致。
void _expectJsonEventsMatchBuiltInEvents({
  required Map<String, Object?> jsonSchedule,
  required HolidaySchedule builtInSchedule,
}) {
  final jsonEventsById = _extractJsonEventsById(jsonSchedule);

  expect(
    jsonEventsById.keys.toSet(),
    equals(
      builtInSchedule.events
          .map((holidayEvent) => holidayEvent.id.name)
          .toSet(),
    ),
  );

  for (final builtInEvent in builtInSchedule.events) {
    final jsonEvent = jsonEventsById[builtInEvent.id.name]!;

    expect(jsonEvent['name'], equals(builtInEvent.name));
    expect(jsonEvent['startDate'], equals(_formatDate(builtInEvent.startDate)));
    expect(jsonEvent['endDate'], equals(_formatDate(builtInEvent.endDate)));
    expect(
      jsonEvent['adjustedWorkdays'],
      equals(builtInEvent.adjustedWorkdayDates.map(_formatDate).toList()),
    );
  }
}

/// 读取结构化节假日 JSON，并按年份建立索引。
///
/// 开源项目会优先让其他语言 SDK 复用 `data/` 目录，所以测试必须直接读取
/// 文件，而不是只相信 Dart 代码里的手写常量。
Map<int, Map<String, Object?>> _loadJsonSchedulesByYear() {
  final jsonContent = File(_holidaySchedulesDataPath).readAsStringSync();
  final rootJson = jsonDecode(jsonContent) as Map<String, Object?>;
  final jsonYears = rootJson['years'] as List<Object?>;

  return {
    for (final jsonYear in jsonYears)
      (jsonYear! as Map<String, Object?>)['year'] as int:
          jsonYear as Map<String, Object?>,
  };
}

/// 从 JSON 节日列表提取按 Dart 枚举名索引的数据。
///
/// JSON 对外使用 snake_case 是为了兼容多语言生态；Dart 内部使用 enum.name。
/// 这里集中转换，避免每个断言都混着协议格式和语言实现格式。
Map<String, Map<String, Object?>> _extractJsonEventsById(
  Map<String, Object?> jsonSchedule,
) {
  final jsonEvents = jsonSchedule['holidays'] as List<Object?>;

  return {
    for (final jsonEvent in jsonEvents)
      _snakeCaseHolidayIdToEnumName(
        (jsonEvent! as Map<String, Object?>)['id'] as String,
      ): jsonEvent as Map<String, Object?>,
  };
}

/// 将 JSON 协议里的 snake_case 节日 ID 转成 Dart enum.name。
///
/// 这里不把 JSON 字段名改成 Dart 风格，是为了让 `data/` 目录可以被
/// TypeScript、Python 等语言直接复用，避免 Dart SDK 反过来污染通用数据协议。
String _snakeCaseHolidayIdToEnumName(String snakeCaseHolidayId) {
  final holidayIdParts = snakeCaseHolidayId.split('_');

  return holidayIdParts.first +
      holidayIdParts
          .skip(1)
          .map(
            (holidayIdPart) =>
                holidayIdPart[0].toUpperCase() + holidayIdPart.substring(1),
          )
          .join();
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '${date.year}-$month-$day';
}
