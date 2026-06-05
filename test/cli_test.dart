import 'dart:async';

import 'package:test/test.dart';

import '../bin/cn_workday_calendar.dart';

void main() {
  group('cn_workday_calendar CLI', () {
    test('prints adjusted workday details for a weekend make-up day', () {
      final outputLines = _capturePrintedLines(() {
        final exitCode = runCalendarCli(['date', '2026-02-14']);

        expect(exitCode, equals(0));
      });

      expect(outputLines, contains('Is workday: true'));
      expect(outputLines, contains('Is weekend: true'));
      expect(outputLines, contains('Is adjusted workday: true'));
      expect(outputLines, contains('Holiday name: 春节'));
    });

    test('prints legal holiday details for a weekday holiday', () {
      final outputLines = _capturePrintedLines(() {
        final exitCode = runCalendarCli(['date', '2026-02-16']);

        expect(exitCode, equals(0));
      });

      expect(outputLines, contains('Is workday: false'));
      expect(outputLines, contains('Is weekend: false'));
      expect(outputLines, contains('Is legal holiday: true'));
      expect(outputLines, contains('Holiday name: 春节'));
    });

    test('prints natural weekend details', () {
      final outputLines = _capturePrintedLines(() {
        final exitCode = runCalendarCli(['date', '2026-01-10']);

        expect(exitCode, equals(0));
      });

      expect(outputLines, contains('Is workday: false'));
      expect(outputLines, contains('Is weekend: true'));
      expect(outputLines, contains('Is legal holiday: false'));
      expect(outputLines, contains('Holiday name: -'));
    });

    test('prints inclusive range summary', () {
      final outputLines = _capturePrintedLines(() {
        final exitCode = runCalendarCli(['range', '2026-02-01', '2026-02-28']);

        expect(exitCode, equals(0));
      });

      expect(outputLines, contains('Total days: 28'));
      expect(outputLines, contains('Workdays: 16'));
      expect(outputLines, contains('Non-workdays: 12'));
    });

    test('rejects invalid date format', () {
      final outputLines = _capturePrintedLines(() {
        final exitCode = runCalendarCli(['date', '2026-02-30']);

        expect(exitCode, equals(64));
      });

      expect(
        outputLines,
        contains('Usage error: date must use yyyy-MM-dd format.'),
      );
    });
  });
}

/// 捕获 CLI 打印内容，避免测试依赖人工肉眼观察终端。
///
/// CLI 是这个 SDK 的人工验收入口，测试时必须断言它实际输出了周末、调休、
/// 法定节假日等关键字段，而不是只检查函数返回码。
List<String> _capturePrintedLines(void Function() runCommand) {
  final outputLines = <String>[];

  runZoned(
    runCommand,
    zoneSpecification: ZoneSpecification(
      print: (_, _, _, line) {
        outputLines.add(line);
      },
    ),
  );

  return outputLines;
}
