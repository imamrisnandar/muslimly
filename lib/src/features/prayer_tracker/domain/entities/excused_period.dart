enum ExcuseKind {
  haid,
  nifas,
  sakit;

  static ExcuseKind fromKey(String k) => ExcuseKind.values.firstWhere(
    (e) => e.name == k,
    orElse: () => ExcuseKind.sakit,
  );
}

/// A stretch of days during which prayer tracking is paused. Local-only: never
/// synced, never logged. Dates are `yyyy-MM-dd` (they compare lexicographically).
class ExcusedPeriod {
  final int? id;
  final ExcuseKind kind;
  final String startDate;

  /// Null while the period is ongoing.
  final String? endDate;

  /// Optional date the user expects it to end; drives the end reminder.
  final String? expectedEndDate;

  const ExcusedPeriod({
    this.id,
    required this.kind,
    required this.startDate,
    this.endDate,
    this.expectedEndDate,
  });

  bool get isActive => endDate == null;

  bool covers(String date) =>
      date.compareTo(startDate) >= 0 &&
      (endDate == null || date.compareTo(endDate!) <= 0);

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'kind': kind.name,
    'start_date': startDate,
    'end_date': endDate,
    'expected_end_date': expectedEndDate,
  };

  factory ExcusedPeriod.fromMap(Map<String, Object?> m) => ExcusedPeriod(
    id: m['id'] as int?,
    kind: ExcuseKind.fromKey(m['kind'] as String),
    startDate: m['start_date'] as String,
    endDate: m['end_date'] as String?,
    expectedEndDate: m['expected_end_date'] as String?,
  );
}
