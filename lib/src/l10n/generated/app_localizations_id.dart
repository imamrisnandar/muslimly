// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get settingsIbadah => 'Ibadah';

  @override
  String get hijriAdjustment => 'Koreksi Tanggal Hijriyah';

  @override
  String get hijriAdjustmentSubtitle => 'Sesuaikan jika tanggal berbeda';

  @override
  String get prayerCalculationMethod => 'Metode Perhitungan Waktu Sholat';

  @override
  String get prayerCalculationMethodSingapore => 'Singapura (JAKIM/MUIS)';

  @override
  String get prayerCalculationMethodKemenagRI => 'Kemenag RI';

  @override
  String get days => 'Hari';

  @override
  String get day => 'Hari';

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
  String get bottomNavDzikir => 'Aktivitas';

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
  String get searchCityHint => 'Nama kota (cth. Jakarta)';

  @override
  String get useCurrentLocation => 'Gunakan Lokasi Saat Ini';

  @override
  String get locationNotFound => 'Lokasi tidak ditemukan';

  @override
  String get trySearchingWith => 'Coba cari dengan:';

  @override
  String get searchSuggestionCity => 'Nama kota (cth. Jakarta)';

  @override
  String get searchSuggestionDistrict => 'Nama kecamatan (cth. Bandung Barat)';

  @override
  String get searchSuggestionAddress => 'Alamat lengkap';

  @override
  String get searchForLocation => 'Cari lokasi';

  @override
  String get popularCities => 'Kota populer:';

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
  String get searchSurahHint => 'Cari Surah atau Ayat...';

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
    return '15 menit lagi waktu $prayerName akan tiba. Jangan lupa sempatkan membaca Al-Quran setelah sholat ya.';
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
  String get prayerHeading => 'Insya Allah, Menuju';

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
      'Anda telah menyelesaikan rangkaian zikir ini.';

  @override
  String get dzikirSelectCategory => 'Pilih Kategori';

  @override
  String get dzikirMorningTitle => 'Zikir Pagi';

  @override
  String get dzikirMorningSubtitle => 'Pembuka hari dengan zikir';

  @override
  String get dzikirEveningTitle => 'Zikir Petang';

  @override
  String get dzikirEveningSubtitle => 'Penutup hari dengan ketenangan';

  @override
  String get dzikirPrayerTitle => 'Zikir Sholat';

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
      'Temukan berbagai aktivitas ibadah harian dan panduan belajar di sini.';

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

  @override
  String get lblBookmarks => 'Daftar Penanda';

  @override
  String get tabAyahList => 'Ayat (List)';

  @override
  String get tabPageMushaf => 'Mushaf (Halaman)';

  @override
  String get emptyBookmarkAyahTitle => 'Belum ada bookmark ayat';

  @override
  String get emptyBookmarkAyahSubtitle =>
      'Ayat yang Anda tandai akan muncul di sini';

  @override
  String get emptyBookmarkPageTitle => 'Belum ada bookmark halaman';

  @override
  String get emptyBookmarkPageSubtitle =>
      'Halaman yang Anda tandai akan muncul di sini';

  @override
  String get lblSavedBookmarks => 'BOOKMARK TERSIMPAN';

  @override
  String get lblListType => 'Ayat';

  @override
  String get lblMushafType => 'Mushaf';

  @override
  String get lblAyah => 'Ayat';

  @override
  String get lblPage => 'Hal';

  @override
  String get lblWeek => 'Minggu';

  @override
  String get targetPageExplanation =>
      'Target Halaman dihitung saat membaca di tab Mushaf.';

  @override
  String get targetAyahExplanation =>
      'Target Ayat dihitung saat membaca di mode List/Detail Surah.';

  @override
  String get backgroundRefreshTitle => 'Progres Bacaan Kemarin';

  @override
  String backgroundProgressEncourage(Object progress, Object unit) {
    return 'Kemarin kamu membaca $progress $unit. Yuk, semangat capai target hari ini!';
  }

  @override
  String backgroundProgressFinished(Object target, Object unit) {
    return 'Alhamdulillah, kemarin target $target $unit tercapai! Pertahankan semangatmu.';
  }

  @override
  String get backgroundProgressZero =>
      'Kemarin kamu belum sempat baca Quran. Mulai hari ini dengan bismillah yuk!';

  @override
  String get settingsTestBackground => 'Test Background Fetch';

  @override
  String get settingsTestBackgroundSubtitle =>
      'Jalankan task update harian sekarang';

  @override
  String get showcaseQuranSearch => 'Cari Surah atau Ayat tertentu.';

  @override
  String get showcaseQuranBookmarks => 'Akses bookmark dan ayat favoritmu.';

  @override
  String get showcaseQuranItem =>
      'Ketuk untuk membuka. Pilih tampilan Ayat atau Mushaf.';

  @override
  String get showcaseQuranPlay => 'Ketuk untuk memutar audio Surah.';

  @override
  String get showcaseMarkRead =>
      'Ketuk untuk tandai sudah dibaca dan pantau progresmu.';

  @override
  String get showcaseTafsir => 'Lihat Tafsir dan detail terjemahan.';

  @override
  String get showcasePlayAyah => 'Dengarkan audio untuk ayat ini.';

  @override
  String get settingsResetShowcase => 'Reset Tutorial';

  @override
  String get settingsResetShowcaseSubtitle =>
      'Tampilkan ulang semua tutorial intro.';

  @override
  String get jumpToAyah => 'Lompat ke Ayat';

  @override
  String get showcaseJumpToAyahDesc =>
      'Ketuk di sini untuk melompat cepat ke ayat tertentu';

  @override
  String get navPage => 'Halaman';

  @override
  String get navJuz => 'Juz';

  @override
  String get navSurah => 'Surah';

  @override
  String get hintEnterPage => 'Isi Halaman (1 - 604)';

  @override
  String get goButton => 'Buka Halaman';

  @override
  String startOfJuz(Object number) {
    return 'Mulai Juz $number';
  }

  @override
  String get hizb => 'Hizb';

  @override
  String get rub => 'Rub';

  @override
  String get selectAyah => 'Pilih Ayat';

  @override
  String surahAyahs(Object count) {
    return '$count Ayat';
  }

  @override
  String get showcaseAyahShare => 'Bagikan ayat ini (Teks/Gambar).';

  @override
  String get showcaseAyahBookmark => 'Simpan ayat ini ke Bookmark.';

  @override
  String get showcaseQuranNavigation =>
      'Lompat ke Halaman, Juz, atau Hizb tertentu.';

  @override
  String searchInAyahs(Object query) {
    return 'Cari \'$query\' di dalam Ayat';
  }

  @override
  String searchResultsFor(Object query) {
    return 'Hasil pencarian \'$query\'';
  }

  @override
  String get quranNavigationTitle => 'Navigasi Al-Quran';

  @override
  String get qiblaCompass => 'Arah Kiblat';

  @override
  String get findQiblaDirection => 'Cari Arah Kiblat';

  @override
  String get qiblaDirection => 'Arah Kiblat';

  @override
  String get locationPermissionRequired => 'Izin Lokasi Diperlukan';

  @override
  String get errorReadingCompass => 'Gagal membaca kompas';

  @override
  String get deviceNoSensors => 'Perangkat tidak memiliki sensor';

  @override
  String get compassCalibrateHint =>
      'Putar perangkat membentuk angka 8 untuk kalibrasi';

  @override
  String get onboardingTitle1 => 'Bangun Kebiasaan Mengaji';

  @override
  String get onboardingDesc1 =>
      'Atur target harianmu (misal: 1 Juz atau 4 Halaman) dan pantau istiqomahmu setiap hari.';

  @override
  String get onboardingTitle2 => 'Sahabat Ibadah Terlengkap';

  @override
  String get onboardingDesc2 =>
      'Jadwal sholat akurat, arah kiblat presisi, dan zikir harian dalam satu aplikasi.';

  @override
  String get onboardingTitle3 => 'Syafaat di Hari Kiamat';

  @override
  String get onboardingDesc3 =>
      '\"Bacalah Al-Qur\'an, karena sesungguhnya ia akan datang pada hari kiamat sebagai pemberi syafa\'at bagi pembacanya.\" (HR. Muslim)';

  @override
  String get getStarted => 'Mulai Sekarang';

  @override
  String get share => 'Bagikan';

  @override
  String get continueReadingAyah => 'LANJUT BACA (AYAT)';

  @override
  String get continueReadingPage => 'LANJUT BACA (HALAMAN)';

  @override
  String get showcaseDzikirTitle => 'Aktivitas';

  @override
  String get showcaseSettingsTitle => 'Pengaturan';

  @override
  String get showcaseQuranTabTitle => 'Al-Quran';

  @override
  String get showcaseDailyGoalTitle => 'Target Harian';

  @override
  String get showcaseQuickAccessTitle => 'Akses Cepat';

  @override
  String get showcasePrayerTitle => 'Jadwal Sholat';

  @override
  String sbJumpToAyah(Object ayah, Object page) {
    return 'Lompat ke Ayat $ayah (Hal $page)';
  }

  @override
  String get sbPageNotFound => 'Halaman tidak ditemukan di data.';

  @override
  String sbAyahNotFound(Object ayah) {
    return 'Ayat $ayah tidak ditemukan';
  }

  @override
  String get sbDataNotLoaded => 'Data belum dimuat.';

  @override
  String sbOpeningSurah(Object surah) {
    return 'Membuka $surah...';
  }

  @override
  String get sbNextSurahNotFound => 'Surah berikutnya tidak ditemukan!';

  @override
  String get sbEndOfQuran => 'Akhir Al-Quran';

  @override
  String get sbStartOfQuran => 'Awal Al-Quran';

  @override
  String sbBookmarkedPage(Object page) {
    return 'Halaman $page ditandai';
  }

  @override
  String get sbReadingSaved => 'Riwayat bacaan disimpan!';

  @override
  String get sbAyahBookmarked => 'Ayat berhasil ditandai!';

  @override
  String get searchSortedByRelevance =>
      'Diurutkan berdasar relevansi, untuk detail klik pada ayat';

  @override
  String get qiblaFacing => 'Anda menghadap Kiblat';

  @override
  String get qiblaTurnRight => 'Putar Kanan →';

  @override
  String get qiblaTurnLeft => '← Putar Kiri';

  @override
  String get qiblaLocating => 'Mencari Qiblat...';

  @override
  String get qiblaAligned => 'LURUS';

  @override
  String get qiblaAlignArrow => 'Luruskan panah ke atas';

  @override
  String get qiblaNoSensor => 'Sensor Kompas Tidak Ditemukan';

  @override
  String get sbBookmarkSaved => 'Bookmark tersimpan';

  @override
  String get sbBookmarkRemoved => 'Bookmark dihapus';

  @override
  String sbJumpedToAyah(Object ayah) {
    return 'Pindah ke Ayat $ayah';
  }

  @override
  String get markerAdded => 'Penanda ditambahkan';

  @override
  String get markerRemoved => 'Penanda dihapus';

  @override
  String get markerLimitReached => 'Batas penanda tercapai';

  @override
  String get nextFasting => 'Puasa Berikutnya';

  @override
  String get todayFasting => 'Puasa Hari Ini';

  @override
  String get countdownLabel => 'Menuju Waktu Sholat';

  @override
  String sbRecordedAyahs(Object count) {
    return 'Tercatat $count Ayat telah dibaca!';
  }

  @override
  String get sbLastReadUpdated => 'Posisi terakhir dibaca diperbarui';

  @override
  String get emptyHistorySubtitle => 'Mulai membaca untuk melacak progres Anda';

  @override
  String get lblThisWeek => 'Minggu Ini';

  @override
  String sbPageReadLogged(Object duration, Object page) {
    return 'Halaman $page tercatat ($duration)';
  }

  @override
  String get lblLifetimeTotal => 'Total';

  @override
  String get lblReadingStreak => 'Streak';

  @override
  String get lblDailyAverage => 'Rata-rata/Hari';

  @override
  String get lblAyahs => 'Ayat';

  @override
  String get lblDays => 'Hari';

  @override
  String insightStreakWarning(Object streak, Object unit) {
    return 'Jangan putuskan streak $streak hari! Baca minimal 1 $unit hari ini.';
  }

  @override
  String insightAheadTarget(Object percent) {
    return 'Hebat! Kamu $percent% lebih maju dari target mingguan!';
  }

  @override
  String insightBehindTarget(Object needed, Object remaining, Object unit) {
    return 'Kamu tertinggal $remaining $unit. Coba baca $needed $unit hari ini!';
  }

  @override
  String insightStreakMilestone(Object streak) {
    return 'Streak $streak hari! Pertahankan!';
  }

  @override
  String get insightPerfectWeek =>
      'Minggu sempurna! Kamu mencapai target setiap hari!';

  @override
  String insightDailyRecord(Object max, Object unit) {
    return 'Rekor baru! $max $unit dalam sehari!';
  }

  @override
  String insightLifetimeMilestone(Object total, Object unit) {
    return 'Pencapaian luar biasa! Total bacaan $total $unit!';
  }

  @override
  String insightTargetInfo(Object daily, Object unit, Object weekly) {
    return 'Target: $daily $unit/Hari • $weekly $unit/Minggu';
  }

  @override
  String get guideTitle => 'Panduan Aplikasi';

  @override
  String get guideSubtitle => 'Pelajari cara pencatatan dan target';

  @override
  String get guideTargetTitle => '1. Target & Niat';

  @override
  String get guideTargetDesc =>
      'Atur Target Harian di Pengaturan. **Kamu bisa memilih target berdasarkan Halaman atau Ayat.** Target Mingguan adalah target harian x 7. Kamu bisa menabung bacaan di akhir pekan untuk mengejar target mingguan.';

  @override
  String get guideMushafTitle => '2. Mode Mushaf (Halaman)';

  @override
  String get guideMushafDesc =>
      '• **Timer Otomatis:** Berjalan saat halaman terbuka.\n• **Progres:** Geser ke halaman berikutnya akan mencatat halaman sebelumnya sebagai sudah dibaca (setelah minimal 20 detik membaca).\n• **Tandai Manual:** Gunakan **Tombol Checklist Hijau** (kanan bawah) untuk menyimpan posisi terakhir tanpa pindah halaman.';

  @override
  String get guideListTitle => '3. Mode Ayat (List)';

  @override
  String get guideListDesc =>
      '• **Tanpa Timer:** Fokus pada jumlah ayat, bukan durasi.\n• **Progres:** Tekan ayat dan pilih **Tandai Terakhir Baca**. Kami menghitung selisih ayat baru dari sesi terakhirmu.\n• *Contoh:* Terakhir baca Ayat 5, hari ini tandai Ayat 20. Tercatat: **15 Ayat Baru**.';

  @override
  String get guideInsightTitle => '4. Statistik & Streak';

  @override
  String get guideInsightDesc =>
      '• **Halaman Unik:** Di Mode Mushaf, kami mencatat *Halaman Unik* untuk progres Khatam. Membaca halaman yang sama berulang kali tidak menambah \'Total Halaman\', tapi durasinya tetap dicatat!\n• **Streak:** Baca minimal 1 ayat/halaman setiap hari agar streak tidak putus.';

  @override
  String get lblWeekly => 'Mingguan';

  @override
  String get lblMonthly => 'Bulanan';

  @override
  String get msgEndOfHistory => 'Anda telah mencapai akhir riwayat';

  @override
  String get chartMonthlyTitle => 'Progres Bulanan';

  @override
  String get calendarDayMon => 'Sen';

  @override
  String get calendarDayTue => 'Sel';

  @override
  String get calendarDayWed => 'Rab';

  @override
  String get calendarDayThu => 'Kam';

  @override
  String get calendarDayFri => 'Jum';

  @override
  String get calendarDaySat => 'Sab';

  @override
  String get calendarDaySun => 'Min';

  @override
  String get calendarLegendWajib => 'Wajib';

  @override
  String get calendarLegendSunnah => 'Sunnah';

  @override
  String get calendarLegendHaram => 'Diharamkan';

  @override
  String get fastingRamadan => 'Puasa Ramadan';

  @override
  String get fastingArafah => 'Puasa Arafah';

  @override
  String get fastingAshura => 'Puasa Asyura';

  @override
  String get fastingTasua => 'Puasa Tasu\'a';

  @override
  String get fastingAyyamulBidh => 'Ayyamul Bidh';

  @override
  String get fastingMonday => 'Puasa Senin';

  @override
  String get fastingThursday => 'Puasa Kamis';

  @override
  String get eidFitr => 'Idul Fitri';

  @override
  String get eidAdha => 'Idul Adha';

  @override
  String get daysTasyrik => 'Hari Tasyrik';

  @override
  String get reminderFasting => 'PUASA';

  @override
  String get reminderDzikir => 'ZIKIR';

  @override
  String reminderIftarIn(Object duration) {
    return 'Berbuka $duration lagi';
  }

  @override
  String reminderFastingType(Object type) {
    return 'Puasa $type';
  }

  @override
  String reminderDzikirTime(Object type) {
    return 'Waktunya zikir $type';
  }

  @override
  String get showcaseMiniPlayerTitle => 'Tampilan Mini';

  @override
  String get showcaseMiniPlayerDesc =>
      'Geser ke bawah atau tekan tombol ini (v) untuk tampilan mini.';

  @override
  String get showcaseChangeQoriTitle => 'Ganti Qori';

  @override
  String get showcaseChangeQoriDesc =>
      'Ketuk di sini untuk mengganti penyuara.';

  @override
  String get showcaseRepeatTitle => 'Mode Ulang';

  @override
  String get showcaseRepeatDesc =>
      'Ketuk untuk mengulang satu ayat atau seluruh surat.';

  @override
  String get showcaseSpeedTitle => 'Kecepatan Audio';

  @override
  String get showcaseSpeedDesc => 'Ketuk untuk mengubah kecepatan bacaan.';

  @override
  String get ibadahPracticesSection => 'Amalan Harian';

  @override
  String get ibadahLearningSection => 'Pengetahuan & Panduan';

  @override
  String get ibadahTajweedTitle => 'Belajar Tajwid';

  @override
  String get ibadahTajweedSubtitle => 'Pelajari Hukum Nun Sukun & Mim Sukun';

  @override
  String get ibadahWudhuTitle => 'Tata Cara Wudhu';

  @override
  String get ibadahPrayerTitle => 'Panduan Sholat';

  @override
  String get ibadahPrayerSubtitle => 'Tata cara sholat lengkap';

  @override
  String get ibadahFastingTitle => 'Panduan Puasa';

  @override
  String get ibadahFastingSubtitle => 'Puasa Wajib & Sunnah';

  @override
  String get lblNext => 'Selanjutnya';

  @override
  String get lblPrevious => 'Sebelumnya';

  @override
  String get lblDefinition => 'Definisi';

  @override
  String get lblLetters => 'Huruf';

  @override
  String get lblExamples => 'Contoh Bacaan';

  @override
  String get lblSchedule => 'Jadwal';

  @override
  String get lblCalendar => 'Kalender';

  @override
  String get lblFastingHeader => 'PUASA';

  @override
  String get lblSearch => 'Cari...';

  @override
  String get lblAllCategories => 'Semua';

  @override
  String get msgNoData => 'Tidak ada data';

  @override
  String get msgNoResults => 'Tidak ada hasil ditemukan';

  @override
  String get fastingGuideTitle => 'Panduan Puasa';

  @override
  String get fastingGuideSubtitle => 'Fiqih Puasa';

  @override
  String get searchFastingGuide => 'Cari pembahasan puasa...';

  @override
  String get searchDoa => 'Cari doa...';

  @override
  String get msgNoDoaFound => 'Tidak ditemukan doa';

  @override
  String get wordByWord => 'Per Kata';

  @override
  String get translation => 'Terjemahan';

  @override
  String get readTafsirButton => 'Baca Tafsir Ayat Ini';

  @override
  String get tafsirTitle => 'Tafsir';

  @override
  String get tafsirSourceJalalayn => 'Sumber: Tafsir Jalalayn (Indonesia)';

  @override
  String get tafsirSourceIbnKathir => 'Sumber: Tafsir Ibn Kathir (English)';

  @override
  String get backToTranslation => 'Kembali ke Terjemahan';

  @override
  String get tafsirNotAvailable => 'Tafsir tidak tersedia untuk ayat ini.';

  @override
  String get wudhuGuideTitle => 'Panduan Wudhu';

  @override
  String get wudhuGuideSubtitle => 'Tata Cara Wudhu Praktis & Sesuai Sunnah';

  @override
  String get searchWudhuGuide => 'Cari topik wudhu...';

  @override
  String get prayerGuideSubtitle => 'Panduan Sholat Lengkap Sesuai Sunnah';

  @override
  String get searchPrayerGuide => 'Cari topik sholat...';

  @override
  String get lblSkip => 'Lewati';

  @override
  String get articleTitle => 'Artikel';

  @override
  String get articleSeeAll => 'Lihat Semua';

  @override
  String get articleReadMore => 'Baca Selengkapnya';

  @override
  String get articleSearchHint => 'Cari artikel...';

  @override
  String get articleSearchStart => 'Mulai pencarian...';

  @override
  String get articleNoData => 'Tidak ada artikel ditemukan.';

  @override
  String get articleErrorLoad => 'Gagal memuat artikel';

  @override
  String get articleErrorSearch => 'Gagal mencari artikel';

  @override
  String get articleListTitle => 'Artikel Islami';

  @override
  String get articleListEmpty => 'Belum ada artikel.';

  @override
  String get modeHafalanTitle => 'Mode Hafalan';

  @override
  String get modeHafalanSubtitle => 'Uji hafalan dengan membaca suara';

  @override
  String hafalanAccuracy(Object percent) {
    return 'Selesai! Akurasi: $percent%';
  }

  @override
  String hafalanProgressAyat(Object completed, Object total) {
    return '$completed/$total ayat';
  }

  @override
  String hafalanProgressKata(Object matched, Object total) {
    return '$matched/$total kata';
  }

  @override
  String get authChoiceTitle => 'Mulai Sekarang';

  @override
  String get authChoiceSubtitle => 'Pilih cara untuk melanjutkan';

  @override
  String get authChoiceLogin => 'Masuk dengan Akun';

  @override
  String get authChoiceLoginSubtitle => 'Sinkronkan data di semua perangkat';

  @override
  String get authChoiceRegister => 'Buat Akun Baru';

  @override
  String get authChoiceRegisterSubtitle => 'Bergabung dengan Muslimly gratis';

  @override
  String get authChoiceGuest => 'Lanjut Tanpa Akun';

  @override
  String get authChoiceGuestNote =>
      'Kamu bisa masuk nanti kapan saja melalui Pengaturan';

  @override
  String get loginWelcome => 'Selamat Datang';

  @override
  String get loginSubtitle => 'Masuk ke ruang ibadah harianmu.';

  @override
  String get loginHintPassword => 'Masukkan kata sandi';

  @override
  String get loginForgotPassword => 'Lupa Kata Sandi?';

  @override
  String get loginOr => 'ATAU';

  @override
  String get loginContinueAsGuest => 'Lanjut Tanpa Akun';

  @override
  String get loginNewHere => 'Baru di sini?';

  @override
  String loginWelcomeBack(Object name) {
    return 'Selamat datang kembali, $name!';
  }

  @override
  String get registerSubtitle => 'Bergabung dan sinkronkan progresmu.';

  @override
  String get registerLabelUsername => 'Nama Pengguna';

  @override
  String get registerHintUsername => 'Masukkan nama pengguna';

  @override
  String get registerLabelEmail => 'Email';

  @override
  String get registerHintEmail => 'Masukkan email Anda';

  @override
  String get registerLabelPassword => 'Kata Sandi';

  @override
  String get registerHintPassword => 'Minimal 6 karakter';

  @override
  String get registerErrorAllFields => 'Semua kolom wajib diisi.';

  @override
  String get registerErrorPasswordLength => 'Kata sandi minimal 6 karakter.';

  @override
  String get registerSuccess => 'Akun berhasil dibuat! Silakan masuk.';

  @override
  String get registerErrorFallback => 'Pendaftaran gagal.';

  @override
  String get registerHaveAccount => 'Sudah punya akun?';

  @override
  String get registerLogIn => 'Masuk';

  @override
  String get settingsSecurity => 'Keamanan';

  @override
  String get settingsAccount => 'Akun';

  @override
  String get settingsLogout => 'Keluar';

  @override
  String get settingsLogoutConfirm => 'Yakin ingin keluar dari akun?';

  @override
  String get settingsLogin => 'Masuk';

  @override
  String get settingsLoginSubtitle =>
      'Masuk untuk sinkronisasi data di semua perangkat';

  @override
  String get settingsCreateAccount => 'Buat Akun';

  @override
  String get settingsCreateAccountSubtitle =>
      'Baru di Muslimly? Daftar di sini';

  @override
  String get targetChooseTarget => 'Pilih Target';

  @override
  String settingsMonthAdjustment(Object month) {
    return 'Koreksi $month';
  }

  @override
  String get settingsEmail => 'Email';

  @override
  String get settingsEmailCopied => 'Email disalin ke clipboard';

  @override
  String get forgotPasswordTitle => 'Lupa Password';

  @override
  String get forgotPasswordSubtitle =>
      'Masukkan email untuk menerima kode verifikasi';

  @override
  String get forgotPasswordSendCode => 'Kirim Kode';

  @override
  String get forgotPasswordBackToLogin => 'Kembali ke Login';

  @override
  String get otpVerifyTitle => 'Masukkan Kode OTP';

  @override
  String otpVerifySubtitle(String email) {
    return 'Kami mengirim kode 6 digit ke $email';
  }

  @override
  String get otpVerifyHint => 'Kode 6 digit';

  @override
  String get otpVerifyButton => 'Verifikasi';

  @override
  String get otpVerifyResend => 'Kirim Ulang';

  @override
  String get newPasswordTitle => 'Password Baru';

  @override
  String get newPasswordSubtitle => 'Masukkan password baru Anda di bawah';

  @override
  String get newPasswordLabel => 'PASSWORD BARU';

  @override
  String get newPasswordConfirmLabel => 'KONFIRMASI PASSWORD';

  @override
  String get newPasswordHint => 'Min. 8 karakter';

  @override
  String get newPasswordConfirmHint => 'Ulangi password baru';

  @override
  String get newPasswordButton => 'Reset Password';

  @override
  String get newPasswordMismatch => 'Password tidak cocok';

  @override
  String get newPasswordSuccess => 'Password berhasil direset! Silakan login.';

  @override
  String get settingsUsername => 'Username';

  @override
  String get settingsEditUsername => 'Edit Username';

  @override
  String get settingsChangePassword => 'Ganti Password';

  @override
  String get settingsCurrentPassword => 'Password Saat Ini';

  @override
  String get settingsCurrentPasswordHint => 'Masukkan password saat ini';

  @override
  String get settingsPasswordChanged => 'Password berhasil diubah';

  @override
  String get settingsUsernameUpdated => 'Username berhasil diubah';

  @override
  String get settingsUsernameHint => 'Masukkan username baru';

  @override
  String get settingsDeleteAccount => 'Hapus Akun';

  @override
  String get settingsDeleteAccountTitle => 'Hapus Akun';

  @override
  String get settingsDeleteAccountWarning =>
      'Tindakan ini permanen dan tidak dapat dibatalkan. Semua data Anda akan dihapus.';

  @override
  String get settingsDeleteAccountReason => 'Kenapa Anda pergi?';

  @override
  String get settingsDeleteReasonNoLongerNeed =>
      'Saya tidak lagi membutuhkan aplikasi ini';

  @override
  String get settingsDeleteReasonPrivacy => 'Masalah privasi';

  @override
  String get settingsDeleteReasonNotifications => 'Terlalu banyak notifikasi';

  @override
  String get settingsDeleteReasonBetterApp =>
      'Menemukan aplikasi yang lebih baik';

  @override
  String get settingsDeleteReasonOther => 'Lainnya';

  @override
  String get settingsDeleteReasonOtherHint => 'Ceritakan alasanmu...';

  @override
  String get settingsDeleteOtherTooShort => 'Masukkan minimal 3 kata';

  @override
  String get passwordComplexityHint =>
      'Min. 8 karakter, huruf besar, huruf kecil, dan angka';

  @override
  String get passwordTooWeak =>
      'Password harus min. 8 karakter dan mengandung huruf besar, huruf kecil, dan angka';

  @override
  String get settingsDeleteConfirmButton => 'Hapus Akun Saya';

  @override
  String get settingsDeleteSuccess => 'Akun berhasil dihapus';

  @override
  String get settingsDeleteConfirmTitle => 'Apakah Anda yakin?';

  @override
  String get settingsDeleteConfirmMessage =>
      'Akun dan semua data Anda akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get settingsDeleteConfirmYes => 'Ya, Hapus';

  @override
  String get settingsDeleteConfirmNo => 'Batal';
}
