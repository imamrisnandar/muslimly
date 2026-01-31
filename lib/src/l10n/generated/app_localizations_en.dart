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
  String get searchSurahHint => 'Search Surah or Ayah...';

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
    return '15 minutes left until $prayerName time. Don\'t forget to read Quran after prayer.';
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

  @override
  String get backgroundRefreshTitle => 'Yesterday\'s Progress';

  @override
  String backgroundProgressEncourage(Object progress, Object unit) {
    return 'Yesterday you read $progress ${unit}s. Let\'s try to hit the target today!';
  }

  @override
  String backgroundProgressFinished(Object target, Object unit) {
    return 'Alhamdulillah, you hit the $target $unit target yesterday! Keep it up.';
  }

  @override
  String get backgroundProgressZero =>
      'You didn\'t read Quran yesterday. Let\'s start fresh today with Bismillah!';

  @override
  String get settingsTestBackground => 'Test Background Fetch';

  @override
  String get settingsTestBackgroundSubtitle => 'Run daily update task now';

  @override
  String get showcaseQuranSearch => 'Search specific Surah or Ayah.';

  @override
  String get showcaseQuranBookmarks =>
      'Access your bookmarks and favorite verses.';

  @override
  String get showcaseQuranItem =>
      'Tap to open. Choose between Ayah or Mushaf view.';

  @override
  String get showcaseQuranPlay => 'Tap to play the Surah audio.';

  @override
  String get showcaseMarkRead =>
      'Tap to mark this ayah as read and track your progress.';

  @override
  String get showcaseTafsir => 'View Tafsir and detailed translation.';

  @override
  String get showcasePlayAyah => 'Listen to the audio of this ayah.';

  @override
  String get settingsResetShowcase => 'Reset Showcase';

  @override
  String get settingsResetShowcaseSubtitle =>
      'Reset all tutorials to see them again.';

  @override
  String get jumpToAyah => 'Jump to Ayah';

  @override
  String get showcaseJumpToAyahDesc =>
      'Tap here to quickly navigate to a specific Ayah';

  @override
  String get navPage => 'Page';

  @override
  String get navJuz => 'Juz';

  @override
  String get navSurah => 'Surah';

  @override
  String get hintEnterPage => 'Enter Page (1 - 604)';

  @override
  String get goButton => 'Go to Page';

  @override
  String startOfJuz(Object number) {
    return 'Start of Juz $number';
  }

  @override
  String get hizb => 'Hizb';

  @override
  String get rub => 'Rub';

  @override
  String get selectAyah => 'Select Ayah';

  @override
  String surahAyahs(Object count) {
    return '$count Ayahs';
  }

  @override
  String get showcaseAyahShare => 'Share this Ayah text or image.';

  @override
  String get showcaseAyahBookmark => 'Bookmark this Ayah to read later.';

  @override
  String get showcaseQuranNavigation => 'Jump to specific Page, Juz, or Hizb.';

  @override
  String searchInAyahs(Object query) {
    return 'Search \'$query\' in Ayahs';
  }

  @override
  String searchResultsFor(Object query) {
    return 'Search results for \'$query\'';
  }

  @override
  String get quranNavigationTitle => 'Quran Navigation';

  @override
  String get qiblaCompass => 'Qibla Compass';

  @override
  String get findQiblaDirection => 'Find Qibla Direction';

  @override
  String get qiblaDirection => 'Qibla Direction';

  @override
  String get locationPermissionRequired => 'Location Permission Required';

  @override
  String get errorReadingCompass => 'Error reading compass';

  @override
  String get deviceNoSensors => 'Device does not have sensors';

  @override
  String get compassCalibrateHint =>
      'Rotate your device in a figure 8 pattern to calibrate';

  @override
  String get onboardingTitle1 => 'Build a Reading Habit';

  @override
  String get onboardingDesc1 =>
      'Set your daily target (e.g. 1 Juz or 4 Pages) and track your consistency every day.';

  @override
  String get onboardingTitle2 => 'Complete Worship Companion';

  @override
  String get onboardingDesc2 =>
      'Accurate prayer times, precise Qibla direction, and daily Dzikir in one app.';

  @override
  String get onboardingTitle3 => 'Intercession in the Hereafter';

  @override
  String get onboardingDesc3 =>
      '\"Read the Quran, for indeed it will come on the Day of Resurrection as an intercessor for its companions.\" (Muslim)';

  @override
  String get getStarted => 'Get Started';

  @override
  String get share => 'Share';

  @override
  String get continueReadingAyah => 'CONTINUE READING (AYAH)';

  @override
  String get continueReadingPage => 'CONTINUE READING (PAGE)';

  @override
  String get showcaseDzikirTitle => 'Dzikir & Dua';

  @override
  String get showcaseSettingsTitle => 'Settings';

  @override
  String get showcaseQuranTabTitle => 'Quran';

  @override
  String get showcaseDailyGoalTitle => 'Daily Goal';

  @override
  String get showcaseQuickAccessTitle => 'Quick Access';

  @override
  String get showcasePrayerTitle => 'Prayer Times';

  @override
  String sbJumpToAyah(Object ayah, Object page) {
    return 'Jumped to Ayah $ayah (Page $page)';
  }

  @override
  String get sbPageNotFound => 'Page not found in loaded data.';

  @override
  String sbAyahNotFound(Object ayah) {
    return 'Could not find Ayah $ayah';
  }

  @override
  String get sbDataNotLoaded => 'Data not loaded yet.';

  @override
  String sbOpeningSurah(Object surah) {
    return 'Opening $surah...';
  }

  @override
  String get sbNextSurahNotFound => 'Next Surah Not Found!';

  @override
  String get sbEndOfQuran => 'End of Quran';

  @override
  String get sbStartOfQuran => 'Start of Quran';

  @override
  String sbBookmarkedPage(Object page) {
    return 'Bookmarked Page $page';
  }

  @override
  String get sbReadingSaved => 'Reading progress saved!';

  @override
  String get sbAyahBookmarked => 'Ayah Bookmarked!';

  @override
  String get searchSortedByRelevance =>
      'Sorted by relevance, for details click on the ayah';

  @override
  String get qiblaFacing => 'You are facing Qibla';

  @override
  String get qiblaTurnRight => 'Turn Right →';

  @override
  String get qiblaTurnLeft => '← Turn Left';

  @override
  String get qiblaLocating => 'Locating Qibla...';

  @override
  String get qiblaAligned => 'ALIGNED';

  @override
  String get qiblaAlignArrow => 'Align the arrow to the top';

  @override
  String get qiblaNoSensor => 'No Compass Sensor';

  @override
  String get sbBookmarkSaved => 'Bookmark saved';

  @override
  String get sbBookmarkRemoved => 'Bookmark removed';

  @override
  String sbJumpedToAyah(Object ayah) {
    return 'Jumped to Ayah $ayah';
  }

  @override
  String sbRecordedAyahs(Object count) {
    return 'Recorded $count Ayahs read!';
  }

  @override
  String get sbLastReadUpdated => 'Last read position updated';

  @override
  String get emptyHistorySubtitle => 'Start reading to track your progress';

  @override
  String get lblThisWeek => 'This Week';

  @override
  String sbPageReadLogged(Object duration, Object page) {
    return 'Page $page recorded (${duration}s)';
  }

  @override
  String get lblLifetimeTotal => 'Total';

  @override
  String get lblReadingStreak => 'Streak';

  @override
  String get lblDailyAverage => 'Avg/Day';

  @override
  String get lblAyahs => 'Ayahs';

  @override
  String get lblDays => 'Days';

  @override
  String insightStreakWarning(Object streak, Object unit) {
    return 'Don\'t break your $streak-day streak! Read at least 1 $unit today.';
  }

  @override
  String insightAheadTarget(Object percent) {
    return 'Great job! You\'re $percent% ahead of your weekly target!';
  }

  @override
  String insightBehindTarget(Object needed, Object remaining, Object unit) {
    return 'You\'re behind by $remaining $unit. Try reading $needed $unit today!';
  }

  @override
  String insightStreakMilestone(Object streak) {
    return '$streak-day streak! Keep it up!';
  }

  @override
  String get insightPerfectWeek =>
      'Perfect week! You\'ve reached your target every day!';

  @override
  String insightDailyRecord(Object max, Object unit) {
    return 'New Record! $max $unit in a single day!';
  }

  @override
  String insightLifetimeMilestone(Object total, Object unit) {
    return 'Amazing! You\'ve reached $total $unit lifetime total!';
  }

  @override
  String insightTargetInfo(Object daily, Object unit, Object weekly) {
    return 'Target: $daily $unit/Day • $weekly $unit/Week';
  }

  @override
  String get guideTitle => 'App Guide';

  @override
  String get guideSubtitle => 'Learn about tracking and targets';

  @override
  String get guideTargetTitle => '1. Targets & Goals';

  @override
  String get guideTargetDesc =>
      'Set your Daily Target in Settings. **You can choose to track by Pages or Ayahs.** Your Weekly Target is simply your daily target x 7. You can accumulate reading on weekends to meet the weekly goal.';

  @override
  String get guideMushafTitle => '2. Mushaf Mode (Page View)';

  @override
  String get guideMushafDesc =>
      '• **Timer:** Starts automatically when you open a page.\n• **Progress:** Swiping to the next page counts the previous one as read (after reading for at least 20 seconds).\n• **Manual Mark:** Use the **Green Checklist Button** (bottom right) to save your last position without changing pages.';

  @override
  String get guideListTitle => '3. List Mode (Ayah View)';

  @override
  String get guideListDesc =>
      '• **No Timer:** We focus on Ayah count here, not duration.\n• **Progress:** Tap an ayah and select **Mark as Last Read**. We calculate how many new ayahs you\'ve read since your last session.\n• *Example:* If you last read Ayah 5, and today mark Ayah 20, we record **15 new ayahs**.';

  @override
  String get guideInsightTitle => '4. Stats & Streak';

  @override
  String get guideInsightDesc =>
      '• **Unique Pages:** In Mushaf Mode, we track *Unique Pages* for Khatam progress. Reading the same page twice won\'t double your \'Total Pages\' count, but the duration is added!\n• **Streak:** Read at least 1 ayah/page daily to keep your streak alive.';
}
