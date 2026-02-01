import 'dart:math';
import 'package:intl/intl.dart';
import 'package:muslimly/src/core/database/database_service.dart';
import 'package:muslimly/src/features/quran/domain/entities/reading_activity.dart';

/// Script to generate 6 months of dummy reading history data
/// Run this from a test or debug context
Future<void> generateDummyData() async {
  final db = DatabaseService();
  final random = Random();
  final now = DateTime.now();

  print('🚀 Generating 6 months of dummy reading history...');

  // Clear existing history first
  final database = await db.database;
  await database.delete('reading_activity');
  print('🗑️ Cleared existing history');

  int totalActivities = 0;

  // Generate data for last 6 months (180 days)
  for (int daysAgo = 0; daysAgo < 180; daysAgo++) {
    final date = now.subtract(Duration(days: daysAgo));
    final dateStr = DateFormat('yyyy-MM-dd').format(date);

    // Random: 60% chance of reading on any given day
    if (random.nextDouble() > 0.4) {
      // Random number of reading sessions per day (1-5)
      final sessionsCount = random.nextInt(5) + 1;

      for (int session = 0; session < sessionsCount; session++) {
        // Randomly choose between page mode and ayah mode
        final isPageMode = random.nextBool();

        if (isPageMode) {
          // Page mode
          final pageNumber = random.nextInt(604) + 1; // Quran has 604 pages
          final surahNumber = random.nextInt(114) + 1; // 114 surahs
          final durationSeconds = random.nextInt(600) + 60; // 1-10 minutes

          final activity = ReadingActivity(
            date: dateStr,
            pageNumber: pageNumber,
            surahNumber: surahNumber,
            durationSeconds: durationSeconds,
            timestamp: date.millisecondsSinceEpoch,
            mode: 'page',
          );

          await db.insertActivity(activity);
          totalActivities++;
        } else {
          // Ayah mode
          final surahNumber = random.nextInt(114) + 1;
          final startAyah = random.nextInt(20) + 1;
          final endAyah = startAyah + random.nextInt(10) + 1;
          final totalAyahs = endAyah - startAyah + 1;
          final durationSeconds = random.nextInt(900) + 120; // 2-15 minutes

          final activity = ReadingActivity(
            date: dateStr,
            pageNumber: 1, // Placeholder for ayah mode
            surahNumber: surahNumber,
            durationSeconds: durationSeconds,
            timestamp: date.millisecondsSinceEpoch,
            startAyah: startAyah,
            endAyah: endAyah,
            totalAyahs: totalAyahs,
            mode: 'ayah',
          );

          await db.insertActivity(activity);
          totalActivities++;
        }
      }
    }
  }

  print('✅ Generated $totalActivities reading activities over 6 months!');
  print(
    '📊 Data range: ${DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 180)))} to ${DateFormat('yyyy-MM-dd').format(now)}',
  );
}
