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
  String get bottomNavDzikir => 'Dzikir & Doa';

  @override
  String get bottomNavSettings => 'Pengaturan';

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
  String get modeMushafSubtitle => 'Tampilan halaman';

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

  @override
  String notificationPrayerTitle(Object prayerName) {
    return 'Waktu $prayerName Telah Tiba';
  }

  @override
  String notificationPrayerBody(Object prayerName) {
    return 'Mari laksanakan sholat $prayerName sekarang.';
  }

  @override
  String notificationPrePrayerTitle(Object prayerName) {
    return 'Menuju Waktu $prayerName';
  }

  @override
  String notificationPrePrayerBody(Object prayerName) {
    return '15 menit lagi waktu $prayerName akan tiba.';
  }

  @override
  String notificationSmartTitle(Object userName) {
    return 'Assalamualaikum, $userName.';
  }

  @override
  String notificationSmartBodyProgress(Object remaining) {
    return 'Yuk, baca $remaining halaman lagi hari ini! ✨';
  }

  @override
  String notificationSmartBodyStart(Object target) {
    return 'Yuk, baca $target halaman targetmu hari ini! ✨';
  }

  @override
  String get notificationFallbackTitle => 'Waktunya Mengaji 📖';

  @override
  String get notificationFallbackBody => 'Sempatkan baca satu ayat pun baik.';

  @override
  String get nameInputError => 'Mohon masukkan nama Anda';

  @override
  String dzikirReadCount(Object count) {
    return 'Baca ${count}x';
  }

  @override
  String get dzikirTapToCount => 'Tap untuk hitung';

  @override
  String get dzikirFinish => 'Selesai';

  @override
  String get dzikirAlhamdulillah => 'Alhamdulillah';

  @override
  String get dzikirDoneMessage =>
      'Anda telah menyelesaikan rangkaian dzikir ini.';

  @override
  String get dzikirSelectCategory => 'Pilih Kategori';

  @override
  String get dzikirMorningTitle => 'Dzikir Pagi';

  @override
  String get dzikirMorningSubtitle => 'Pembuka hari dengan dzikir';

  @override
  String get dzikirEveningTitle => 'Dzikir Petang';

  @override
  String get dzikirEveningSubtitle => 'Penutup hari dengan ketenangan';

  @override
  String get dzikirPrayerTitle => 'Dzikir Sholat';

  @override
  String get dzikirPrayerSubtitle => 'Wirid setelah sholat fardhu';

  @override
  String get dzikirDailyTitle => 'Doa Harian';

  @override
  String get dzikirDailySubtitle => 'Kumpulan doa sehari-hari';

  @override
  String get comingSoon => 'Segera Hadir';

  @override
  String get fontDownloadError => 'Gagal mengunduh font';

  @override
  String get checkInternetConnection => 'Mohon periksa koneksi internet Anda.';

  @override
  String get tryAgain => 'Coba Lagi';

  @override
  String get showcaseNavigation =>
      'Geser kanan/kiri untuk pindah halaman.\nTekan lama ayat untuk opsi.';

  @override
  String get showcaseBookmark => 'Simpan halaman ini ke bookmark.';

  @override
  String get showcaseCompletion =>
      'Halaman otomatis tertanda selesai setelah 20 detik.\nKetuk untuk tandai manual.';

  @override
  String get showcaseDailyGoal => 'Pantau progres bacaan harianmu di sini.';

  @override
  String get showcaseSettingsGoal =>
      'Atur target bacaan harian di menu Pengaturan.';

  @override
  String get showcasePrayerCard =>
      'Lihat jadwal sholat dan hitung mundur adzan.';

  @override
  String get showcaseQuickAccess => 'Akses cepat ke Bookmark dan Riwayat.';

  @override
  String get showcaseDzikir =>
      'Baca Dzikir pagi/petang dan kumpulan Doa di sini.';

  @override
  String get showcaseQuranTab => 'Ketuk di sini untuk mulai membaca Al-Quran.';

  @override
  String get lblPages => 'Halaman';

  @override
  String get lblReadMore => 'Baca Lagi';

  @override
  String get lblInspiration => 'Inspirasi';

  @override
  String get lblCompleted => 'Selesai! 🎉';

  @override
  String get menuPlay => 'Putar';

  @override
  String get menuTranslation => 'Terjemahan';

  @override
  String get menuTafsir => 'Tafsir';

  @override
  String get menuBookmark => 'Tandai';

  @override
  String get tajwidLegendTitle => 'Panduan Tajwid';

  @override
  String get tajwidGhunnah => 'Ghunnah / Idgham Bighunnah';

  @override
  String get tajwidGhunnahDesc => 'Dengung (2 harakat)';

  @override
  String get tajwidIkhfa => 'Ikhfa';

  @override
  String get tajwidIkhfaDesc => 'Samar-samar (2 harakat)';

  @override
  String get tajwidMadJaiz => 'Mad Jaiz Munfasil';

  @override
  String get tajwidMadJaizDesc => 'Panjang (2/4/5 harakat)';

  @override
  String get tajwidQalqalah => 'Qalqalah';

  @override
  String get tajwidQalqalahDesc => 'Pantulan';

  @override
  String get tajwidIqlab => 'Iqlab';

  @override
  String get tajwidIqlabDesc => 'Membalikkan (Bunyi \'N\' jadi \'M\')';

  @override
  String get tajwidMadWajib => 'Mad Wajib / Lazim';

  @override
  String get tajwidMadWajibDesc => 'Panjang (4-6 harakat)';

  @override
  String get tajwidIdghamBilaghunnah => 'Idgham Bilaghunnah / Tanda Wakaf';

  @override
  String get tajwidIdghamBilaghunnahDesc => 'Dilebur / Tidak dibaca';

  @override
  String get showcaseDraggableTitle => 'Player Fleksibel';

  @override
  String get showcaseDraggableDesc =>
      'Tekan lama & geser player ini untuk memindahkan posisinya';

  @override
  String get showcaseReciterDesc => 'Ganti Qari pilihan Anda di sini';
}
