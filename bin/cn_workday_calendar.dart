import 'dart:io' as io;

import 'package:cn_workday_calendar/cn_workday_calendar.dart';

const _dateCommand = 'date';
const _rangeCommand = 'range';
const _samplesCommand = 'samples';
const _helpCommand = 'help';
const _isoDateSeparator = '-';
const _exitSuccess = 0;
const _exitUsageError = 64;

void main(List<String> arguments) {
  io.exitCode = runCalendarCli(arguments);
}

/// 执行命令行测试工具。
///
/// 这个工具面向 SDK 使用者和维护者，目标是不用写代码也能验证单日、日期区间、
/// 周末、法定节假日和调休补班的判断结果，避免开源库只停留在单元测试层面。
int runCalendarCli(List<String> arguments) {
  if (arguments.isEmpty) {
    _printUsage();
    return _exitUsageError;
  }

  final command = arguments.first;
  final commandArguments = arguments.skip(1).toList();
  final calendar = CnWorkdayCalendar();

  if (command == _helpCommand || command == '--help' || command == '-h') {
    _printUsage();
    return _exitSuccess;
  }

  if (command == _dateCommand) {
    return _runDateCommand(calendar, commandArguments);
  }

  if (command == _rangeCommand) {
    return _runRangeCommand(calendar, commandArguments);
  }

  if (command == _samplesCommand) {
    return _runSamplesCommand(calendar);
  }

  print('Unknown command: $command');
  _printUsage();
  return _exitUsageError;
}

/// 查询单个日期的工作日判断结果。
///
/// 单日查询是验证 SDK 最直观的入口，输出必须包含周末、法定节假日、调休补班
/// 和关联节日名称，避免调用方只能看到一个无法解释的布尔值。
int _runDateCommand(CnWorkdayCalendar calendar, List<String> commandArguments) {
  if (commandArguments.length != 1) {
    print('Usage error: date command requires exactly one yyyy-MM-dd value.');
    _printUsage();
    return _exitUsageError;
  }

  final targetDate = _tryParseIsoDate(commandArguments.first);

  if (targetDate == null) {
    print('Usage error: date must use yyyy-MM-dd format.');
    return _exitUsageError;
  }

  _printWorkdayResult(calendar.getWorkdayResult(targetDate));
  return _exitSuccess;
}

/// 查询日期区间的工作日统计结果。
///
/// 区间查询用于验证月度汇总、薪资周期和排班周期等真实场景，输出既包含总天数，
/// 也包含工作日和休息日数量，方便人工快速发现调休数据是否被漏算。
int _runRangeCommand(
  CnWorkdayCalendar calendar,
  List<String> commandArguments,
) {
  if (commandArguments.length != 2) {
    print('Usage error: range command requires startDate and endDate.');
    _printUsage();
    return _exitUsageError;
  }

  final startDate = _tryParseIsoDate(commandArguments[0]);
  final endDate = _tryParseIsoDate(commandArguments[1]);

  if (startDate == null || endDate == null) {
    print('Usage error: dates must use yyyy-MM-dd format.');
    return _exitUsageError;
  }

  if (startDate.isAfter(endDate)) {
    print('Usage error: endDate must not be earlier than startDate.');
    return _exitUsageError;
  }

  final totalDayCount = endDate.difference(startDate).inDays + 1;
  final workdayCount = calendar.countWorkdays(
    startDate: startDate,
    endDate: endDate,
  );

  print('Range: ${_formatDate(startDate)} ~ ${_formatDate(endDate)}');
  print('Total days: $totalDayCount');
  print('Workdays: $workdayCount');
  print('Non-workdays: ${totalDayCount - workdayCount}');
  return _exitSuccess;
}

/// 运行覆盖典型场景的命令行样例。
///
/// 样例固定覆盖普通工作日、普通周末、法定节假日和调休补班日，维护者更新年份
/// 数据后可以先用它做人工烟测，再进入自动化测试。
int _runSamplesCommand(CnWorkdayCalendar calendar) {
  final sampleDates = [
    DateTime(2026, 1, 5),
    DateTime(2026, 1, 10),
    DateTime(2026, 2, 16),
    DateTime(2026, 2, 14),
    DateTime(2026, 10, 10),
  ];

  for (final sampleDate in sampleDates) {
    _printWorkdayResult(calendar.getWorkdayResult(sampleDate));
    print('');
  }

  _runRangeCommand(calendar, ['2026-02-01', '2026-02-28']);
  return _exitSuccess;
}

void _printWorkdayResult(WorkdayResult result) {
  print('Date: ${_formatDate(result.date)}');
  print('Is workday: ${result.isWorkday}');
  print('Is weekend: ${result.isWeekend}');
  print('Is legal holiday: ${result.isLegalHoliday}');
  print('Is adjusted workday: ${result.isAdjustedWorkday}');
  print('Holiday name: ${result.holidayName ?? '-'}');
}

DateTime? _tryParseIsoDate(String isoDate) {
  final dateParts = isoDate.split(_isoDateSeparator);

  if (dateParts.length != 3) {
    return null;
  }

  final year = int.tryParse(dateParts[0]);
  final month = int.tryParse(dateParts[1]);
  final day = int.tryParse(dateParts[2]);

  if (year == null || month == null || day == null) {
    return null;
  }

  final parsedDate = DateTime(year, month, day);

  if (_formatDate(parsedDate) != isoDate) {
    return null;
  }

  return parsedDate;
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '${date.year}-$month-$day';
}

void _printUsage() {
  print('Usage:');
  print('  dart run cn_workday_calendar date yyyy-MM-dd');
  print('  dart run cn_workday_calendar range yyyy-MM-dd yyyy-MM-dd');
  print('  dart run cn_workday_calendar samples');
  print('');
  print('Examples:');
  print('  dart run cn_workday_calendar date 2026-02-14');
  print('  dart run cn_workday_calendar date 2026-02-16');
  print('  dart run cn_workday_calendar range 2026-02-01 2026-02-28');
}
