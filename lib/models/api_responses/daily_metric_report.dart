class DailyMetricReport {
  final DateTime date;
  final int level;

  DailyMetricReport({required this.date, required this.level});

  factory DailyMetricReport.fromJson(
    Map<String, dynamic> map,
    String levelField,
  ) {
    return DailyMetricReport(
      date: DateTime.parse(map['date']),
      level: (map[levelField] as num).toInt(),
    );
  }
}
