# cn_workday_calendar

中国大陆法定节假日、调休补班与工作日判断 Dart SDK。

这个项目适合考勤、工时统计、HR SaaS、日历工具、个人时间复盘等场景。它只处理国务院办公厅公布的全国性安排，不处理地方假期、企业自定义排班、个人请假或特殊行业轮班。

## Features

- 判断某天是否为工作日
- 判断某天是否为节假日放假日
- 判断某天是否为调休补班日
- 获取节假日名称
- 统计闭区间内的工作日数量
- 提供 2024、2025、2026 年内置数据
- 提供 `data/holiday_schedules.json`，方便未来扩展 TypeScript、Python、Go SDK

## Usage

```dart
import 'package:cn_workday_calendar/cn_workday_calendar.dart';

void main() {
  final calendar = CnWorkdayCalendar();
  final result = calendar.getWorkdayResult(DateTime(2026, 2, 14));

  print(result.isWorkday); // true
  print(result.isAdjustedWorkday); // true
  print(result.holidayName); // 春节
}
```

## API

```dart
calendar.isWorkday(DateTime(2026, 10, 10));
calendar.isHoliday(DateTime(2026, 10, 1));
calendar.isAdjustedWorkday(DateTime(2026, 10, 10));
calendar.isLegalHoliday(DateTime(2026, 10, 1));
calendar.getHolidayName(DateTime(2026, 10, 1));
calendar.countWorkdays(
  startDate: DateTime(2026, 2, 1),
  endDate: DateTime(2026, 2, 28),
);
```

## CLI Smoke Test

项目内置一个可执行命令，方便不用写代码也能验证 SDK 判断结果。

```bash
dart run cn_workday_calendar date 2026-02-14
dart run cn_workday_calendar date 2026-02-16
dart run cn_workday_calendar range 2026-02-01 2026-02-28
dart run cn_workday_calendar samples
```

输出会包含：

- 是否工作日
- 是否周末
- 是否法定节假日
- 是否调休补班日
- 关联节假日名称
- 区间内总天数、工作日数、非工作日数

## Data Sources

- 2024: [国务院办公厅关于2024年部分节假日安排的通知](https://www.kashi.gov.cn/ksdqxzgs/c115966/202310/c37344d547094e6e8ec8506dc07e7673.shtml)
- 2025: [国务院办公厅关于2025年部分节假日安排的通知](https://www.forestry.gov.cn/c/www/szxx/594663.jhtml)
- 2026: [国务院办公厅关于2026年部分节假日安排的通知](https://news.cctv.com/2025/11/04/ARTIzBycPZbvvPD4uW0iYbKR251104.shtml)

## Maintenance Policy

每年国务院办公厅发布下一年度节假日安排后，维护者应新增对应年份数据，并补充测试。任何数据变更都必须包含来源 URL，避免项目变成无法审计的“手抄日历”。

## Testing

```bash
dart analyze
dart test
dart run cn_workday_calendar samples
```

测试分两类：

- API 行为测试：覆盖普通工作日、普通周末、法定节假日、调休补班、日期区间统计。
- 数据完整性测试：校验 Dart 内置数据和 `data/holiday_schedules.json` 一致，防止多语言 SDK 后续复用 JSON 时出现平台间结果漂移。

## License

MIT
