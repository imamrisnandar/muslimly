import 'prayer_log.dart';

/// One prayer on one day, with its time window as absolute instants (UTC).
class PrayerSlot {
  final String date; // yyyy-MM-dd of the window start
  final TrackedPrayer prayer;
  final DateTime start;
  final DateTime end;

  const PrayerSlot({
    required this.date,
    required this.prayer,
    required this.start,
    required this.end,
  });

  String get id => '$date/${prayer.key}';

  bool isOpenAt(DateTime now) => !now.isBefore(start) && now.isBefore(end);
}

enum SlotStatus {
  /// Window has not started yet.
  upcoming,

  /// Inside the window, nothing logged.
  open,

  /// Window ended without any log. The user decides: prayed or missed — it is
  /// never turned into a debt automatically.
  unrecorded,

  performed,
  missed,

  /// The slot's date is inside an excused period (projected at read time;
  /// nothing is stored per slot). A logged entry still wins over this.
  excused,
}

class SlotView {
  final PrayerSlot slot;
  final SlotStatus status;
  final bool inJamaah;

  /// Only meaningful when [status] is [SlotStatus.performed]: the check-in was
  /// made before the window closed.
  final bool onTime;

  const SlotView({
    required this.slot,
    required this.status,
    this.inJamaah = false,
    this.onTime = false,
  });
}
