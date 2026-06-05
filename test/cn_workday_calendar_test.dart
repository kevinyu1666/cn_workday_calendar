import 'package:cn_workday_calendar/cn_workday_calendar.dart';
import 'package:test/test.dart';

void main() {
  group('CnWorkdayCalendar', () {
    final calendar = CnWorkdayCalendar();

    test('recognizes an adjusted weekend workday', () {
      final result = calendar.getWorkdayResult(DateTime(2026, 2, 14));

      expect(result.isWorkday, isTrue);
      expect(result.isWeekend, isTrue);
      expect(result.isAdjustedWorkday, isTrue);
      expect(result.holidayName, equals('春节'));
    });

    test('recognizes a legal holiday inside a long holiday range', () {
      final result = calendar.getWorkdayResult(DateTime(2026, 2, 16));

      expect(result.isWorkday, isFalse);
      expect(result.isLegalHoliday, isTrue);
      expect(result.holidayName, equals('春节'));
    });

    test('falls back to natural weekend when year data is unavailable', () {
      final result = calendar.getWorkdayResult(DateTime(2030, 1, 5));

      expect(result.isWorkday, isFalse);
      expect(result.isWeekend, isTrue);
      expect(result.isLegalHoliday, isFalse);
      expect(result.isAdjustedWorkday, isFalse);
    });

    test('falls back to natural workday when year data is unavailable', () {
      final result = calendar.getWorkdayResult(DateTime(2030, 1, 7));

      expect(result.isWorkday, isTrue);
      expect(result.isWeekend, isFalse);
    });

    test('counts inclusive workdays in a holiday month range', () {
      final workdayCount = calendar.countWorkdays(
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
      );

      expect(workdayCount, equals(16));
    });

    test('throws when count range is reversed', () {
      expect(
        () => calendar.countWorkdays(
          startDate: DateTime(2026, 2, 28),
          endDate: DateTime(2026, 2, 1),
        ),
        throwsArgumentError,
      );
    });

    test('reads 2024 Dragon Boat Festival as holiday with weekend bridge', () {
      expect(calendar.isHoliday(DateTime(2024, 6, 10)), isTrue);
      expect(calendar.getHolidayName(DateTime(2024, 6, 10)), equals('端午节'));
    });

    test('reads 2025 combined National Day and Mid-Autumn range', () {
      expect(calendar.isHoliday(DateTime(2025, 10, 6)), isTrue);
      expect(calendar.isAdjustedWorkday(DateTime(2025, 10, 11)), isTrue);
    });

    test('returns requested holiday event metadata', () {
      final nationalDay = calendar.getHolidayEvent(
        year: 2026,
        holidayEventId: HolidayEventId.nationalDay,
      );

      expect(nationalDay, isNotNull);
      expect(nationalDay!.startDate, equals(DateTime(2026, 10, 1)));
      expect(nationalDay.endDate, equals(DateTime(2026, 10, 7)));
    });
  });
}
