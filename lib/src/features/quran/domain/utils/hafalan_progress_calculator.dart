import '../../../../core/utils/quran_constants.dart';
import '../entities/hafalan_session.dart';
import 'arabic_text_matcher.dart';

/// Standard Madani mushaf page count — the last surah/juz's page range runs
/// through here since QuranConstants only stores each surah/juz's *start*
/// page.
const int _totalMushafPages = 604;

enum SurahHafalanStatus { belum, sedang, sudah }

class SurahProgress {
  final int surahNumber;
  final SurahHafalanStatus status;

  /// Most recent session timestamp (ms since epoch) touching any page of
  /// this surah, or null if it has never been attempted.
  final int? lastSessionTimestamp;

  /// The most recent session (by timestamp) touching this surah that has
  /// an opt-in recording (§F) attached — null if none does. Not
  /// necessarily the same session as [lastSessionTimestamp]'s: the latest
  /// attempt might not have had recording turned on.
  final int? latestAudioSessionId;
  final String? latestAudioFilePath;
  final bool latestAudioIsSaved;

  const SurahProgress({
    required this.surahNumber,
    required this.status,
    this.lastSessionTimestamp,
    this.latestAudioSessionId,
    this.latestAudioFilePath,
    this.latestAudioIsSaved = false,
  });
}

class JuzProgress {
  final int juzNumber;

  /// Fraction (0.0–1.0) of this juz's pages that have at least one passing
  /// session.
  final double percentage;

  const JuzProgress({required this.juzNumber, required this.percentage});
}

/// Pure projection of the hafalan_sessions log (A) into per-surah status and
/// per-juz completion — no persistence of its own, safe to recompute on
/// every load.
///
/// Threshold rule (product decision, see HAFALAN_TRACKER_PLAN.md §B): a page
/// "counts" the moment ANY session on it passes ArabicTextMatcher.isPass()
/// — not just the latest one. That makes both surah status and juz
/// percentage monotonic: a later low-accuracy re-read of an already-passed
/// page can never un-pass it.
class HafalanProgressCalculator {
  const HafalanProgressCalculator._();

  static int _surahStartPage(int surahNumber) =>
      QuranConstants.surahPageStart[surahNumber] ?? 1;

  static int _surahEndPage(int surahNumber) {
    final nextStart = QuranConstants.surahPageStart[surahNumber + 1];
    return (nextStart ?? (_totalMushafPages + 1)) - 1;
  }

  static int _juzStartPage(int juzNumber) =>
      QuranConstants.juzPageStart[juzNumber] ?? 1;

  static int _juzEndPage(int juzNumber) {
    final nextStart = QuranConstants.juzPageStart[juzNumber + 1];
    return (nextStart ?? (_totalMushafPages + 1)) - 1;
  }

  /// Page numbers with at least one passing session, keyed by page.
  static Set<int> _passingPages(List<HafalanSession> sessions) {
    final passing = <int>{};
    for (final session in sessions) {
      if (ArabicTextMatcher.isPass(session.accuracy)) {
        passing.add(session.pageNumber);
      }
    }
    return passing;
  }

  /// Status + last-touched timestamp for every surah (1–114), derived from
  /// [sessions].
  static List<SurahProgress> calculateSurahProgress(
    List<HafalanSession> sessions,
  ) {
    final passingPages = _passingPages(sessions);

    // Group sessions by page for "any session at all" + last-timestamp look-ups.
    final sessionsByPage = <int, List<HafalanSession>>{};
    for (final session in sessions) {
      sessionsByPage.putIfAbsent(session.pageNumber, () => []).add(session);
    }

    final result = <SurahProgress>[];
    for (int surahNumber = 1; surahNumber <= 114; surahNumber++) {
      final startPage = _surahStartPage(surahNumber);
      final endPage = _surahEndPage(surahNumber);

      bool hasAnySession = false;
      bool allPagesPass = true;
      int? lastTimestamp;
      HafalanSession? latestAudioSession;

      for (int page = startPage; page <= endPage; page++) {
        final pageSessions = sessionsByPage[page];
        if (pageSessions != null && pageSessions.isNotEmpty) {
          hasAnySession = true;
          for (final s in pageSessions) {
            if (lastTimestamp == null || s.timestamp > lastTimestamp) {
              lastTimestamp = s.timestamp;
            }
            if (s.audioFilePath != null &&
                (latestAudioSession == null ||
                    s.timestamp > latestAudioSession.timestamp)) {
              latestAudioSession = s;
            }
          }
        }
        if (!passingPages.contains(page)) {
          allPagesPass = false;
        }
      }

      final status = !hasAnySession
          ? SurahHafalanStatus.belum
          : (allPagesPass
                ? SurahHafalanStatus.sudah
                : SurahHafalanStatus.sedang);

      result.add(
        SurahProgress(
          surahNumber: surahNumber,
          status: status,
          lastSessionTimestamp: lastTimestamp,
          latestAudioSessionId: latestAudioSession?.id,
          latestAudioFilePath: latestAudioSession?.audioFilePath,
          latestAudioIsSaved: latestAudioSession?.isAudioSaved == 1,
        ),
      );
    }
    return result;
  }

  /// Completion percentage for every juz (1–30), derived from [sessions].
  static List<JuzProgress> calculateJuzProgress(List<HafalanSession> sessions) {
    final passingPages = _passingPages(sessions);

    final result = <JuzProgress>[];
    for (int juzNumber = 1; juzNumber <= 30; juzNumber++) {
      final startPage = _juzStartPage(juzNumber);
      final endPage = _juzEndPage(juzNumber);
      final totalPages = endPage - startPage + 1;

      int passedCount = 0;
      for (int page = startPage; page <= endPage; page++) {
        if (passingPages.contains(page)) passedCount++;
      }

      result.add(
        JuzProgress(
          juzNumber: juzNumber,
          percentage: totalPages > 0 ? passedCount / totalPages : 0.0,
        ),
      );
    }
    return result;
  }

  /// Total ayat considered "hafal" — the ayahCount of every page with at
  /// least one passing session, summed once per page (not once per session).
  static int calculateTotalAyatHafal(List<HafalanSession> sessions) {
    final passingPages = _passingPages(sessions);
    final ayahCountByPage = <int, int>{};
    for (final session in sessions) {
      if (passingPages.contains(session.pageNumber)) {
        ayahCountByPage[session.pageNumber] = session.ayahCount;
      }
    }
    return ayahCountByPage.values.fold(0, (sum, count) => sum + count);
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static String _fmtDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  /// Consecutive-day hafalan streak, with a "shield": one gap day per
  /// rolling 7-day window doesn't break it (HAFALAN_TRACKER_PLAN.md §E
  /// Riset #2 point 1 — a child missing one day to illness/travel shouldn't
  /// lose all motivation progress). Shares the same date-walk shape as
  /// ReadingBloc's _calculateLifetimeStats streak (unique dates from the
  /// log, anchored at today-or-yesterday, walked backward day by day) —
  /// deliberately independent of that log/table, not reused.
  ///
  /// A shielded day doesn't itself count toward the streak number, it just
  /// doesn't reset it to zero. The shield refills every 7 days walked
  /// (whether or not it was used), so at most 1 gap per calendar week of
  /// history is forgiven.
  static int calculateHafalanStreak(List<HafalanSession> sessions) {
    if (sessions.isEmpty) return 0;

    final sessionDates = sessions.map((s) => s.date).toSet();
    final earliestDate = sessionDates
        .map(DateTime.parse)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    DateTime? anchor;
    if (sessionDates.contains(_fmtDate(today))) {
      anchor = today;
    } else if (sessionDates.contains(_fmtDate(yesterday))) {
      anchor = yesterday;
    }
    if (anchor == null) return 0;

    int streak = 0;
    int daysWalked = 0;
    bool shieldAvailable = true;
    DateTime cursor = anchor;

    // Bounded by the earliest recorded session date — without this, a
    // history with a session roughly every 7 days would let the shield
    // refill forever and walk back indefinitely.
    while (!cursor.isBefore(earliestDate)) {
      if (sessionDates.contains(_fmtDate(cursor))) {
        streak++;
      } else if (shieldAvailable) {
        shieldAvailable = false;
      } else {
        break;
      }
      daysWalked++;
      if (daysWalked % 7 == 0) shieldAvailable = true;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
