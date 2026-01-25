// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Muslimly';

  @override
  String dashboardGreeting(Object name) {
    return 'Assalamu\'alaikum, $name';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsName => 'Name';

  @override
  String get settingsSave => 'Save';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageIndonesian => 'Indonesian';

  @override
  String get nameInputTitle => 'What should we call you?';

  @override
  String get nameInputHint => 'Your Name';

  @override
  String get nameInputButton => 'Get Started';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavPrayer => 'Prayer';

  @override
  String get bottomNavQuran => 'Quran';

  @override
  String get bottomNavDzikir => 'Dzikir & Dua';

  @override
  String get bottomNavSettings => 'Settings';

  @override
  String get cardNextPrayer => 'Next Prayer';

  @override
  String get cardDailyGoal => 'Daily Quran Goal';

  @override
  String get cardQuickAccess => 'Quick Access';

  @override
  String get cardContinueReading => 'Continue Reading';

  @override
  String get cardDailyInspiration => 'Daily Inspiration';

  @override
  String timeRemaining(Object hours, Object minutes) {
    return '$hours h $minutes min remaining';
  }

  @override
  String get untilTomorrow => 'Until tomorrow';

  @override
  String get upcomingPrayer => 'Upcoming';

  @override
  String get prayerSchedule => 'Prayer Schedule';

  @override
  String get searchCityTitle => 'Search City';

  @override
  String get searchCityHint => 'Enter city name (e.g. London)';

  @override
  String get close => 'Close';

  @override
  String get loading => 'Loading...';

  @override
  String get quranTitle => 'Al-Quran';

  @override
  String versesCount(Object count) {
    return '$count Verses';
  }

  @override
  String get readingModeTitle => 'Select Reading Mode';

  @override
  String get modeListTitle => 'Verse by Verse';

  @override
  String get modeListSubtitle => 'List view with translation';

  @override
  String get modeMushafTitle => 'Mushaf Madinah';

  @override
  String get modeMushafSubtitle => 'Page view';

  @override
  String get searchSurahHint => 'Search Surah (e.g. Al-Kahf)';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutSummary =>
      'Muslimly is your modern companion for daily Islamic activities. Features include accurate prayer times, Quran reading, and daily reminders.';

  @override
  String get contactTitle => 'Contact Developer';

  @override
  String get chartWeeklyTitle => 'Weekly Summary';

  @override
  String get chartLegendTargetReached => 'Target Reached';

  @override
  String get chartLegendInProgress => 'In Progress';

  @override
  String get chartLegendNoActivity => 'No Activity';

  @override
  String get historyTitle => 'Reading History';

  @override
  String targetLabel(Object count) {
    return 'Target: $count pages/day';
  }

  @override
  String prayerNotificationTitle(Object prayer) {
    return '$prayer Notification';
  }

  @override
  String get notificationSoundAdhan => 'Adhan Sound (Adzan)';

  @override
  String get notificationSoundBeep => 'Beep (System Default)';

  @override
  String get notificationSoundSilent => 'Silent (Mute)';

  @override
  String get prayerImsak => 'Imsak';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get settingsQuran => 'Quran Settings';

  @override
  String get settingsDailyTarget => 'Daily Reading Target';

  @override
  String settingsTargetPages(Object count) {
    return '$count Pages / Day';
  }

  @override
  String get settingsReadingHistory => 'Reading History';

  @override
  String get settingsHistorySubtitle => 'View your Mushaf reading logs';

  @override
  String get settingsDeveloper => 'Developer Options';

  @override
  String get settingsTestAdhan => 'Test Adhan Notification';

  @override
  String get settingsTestAdhanSubtitle => 'Trigger an immediate notification';

  @override
  String get settingsTestAdhanTriggered => 'Notification Triggered!';

  @override
  String get targetSelectTitle => 'Select Daily Target';

  @override
  String get targetBeginner => 'Beginner (2 Pages)';

  @override
  String get targetRoutine => 'Routine (4 Pages)';

  @override
  String get targetHalfJuz => 'Half Juz (10 Pages)';

  @override
  String get targetOneJuz => 'One Juz (20 Pages)';

  @override
  String get targetCustom => 'Custom Target...';

  @override
  String get targetCustomTitle => 'Set Custom Target';

  @override
  String get targetCustomHint => 'Enter number of pages';

  @override
  String get cancel => 'Cancel';

  @override
  String get cardReadingHistory => 'Reading History';

  @override
  String get cardReadingHistorySubtitle => 'Track your reading logs';

  @override
  String get cardContinueReadingSubtitle => 'View your saved bookmarks';

  @override
  String get cardDailyInspirationSubtitle => 'The Power of Gratitude in Islam';

  @override
  String get targetReachedMessage => 'MashaAllah, Target Reached!';

  @override
  String targetProgress(Object progress, Object target) {
    return '$progress / $target Pages';
  }

  @override
  String get emptyBookmarkTitle => 'No bookmarks yet';

  @override
  String get emptyBookmarkSubtitle => 'Start reading to add bookmarks';

  @override
  String get btnGoToQuran => 'Go to Quran';

  @override
  String get targetHelp =>
      'Reading progress is recorded automatically when you read a page for more than 20 seconds.';

  @override
  String get markAsRead => 'Mark as Read';

  @override
  String notificationPrayerTitle(Object prayerName) {
    return 'Time for $prayerName';
  }

  @override
  String notificationPrayerBody(Object prayerName) {
    return 'Let\'s perform $prayerName prayer now.';
  }

  @override
  String notificationPrePrayerTitle(Object prayerName) {
    return 'Approaching $prayerName';
  }

  @override
  String notificationPrePrayerBody(Object prayerName) {
    return '15 minutes left until $prayerName time.';
  }

  @override
  String notificationSmartTitle(Object userName) {
    return 'Assalamualaikum, $userName.';
  }

  @override
  String notificationSmartBodyProgress(Object remaining) {
    return 'Let\'s read $remaining more pages today! ✨';
  }

  @override
  String notificationSmartBodyStart(Object target) {
    return 'Let\'s start your $target pages goal today! ✨';
  }

  @override
  String get notificationFallbackTitle => 'Time to Read Quran 📖';

  @override
  String get notificationFallbackBody =>
      'Reading even one verse is meaningful.';

  @override
  String get nameInputError => 'Please enter your name';

  @override
  String dzikirReadCount(Object count) {
    return 'Read ${count}x';
  }

  @override
  String get dzikirTapToCount => 'Tap to count';

  @override
  String get dzikirFinish => 'Done';

  @override
  String get dzikirAlhamdulillah => 'Alhamdulillah';

  @override
  String get dzikirDoneMessage => 'You have completed this Dzikir session.';

  @override
  String get dzikirSelectCategory => 'Select Category';

  @override
  String get dzikirMorningTitle => 'Morning Dzikir';

  @override
  String get dzikirMorningSubtitle => 'Start your day with remembrance';

  @override
  String get dzikirEveningTitle => 'Evening Dzikir';

  @override
  String get dzikirEveningSubtitle => 'Close your day with peace';

  @override
  String get dzikirPrayerTitle => 'After Prayer';

  @override
  String get dzikirPrayerSubtitle => 'Dzikir after Fardhu prayer';

  @override
  String get dzikirDailyTitle => 'Daily Dua';

  @override
  String get dzikirDailySubtitle => 'Collection of daily prayers';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get fontDownloadError => 'Failed to download font';

  @override
  String get checkInternetConnection =>
      'Please check your internet connection.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get showcaseNavigation =>
      'Swipe left/right to move pages.\nLong press verse for options.';

  @override
  String get showcaseBookmark => 'Save this page to bookmarks.';

  @override
  String get showcaseCompletion =>
      'Page is marked as read automatically after 20 sec.\nTap to mark manually.';

  @override
  String get showcaseDailyGoal => 'Track your daily reading progress here.';

  @override
  String get showcaseSettingsGoal =>
      'Set your daily reading target in Settings.';

  @override
  String get showcasePrayerCard => 'Check prayer times and countdown.';

  @override
  String get showcaseQuickAccess => 'Quick access to Bookmarks and History.';

  @override
  String get showcaseDzikir => 'Read daily Dzikir and specific Duas here.';

  @override
  String get showcaseQuranTab => 'Tap here to open the Quran.';

  @override
  String get lblPages => 'Pages';

  @override
  String get lblReadMore => 'Read More';

  @override
  String get lblInspiration => 'Inspiration';

  @override
  String get lblCompleted => 'Completed! 🎉';

  @override
  String get menuPlay => 'Play';

  @override
  String get menuTranslation => 'Translation';

  @override
  String get menuTafsir => 'Tafsir';

  @override
  String get menuBookmark => 'Bookmark';

  @override
  String get tajwidLegendTitle => 'Tajweed Guide';

  @override
  String get tajwidGhunnah => 'Ghunnah / Idgham Bighunnah';

  @override
  String get tajwidGhunnahDesc => 'Nasal sound (2 beats)';

  @override
  String get tajwidIkhfa => 'Ikhfa';

  @override
  String get tajwidIkhfaDesc => 'Hidden / Faint (2 beats)';

  @override
  String get tajwidMadJaiz => 'Mad Jaiz Munfasil';

  @override
  String get tajwidMadJaizDesc => 'Long (2/4/5 beats)';

  @override
  String get tajwidQalqalah => 'Qalqalah';

  @override
  String get tajwidQalqalahDesc => 'Bouncing sound';

  @override
  String get tajwidIqlab => 'Iqlab';

  @override
  String get tajwidIqlabDesc => 'N turns into M sound';

  @override
  String get tajwidMadWajib => 'Mad Wajib / Lazim';

  @override
  String get tajwidMadWajibDesc => 'Very Long (4-6 beats)';

  @override
  String get tajwidIdghamBilaghunnah => 'Idgham Bilaghunnah / Waqf';

  @override
  String get tajwidIdghamBilaghunnahDesc => 'Merged / Not pronounced';

  @override
  String get showcaseDraggableTitle => 'Flexible Player';

  @override
  String get showcaseDraggableDesc => 'Long press & drag to move position.';

  @override
  String get showcaseReciterDesc => 'Tap here to change Reciter.';

  @override
  String get lblBookmarks => 'Bookmarks';

  @override
  String get tabAyahList => 'Ayah (List)';

  @override
  String get tabPageMushaf => 'Mushaf (Page)';

  @override
  String get emptyBookmarkAyahTitle => 'No Ayah Bookmarks';

  @override
  String get emptyBookmarkAyahSubtitle => 'Your marked ayahs will appear here';

  @override
  String get emptyBookmarkPageTitle => 'No Page Bookmarks';

  @override
  String get emptyBookmarkPageSubtitle => 'Your marked pages will appear here';

  @override
  String get lblSavedBookmarks => 'SAVED BOOKMARKS';

  @override
  String get lblListType => 'Ayah';

  @override
  String get lblMushafType => 'Mushaf';

  @override
  String get lblAyah => 'Ayah';

  @override
  String get lblPage => 'Page';

  @override
  String get lblWeek => 'Week';

  @override
  String get targetPageExplanation =>
      'Page target is tracked when reading in Mushaf tab.';

  @override
  String get targetAyahExplanation =>
      'Ayah target is tracked when reading in List/Surah Detail mode.';
}
