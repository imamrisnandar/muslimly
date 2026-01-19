// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Muslimly';

  @override
  String dashboardGreeting(Object name) {
    return 'Assalamu\'alaikum, $name';
  }

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsProfile => 'Profil';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsName => 'Nama';

  @override
  String get settingsSave => 'Simpan';

  @override
  String get settingsLanguageEnglish => 'Inggris';

  @override
  String get settingsLanguageIndonesian => 'Indonesia';

  @override
  String get nameInputTitle => 'Siapa nama panggilanmu?';

  @override
  String get nameInputHint => 'Nama Kamu';

  @override
  String get nameInputButton => 'Mulai';

  @override
  String get commonError => 'Terjadi kesalahan';

  @override
  String get prayerFajr => 'Subuh';

  @override
  String get prayerDhuhr => 'Dzuhur';

  @override
  String get prayerAsr => 'Ashar';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isya';

  @override
  String get bottomNavHome => 'Beranda';

  @override
  String get bottomNavPrayer => 'Jadwal';

  @override
  String get bottomNavQuran => 'Al-Quran';

  @override
  String get bottomNavMurottal => 'Murottal';

  @override
  String get bottomNavArticles => 'Artikel';

  @override
  String get cardNextPrayer => 'Sholat Berikutnya';

  @override
  String get cardDailyGoal => 'Target Harian';

  @override
  String get cardQuickAccess => 'Akses Cepat';

  @override
  String get cardContinueReading => 'Lanjut Baca';

  @override
  String get cardDailyInspiration => 'Inspirasi Harian';

  @override
  String timeRemaining(Object hours, Object minutes) {
    return '$hours jam $minutes menit lagi';
  }

  @override
  String get untilTomorrow => 'Sampai besok';

  @override
  String get upcomingPrayer => 'Akan Datang';

  @override
  String get prayerSchedule => 'Jadwal Sholat';

  @override
  String get searchCityTitle => 'Cari Kota';

  @override
  String get searchCityHint => 'Masukkan nama kota (cth. Jakarta)';

  @override
  String get close => 'Tutup';

  @override
  String get loading => 'Memuat...';

  @override
  String get quranTitle => 'Al-Quran';

  @override
  String versesCount(Object count) {
    return '$count Ayat';
  }

  @override
  String get readingModeTitle => 'Pilih Mode Baca';

  @override
  String get modeListTitle => 'Ayat per Ayat';

  @override
  String get modeListSubtitle => 'Tampilan list dengan terjemahan';

  @override
  String get modeMushafTitle => 'Mushaf Madinah';

  @override
  String get modeMushafSubtitle => 'Tampilan halaman (Arab saja)';

  @override
  String get searchSurahHint => 'Cari Surah (cth. Al-Kahf)';

  @override
  String get aboutTitle => 'Tentang Aplikasi';

  @override
  String get aboutSummary =>
      'Muslimly adalah sahabat modern Anda untuk aktivitas Islami harian. Fitur mencakup jadwal sholat akurat, bacaan Al-Quran, dan pengingat harian.';

  @override
  String get contactTitle => 'Hubungi Pengembang';

  @override
  String get chartWeeklyTitle => 'Ringkasan Mingguan';

  @override
  String get chartLegendTargetReached => 'Target Tercapai';

  @override
  String get chartLegendInProgress => 'Sedang Berjalan';

  @override
  String get chartLegendNoActivity => 'Tidak Ada Aktivitas';

  @override
  String get historyTitle => 'Riwayat Membaca';

  @override
  String targetLabel(Object count) {
    return 'Target: $count halaman/hari';
  }

  @override
  String prayerNotificationTitle(Object prayer) {
    return 'Notifikasi $prayer';
  }

  @override
  String get notificationSoundAdhan => 'Suara Adzan';

  @override
  String get notificationSoundBeep => 'Beep (Standar Sistem)';

  @override
  String get notificationSoundSilent => 'Senyap (Mute)';

  @override
  String get prayerImsak => 'Imsak';

  @override
  String get prayerSunrise => 'Terbit';

  @override
  String get settingsQuran => 'Pengaturan Quran';

  @override
  String get settingsDailyTarget => 'Target Bacaan Harian';

  @override
  String settingsTargetPages(Object count) {
    return '$count Halaman / Hari';
  }

  @override
  String get settingsReadingHistory => 'Riwayat Membaca';

  @override
  String get settingsHistorySubtitle => 'Lihat log aktivitas bacaan';

  @override
  String get settingsDeveloper => 'Opsi Pengembang';

  @override
  String get settingsTestAdhan => 'Test Notifikasi Adzan';

  @override
  String get settingsTestAdhanSubtitle => 'Memicu notifikasi segera';

  @override
  String get settingsTestAdhanTriggered => 'Notifikasi Dipicu!';

  @override
  String get targetSelectTitle => 'Pilih Target Harian';

  @override
  String get targetBeginner => 'Pemula (2 Halaman)';

  @override
  String get targetRoutine => 'Rutin (4 Halaman)';

  @override
  String get targetHalfJuz => 'Setengah Juz (10 Halaman)';

  @override
  String get targetOneJuz => 'Satu Juz (20 Halaman)';

  @override
  String get targetCustom => 'Target Kustom...';

  @override
  String get targetCustomTitle => 'Atur Target Kustom';

  @override
  String get targetCustomHint => 'Masukkan jumlah halaman';

  @override
  String get cancel => 'Batal';

  @override
  String get cardReadingHistory => 'Riwayat Membaca';

  @override
  String get cardReadingHistorySubtitle => 'Lihat catatan bacaan Anda';

  @override
  String get cardContinueReadingSubtitle => 'Lihat penanda yang tersimpan';

  @override
  String get cardDailyInspirationSubtitle => 'Kekuatan Syukur dalam Islam';

  @override
  String get targetReachedMessage => 'MashaAllah, Target Tercapai!';

  @override
  String targetProgress(Object progress, Object target) {
    return '$progress / $target Halaman';
  }

  @override
  String get emptyBookmarkTitle => 'Belum ada penanda';

  @override
  String get emptyBookmarkSubtitle => 'Mulai membaca untuk menambah penanda';

  @override
  String get btnGoToQuran => 'Ke Al-Quran';

  @override
  String get targetHelp =>
      'Progres baca terekam otomatis jika Anda membaca halaman lebih dari 20 detik.';

  @override
  String get markAsRead => 'Tandai Selesai';
}
