/// The five obligatory prayers, in daily order.
enum TrackedPrayer {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha;

  String get key => name;

  static TrackedPrayer fromKey(String key) => TrackedPrayer.values.firstWhere(
    (p) => p.name == key,
    orElse: () => throw ArgumentError('Unknown prayer key: $key'),
  );
}

/// What a row in the append-only `prayer_logs` table means.
enum PrayerLogKind {
  /// A slot was prayed (optionally in jama'ah).
  performed,

  /// The user confirmed a slot was missed: adds 1 to the qadha debt.
  missed,

  /// Made up one or more missed prayers (reduces the debt).
  qadhaDone,

  /// Wizard result / manual adjustment of the debt; `count` may be negative.
  qadhaBaseline;

  String get key {
    switch (this) {
      case PrayerLogKind.performed:
        return 'performed';
      case PrayerLogKind.missed:
        return 'missed';
      case PrayerLogKind.qadhaDone:
        return 'qadha_done';
      case PrayerLogKind.qadhaBaseline:
        return 'qadha_baseline';
    }
  }

  static PrayerLogKind fromKey(String key) => PrayerLogKind.values.firstWhere(
    (k) => k.key == key,
    orElse: () => throw ArgumentError('Unknown prayer log kind: $key'),
  );
}

/// One row of the append-only prayer log — the single source of truth.
/// Slot status, streaks and qadha balances are all pure functions of these.
class PrayerLog {
  final int? id;
  final PrayerLogKind kind;
  final TrackedPrayer prayer;

  /// `yyyy-MM-dd`: the date of the slot's window *start* (an Isha after
  /// midnight still belongs to the previous day). Null for qadha entries that
  /// are not tied to a slot.
  final String? slotDate;

  /// Used by qadha kinds (default 1). Signed for [PrayerLogKind.qadhaBaseline].
  final int count;
  final bool inJamaah;
  final DateTime timestamp;
  final bool isSynced;

  const PrayerLog({
    this.id,
    required this.kind,
    required this.prayer,
    this.slotDate,
    this.count = 1,
    this.inJamaah = false,
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'kind': kind.key,
    'prayer': prayer.key,
    'slot_date': slotDate,
    'count': count,
    'in_jamaah': inJamaah ? 1 : 0,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'is_synced': isSynced ? 1 : 0,
  };

  /// Wire format of POST /sync/prayer-logs.
  Map<String, Object?> toSyncJson() => {
    'kind': kind.key,
    'prayer': prayer.key,
    if (slotDate != null) 'slot_date': slotDate,
    'count': count,
    'in_jamaah': inJamaah,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  /// DB-row map for a row received from GET /sync/prayer-logs, or null when it
  /// is malformed (unknown kind/prayer, missing timestamp).
  static Map<String, Object?>? rowFromRemote(Map<String, dynamic> j) {
    try {
      final kind = PrayerLogKind.fromKey(j['kind'] as String);
      final prayer = TrackedPrayer.fromKey(j['prayer'] as String);
      final ts = (j['timestamp'] as num).toInt();
      final slot = j['slot_date'] as String?;
      return {
        'kind': kind.key,
        'prayer': prayer.key,
        'slot_date': (slot == null || slot.isEmpty) ? null : slot,
        'count': (j['count'] as num?)?.toInt() ?? 1,
        'in_jamaah': (j['in_jamaah'] == true) ? 1 : 0,
        'timestamp': ts,
      };
    } catch (_) {
      return null;
    }
  }

  factory PrayerLog.fromMap(Map<String, Object?> m) => PrayerLog(
    id: m['id'] as int?,
    kind: PrayerLogKind.fromKey(m['kind'] as String),
    prayer: TrackedPrayer.fromKey(m['prayer'] as String),
    slotDate: m['slot_date'] as String?,
    count: (m['count'] as int?) ?? 1,
    inJamaah: ((m['in_jamaah'] as int?) ?? 0) == 1,
    timestamp: DateTime.fromMillisecondsSinceEpoch(m['timestamp'] as int),
    isSynced: ((m['is_synced'] as int?) ?? 0) == 1,
  );
}
