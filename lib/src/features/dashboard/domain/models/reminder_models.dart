import 'package:flutter/material.dart';
import '../../../prayer/domain/services/fasting_service.dart';

/// Type of dzikir (morning or evening)
enum DzikirType { morning, evening }

/// Status of dzikir reminder
enum DzikirStatus {
  pending, // Belum waktunya
  active, // Sedang waktunya
  completed, // Sudah dibaca
  missed, // Lewat waktu & belum dibaca
}

/// Dzikir reminder data
class DzikirReminder {
  final DzikirType type;
  final DateTime scheduledTime;
  final DzikirStatus status;
  final Duration? timeUntil; // if pending
  final Duration? timeSince; // if active/completed/missed
  final bool isActiveNow;

  DzikirReminder({
    required this.type,
    required this.scheduledTime,
    required this.status,
    this.timeUntil,
    this.timeSince,
    required this.isActiveNow,
  });

  String get displayName => type == DzikirType.morning ? 'Pagi' : 'Petang';

  IconData get icon =>
      type == DzikirType.morning ? Icons.wb_sunny : Icons.wb_twilight;
}

/// Fasting reminder data
class FastingReminder {
  final String
  type; // Keep for backward compatibility if needed, or replace usage.
  final FastingEvent event; // NEW field for localization
  final String fastingTypeName; // "wajib", "sunnah", "haram"
  final DateTime date;
  final bool isToday;
  final DateTime? iftarTime; // Maghrib time for today's fasting
  final Duration? timeUntilIftar;

  FastingReminder({
    required this.type,
    required this.event,
    required this.fastingTypeName,
    required this.date,
    required this.isToday,
    this.iftarTime,
    this.timeUntilIftar,
  });

  Color get color {
    switch (fastingTypeName) {
      case 'wajib':
        return const Color(0xFFFFC107); // Gold
      case 'sunnah':
        return const Color(0xFF00E676); // Green
      case 'haram':
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }
}

/// Complete reminder card data
class ReminderCardData {
  final FastingReminder? todayFasting;
  final FastingReminder? nextFasting;
  final DzikirReminder morningDzikir;
  final DzikirReminder eveningDzikir;
  final DateTime currentTime;

  ReminderCardData({
    this.todayFasting,
    this.nextFasting,
    required this.morningDzikir,
    required this.eveningDzikir,
    required this.currentTime,
  });

  bool get hasTodayFasting => todayFasting != null;
  bool get hasNextFasting => nextFasting != null;
  bool get hasAnyActiveDzikir =>
      morningDzikir.isActiveNow || eveningDzikir.isActiveNow;
}
