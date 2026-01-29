import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Muslimly'**
  String get appTitle;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Assalamu\'alaikum, {name}'**
  String dashboardGreeting(Object name);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get settingsName;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSave;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get settingsLanguageIndonesian;

  /// No description provided for @nameInputTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get nameInputTitle;

  /// No description provided for @nameInputHint.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get nameInputHint;

  /// No description provided for @nameInputButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get nameInputButton;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonError;

  /// No description provided for @prayerFajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get prayerFajr;

  /// No description provided for @prayerDhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get prayerDhuhr;

  /// No description provided for @prayerAsr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get prayerAsr;

  /// No description provided for @prayerMaghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get prayerMaghrib;

  /// No description provided for @prayerIsha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get prayerIsha;

  /// No description provided for @bottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// No description provided for @bottomNavPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get bottomNavPrayer;

  /// No description provided for @bottomNavQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get bottomNavQuran;

  /// No description provided for @bottomNavDzikir.
  ///
  /// In en, this message translates to:
  /// **'Dzikir & Dua'**
  String get bottomNavDzikir;

  /// No description provided for @bottomNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get bottomNavSettings;

  /// No description provided for @cardNextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get cardNextPrayer;

  /// No description provided for @cardDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Quran Goal'**
  String get cardDailyGoal;

  /// No description provided for @cardQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get cardQuickAccess;

  /// No description provided for @cardContinueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get cardContinueReading;

  /// No description provided for @cardDailyInspiration.
  ///
  /// In en, this message translates to:
  /// **'Daily Inspiration'**
  String get cardDailyInspiration;

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min remaining'**
  String timeRemaining(Object hours, Object minutes);

  /// No description provided for @untilTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Until tomorrow'**
  String get untilTomorrow;

  /// No description provided for @upcomingPrayer.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingPrayer;

  /// No description provided for @prayerSchedule.
  ///
  /// In en, this message translates to:
  /// **'Prayer Schedule'**
  String get prayerSchedule;

  /// No description provided for @searchCityTitle.
  ///
  /// In en, this message translates to:
  /// **'Search City'**
  String get searchCityTitle;

  /// No description provided for @searchCityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter city name (e.g. London)'**
  String get searchCityHint;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @quranTitle.
  ///
  /// In en, this message translates to:
  /// **'Al-Quran'**
  String get quranTitle;

  /// No description provided for @versesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Verses'**
  String versesCount(Object count);

  /// No description provided for @readingModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Reading Mode'**
  String get readingModeTitle;

  /// No description provided for @modeListTitle.
  ///
  /// In en, this message translates to:
  /// **'Verse by Verse'**
  String get modeListTitle;

  /// No description provided for @modeListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'List view with translation'**
  String get modeListSubtitle;

  /// No description provided for @modeMushafTitle.
  ///
  /// In en, this message translates to:
  /// **'Mushaf Madinah'**
  String get modeMushafTitle;

  /// No description provided for @modeMushafSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Page view'**
  String get modeMushafSubtitle;

  /// No description provided for @searchSurahHint.
  ///
  /// In en, this message translates to:
  /// **'Search Surah or Ayah...'**
  String get searchSurahHint;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutSummary.
  ///
  /// In en, this message translates to:
  /// **'Muslimly is your modern companion for daily Islamic activities. Features include accurate prayer times, Quran reading, and daily reminders.'**
  String get aboutSummary;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Developer'**
  String get contactTitle;

  /// No description provided for @chartWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get chartWeeklyTitle;

  /// No description provided for @chartLegendTargetReached.
  ///
  /// In en, this message translates to:
  /// **'Target Reached'**
  String get chartLegendTargetReached;

  /// No description provided for @chartLegendInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get chartLegendInProgress;

  /// No description provided for @chartLegendNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No Activity'**
  String get chartLegendNoActivity;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading History'**
  String get historyTitle;

  /// No description provided for @targetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target: {count} pages/day'**
  String targetLabel(Object count);

  /// No description provided for @prayerNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'{prayer} Notification'**
  String prayerNotificationTitle(Object prayer);

  /// No description provided for @notificationSoundAdhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan Sound (Adzan)'**
  String get notificationSoundAdhan;

  /// No description provided for @notificationSoundBeep.
  ///
  /// In en, this message translates to:
  /// **'Beep (System Default)'**
  String get notificationSoundBeep;

  /// No description provided for @notificationSoundSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent (Mute)'**
  String get notificationSoundSilent;

  /// No description provided for @prayerImsak.
  ///
  /// In en, this message translates to:
  /// **'Imsak'**
  String get prayerImsak;

  /// No description provided for @prayerSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get prayerSunrise;

  /// No description provided for @settingsQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran Settings'**
  String get settingsQuran;

  /// No description provided for @settingsDailyTarget.
  ///
  /// In en, this message translates to:
  /// **'Daily Reading Target'**
  String get settingsDailyTarget;

  /// No description provided for @settingsTargetPages.
  ///
  /// In en, this message translates to:
  /// **'{count} Pages / Day'**
  String settingsTargetPages(Object count);

  /// No description provided for @settingsReadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Reading History'**
  String get settingsReadingHistory;

  /// No description provided for @settingsHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your Mushaf reading logs'**
  String get settingsHistorySubtitle;

  /// No description provided for @settingsDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer Options'**
  String get settingsDeveloper;

  /// No description provided for @settingsTestAdhan.
  ///
  /// In en, this message translates to:
  /// **'Test Adhan Notification'**
  String get settingsTestAdhan;

  /// No description provided for @settingsTestAdhanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trigger an immediate notification'**
  String get settingsTestAdhanSubtitle;

  /// No description provided for @settingsTestAdhanTriggered.
  ///
  /// In en, this message translates to:
  /// **'Notification Triggered!'**
  String get settingsTestAdhanTriggered;

  /// No description provided for @targetSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Daily Target'**
  String get targetSelectTitle;

  /// No description provided for @targetBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner (2 Pages)'**
  String get targetBeginner;

  /// No description provided for @targetRoutine.
  ///
  /// In en, this message translates to:
  /// **'Routine (4 Pages)'**
  String get targetRoutine;

  /// No description provided for @targetHalfJuz.
  ///
  /// In en, this message translates to:
  /// **'Half Juz (10 Pages)'**
  String get targetHalfJuz;

  /// No description provided for @targetOneJuz.
  ///
  /// In en, this message translates to:
  /// **'One Juz (20 Pages)'**
  String get targetOneJuz;

  /// No description provided for @targetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Target...'**
  String get targetCustom;

  /// No description provided for @targetCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Custom Target'**
  String get targetCustomTitle;

  /// No description provided for @targetCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Enter number of pages'**
  String get targetCustomHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cardReadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Reading History'**
  String get cardReadingHistory;

  /// No description provided for @cardReadingHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your reading logs'**
  String get cardReadingHistorySubtitle;

  /// No description provided for @cardContinueReadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your saved bookmarks'**
  String get cardContinueReadingSubtitle;

  /// No description provided for @cardDailyInspirationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The Power of Gratitude in Islam'**
  String get cardDailyInspirationSubtitle;

  /// No description provided for @targetReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'MashaAllah, Target Reached!'**
  String get targetReachedMessage;

  /// No description provided for @targetProgress.
  ///
  /// In en, this message translates to:
  /// **'{progress} / {target} Pages'**
  String targetProgress(Object progress, Object target);

  /// No description provided for @emptyBookmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get emptyBookmarkTitle;

  /// No description provided for @emptyBookmarkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start reading to add bookmarks'**
  String get emptyBookmarkSubtitle;

  /// No description provided for @btnGoToQuran.
  ///
  /// In en, this message translates to:
  /// **'Go to Quran'**
  String get btnGoToQuran;

  /// No description provided for @targetHelp.
  ///
  /// In en, this message translates to:
  /// **'Reading progress is recorded automatically when you read a page for more than 20 seconds.'**
  String get targetHelp;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get markAsRead;

  /// No description provided for @notificationPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for {prayerName}'**
  String notificationPrayerTitle(Object prayerName);

  /// No description provided for @notificationPrayerBody.
  ///
  /// In en, this message translates to:
  /// **'Let\'s perform {prayerName} prayer now.'**
  String notificationPrayerBody(Object prayerName);

  /// No description provided for @notificationPrePrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Approaching {prayerName}'**
  String notificationPrePrayerTitle(Object prayerName);

  /// No description provided for @notificationPrePrayerBody.
  ///
  /// In en, this message translates to:
  /// **'15 minutes left until {prayerName} time.'**
  String notificationPrePrayerBody(Object prayerName);

  /// No description provided for @notificationSmartTitle.
  ///
  /// In en, this message translates to:
  /// **'Assalamualaikum, {userName}.'**
  String notificationSmartTitle(Object userName);

  /// No description provided for @notificationSmartBodyProgress.
  ///
  /// In en, this message translates to:
  /// **'Let\'s read {remaining} more pages today! ✨'**
  String notificationSmartBodyProgress(Object remaining);

  /// No description provided for @notificationSmartBodyStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start your {target} pages goal today! ✨'**
  String notificationSmartBodyStart(Object target);

  /// No description provided for @notificationFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to Read Quran 📖'**
  String get notificationFallbackTitle;

  /// No description provided for @notificationFallbackBody.
  ///
  /// In en, this message translates to:
  /// **'Reading even one verse is meaningful.'**
  String get notificationFallbackBody;

  /// No description provided for @nameInputError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get nameInputError;

  /// No description provided for @dzikirReadCount.
  ///
  /// In en, this message translates to:
  /// **'Read {count}x'**
  String dzikirReadCount(Object count);

  /// No description provided for @dzikirTapToCount.
  ///
  /// In en, this message translates to:
  /// **'Tap to count'**
  String get dzikirTapToCount;

  /// No description provided for @dzikirFinish.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dzikirFinish;

  /// No description provided for @dzikirAlhamdulillah.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah'**
  String get dzikirAlhamdulillah;

  /// No description provided for @dzikirDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'You have completed this Dzikir session.'**
  String get dzikirDoneMessage;

  /// No description provided for @dzikirSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get dzikirSelectCategory;

  /// No description provided for @dzikirMorningTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning Dzikir'**
  String get dzikirMorningTitle;

  /// No description provided for @dzikirMorningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your day with remembrance'**
  String get dzikirMorningSubtitle;

  /// No description provided for @dzikirEveningTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening Dzikir'**
  String get dzikirEveningTitle;

  /// No description provided for @dzikirEveningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Close your day with peace'**
  String get dzikirEveningSubtitle;

  /// No description provided for @dzikirPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'After Prayer'**
  String get dzikirPrayerTitle;

  /// No description provided for @dzikirPrayerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dzikir after Fardhu prayer'**
  String get dzikirPrayerSubtitle;

  /// No description provided for @dzikirDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Dua'**
  String get dzikirDailyTitle;

  /// No description provided for @dzikirDailySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Collection of daily prayers'**
  String get dzikirDailySubtitle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @fontDownloadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to download font'**
  String get fontDownloadError;

  /// No description provided for @checkInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection.'**
  String get checkInternetConnection;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @showcaseNavigation.
  ///
  /// In en, this message translates to:
  /// **'Swipe left/right to move pages.\nLong press verse for options.'**
  String get showcaseNavigation;

  /// No description provided for @showcaseBookmark.
  ///
  /// In en, this message translates to:
  /// **'Save this page to bookmarks.'**
  String get showcaseBookmark;

  /// No description provided for @showcaseCompletion.
  ///
  /// In en, this message translates to:
  /// **'Page is marked as read automatically after 20 sec.\nTap to mark manually.'**
  String get showcaseCompletion;

  /// No description provided for @showcaseDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Track your daily reading progress here.'**
  String get showcaseDailyGoal;

  /// No description provided for @showcaseSettingsGoal.
  ///
  /// In en, this message translates to:
  /// **'Set your daily reading target in Settings.'**
  String get showcaseSettingsGoal;

  /// No description provided for @showcasePrayerCard.
  ///
  /// In en, this message translates to:
  /// **'Check prayer times and countdown.'**
  String get showcasePrayerCard;

  /// No description provided for @showcaseQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick access to Bookmarks and History.'**
  String get showcaseQuickAccess;

  /// No description provided for @showcaseDzikir.
  ///
  /// In en, this message translates to:
  /// **'Read daily Dzikir and specific Duas here.'**
  String get showcaseDzikir;

  /// No description provided for @showcaseQuranTab.
  ///
  /// In en, this message translates to:
  /// **'Tap here to open the Quran.'**
  String get showcaseQuranTab;

  /// No description provided for @lblPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get lblPages;

  /// No description provided for @lblReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get lblReadMore;

  /// No description provided for @lblInspiration.
  ///
  /// In en, this message translates to:
  /// **'Inspiration'**
  String get lblInspiration;

  /// No description provided for @lblCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed! 🎉'**
  String get lblCompleted;

  /// No description provided for @menuPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get menuPlay;

  /// No description provided for @menuTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get menuTranslation;

  /// No description provided for @menuTafsir.
  ///
  /// In en, this message translates to:
  /// **'Tafsir'**
  String get menuTafsir;

  /// No description provided for @menuBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get menuBookmark;

  /// No description provided for @tajwidLegendTitle.
  ///
  /// In en, this message translates to:
  /// **'Tajweed Guide'**
  String get tajwidLegendTitle;

  /// No description provided for @tajwidGhunnah.
  ///
  /// In en, this message translates to:
  /// **'Ghunnah / Idgham Bighunnah'**
  String get tajwidGhunnah;

  /// No description provided for @tajwidGhunnahDesc.
  ///
  /// In en, this message translates to:
  /// **'Nasal sound (2 beats)'**
  String get tajwidGhunnahDesc;

  /// No description provided for @tajwidIkhfa.
  ///
  /// In en, this message translates to:
  /// **'Ikhfa'**
  String get tajwidIkhfa;

  /// No description provided for @tajwidIkhfaDesc.
  ///
  /// In en, this message translates to:
  /// **'Hidden / Faint (2 beats)'**
  String get tajwidIkhfaDesc;

  /// No description provided for @tajwidMadJaiz.
  ///
  /// In en, this message translates to:
  /// **'Mad Jaiz Munfasil'**
  String get tajwidMadJaiz;

  /// No description provided for @tajwidMadJaizDesc.
  ///
  /// In en, this message translates to:
  /// **'Long (2/4/5 beats)'**
  String get tajwidMadJaizDesc;

  /// No description provided for @tajwidQalqalah.
  ///
  /// In en, this message translates to:
  /// **'Qalqalah'**
  String get tajwidQalqalah;

  /// No description provided for @tajwidQalqalahDesc.
  ///
  /// In en, this message translates to:
  /// **'Bouncing sound'**
  String get tajwidQalqalahDesc;

  /// No description provided for @tajwidIqlab.
  ///
  /// In en, this message translates to:
  /// **'Iqlab'**
  String get tajwidIqlab;

  /// No description provided for @tajwidIqlabDesc.
  ///
  /// In en, this message translates to:
  /// **'N turns into M sound'**
  String get tajwidIqlabDesc;

  /// No description provided for @tajwidMadWajib.
  ///
  /// In en, this message translates to:
  /// **'Mad Wajib / Lazim'**
  String get tajwidMadWajib;

  /// No description provided for @tajwidMadWajibDesc.
  ///
  /// In en, this message translates to:
  /// **'Very Long (4-6 beats)'**
  String get tajwidMadWajibDesc;

  /// No description provided for @tajwidIdghamBilaghunnah.
  ///
  /// In en, this message translates to:
  /// **'Idgham Bilaghunnah / Waqf'**
  String get tajwidIdghamBilaghunnah;

  /// No description provided for @tajwidIdghamBilaghunnahDesc.
  ///
  /// In en, this message translates to:
  /// **'Merged / Not pronounced'**
  String get tajwidIdghamBilaghunnahDesc;

  /// No description provided for @showcaseDraggableTitle.
  ///
  /// In en, this message translates to:
  /// **'Flexible Player'**
  String get showcaseDraggableTitle;

  /// No description provided for @showcaseDraggableDesc.
  ///
  /// In en, this message translates to:
  /// **'Long press & drag to move position.'**
  String get showcaseDraggableDesc;

  /// No description provided for @showcaseReciterDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to change Reciter.'**
  String get showcaseReciterDesc;

  /// No description provided for @lblBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get lblBookmarks;

  /// No description provided for @tabAyahList.
  ///
  /// In en, this message translates to:
  /// **'Ayah (List)'**
  String get tabAyahList;

  /// No description provided for @tabPageMushaf.
  ///
  /// In en, this message translates to:
  /// **'Mushaf (Page)'**
  String get tabPageMushaf;

  /// No description provided for @emptyBookmarkAyahTitle.
  ///
  /// In en, this message translates to:
  /// **'No Ayah Bookmarks'**
  String get emptyBookmarkAyahTitle;

  /// No description provided for @emptyBookmarkAyahSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your marked ayahs will appear here'**
  String get emptyBookmarkAyahSubtitle;

  /// No description provided for @emptyBookmarkPageTitle.
  ///
  /// In en, this message translates to:
  /// **'No Page Bookmarks'**
  String get emptyBookmarkPageTitle;

  /// No description provided for @emptyBookmarkPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your marked pages will appear here'**
  String get emptyBookmarkPageSubtitle;

  /// No description provided for @lblSavedBookmarks.
  ///
  /// In en, this message translates to:
  /// **'SAVED BOOKMARKS'**
  String get lblSavedBookmarks;

  /// No description provided for @lblListType.
  ///
  /// In en, this message translates to:
  /// **'Ayah'**
  String get lblListType;

  /// No description provided for @lblMushafType.
  ///
  /// In en, this message translates to:
  /// **'Mushaf'**
  String get lblMushafType;

  /// No description provided for @lblAyah.
  ///
  /// In en, this message translates to:
  /// **'Ayah'**
  String get lblAyah;

  /// No description provided for @lblPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get lblPage;

  /// No description provided for @lblWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get lblWeek;

  /// No description provided for @targetPageExplanation.
  ///
  /// In en, this message translates to:
  /// **'Page target is tracked when reading in Mushaf tab.'**
  String get targetPageExplanation;

  /// No description provided for @targetAyahExplanation.
  ///
  /// In en, this message translates to:
  /// **'Ayah target is tracked when reading in List/Surah Detail mode.'**
  String get targetAyahExplanation;

  /// No description provided for @backgroundRefreshTitle.
  ///
  /// In en, this message translates to:
  /// **'Yesterday\'s Progress'**
  String get backgroundRefreshTitle;

  /// No description provided for @backgroundProgressEncourage.
  ///
  /// In en, this message translates to:
  /// **'Yesterday you read {progress} {unit}s. Let\'s try to hit the target today!'**
  String backgroundProgressEncourage(Object progress, Object unit);

  /// No description provided for @backgroundProgressFinished.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah, you hit the {target} {unit} target yesterday! Keep it up.'**
  String backgroundProgressFinished(Object target, Object unit);

  /// No description provided for @backgroundProgressZero.
  ///
  /// In en, this message translates to:
  /// **'You didn\'t read Quran yesterday. Let\'s start fresh today with Bismillah!'**
  String get backgroundProgressZero;

  /// No description provided for @settingsTestBackground.
  ///
  /// In en, this message translates to:
  /// **'Test Background Fetch'**
  String get settingsTestBackground;

  /// No description provided for @settingsTestBackgroundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Run daily update task now'**
  String get settingsTestBackgroundSubtitle;

  /// No description provided for @showcaseQuranSearch.
  ///
  /// In en, this message translates to:
  /// **'Search specific Surah or Ayah.'**
  String get showcaseQuranSearch;

  /// No description provided for @showcaseQuranBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Access your bookmarks and favorite verses.'**
  String get showcaseQuranBookmarks;

  /// No description provided for @showcaseQuranItem.
  ///
  /// In en, this message translates to:
  /// **'Tap to open. Choose between Ayah or Mushaf view.'**
  String get showcaseQuranItem;

  /// No description provided for @showcaseQuranPlay.
  ///
  /// In en, this message translates to:
  /// **'Tap to play the Surah audio.'**
  String get showcaseQuranPlay;

  /// No description provided for @showcaseMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Tap to mark this ayah as read and track your progress.'**
  String get showcaseMarkRead;

  /// No description provided for @showcaseTafsir.
  ///
  /// In en, this message translates to:
  /// **'View Tafsir and detailed translation.'**
  String get showcaseTafsir;

  /// No description provided for @showcasePlayAyah.
  ///
  /// In en, this message translates to:
  /// **'Listen to the audio of this ayah.'**
  String get showcasePlayAyah;

  /// No description provided for @settingsResetShowcase.
  ///
  /// In en, this message translates to:
  /// **'Reset Showcase'**
  String get settingsResetShowcase;

  /// No description provided for @settingsResetShowcaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all tutorials to see them again.'**
  String get settingsResetShowcaseSubtitle;

  /// No description provided for @jumpToAyah.
  ///
  /// In en, this message translates to:
  /// **'Jump to Ayah'**
  String get jumpToAyah;

  /// No description provided for @showcaseJumpToAyahDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to quickly navigate to a specific Ayah'**
  String get showcaseJumpToAyahDesc;

  /// No description provided for @navPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get navPage;

  /// No description provided for @navJuz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get navJuz;

  /// No description provided for @navSurah.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get navSurah;

  /// No description provided for @hintEnterPage.
  ///
  /// In en, this message translates to:
  /// **'Enter Page (1 - 604)'**
  String get hintEnterPage;

  /// No description provided for @goButton.
  ///
  /// In en, this message translates to:
  /// **'Go to Page'**
  String get goButton;

  /// No description provided for @startOfJuz.
  ///
  /// In en, this message translates to:
  /// **'Start of Juz {number}'**
  String startOfJuz(Object number);

  /// No description provided for @hizb.
  ///
  /// In en, this message translates to:
  /// **'Hizb'**
  String get hizb;

  /// No description provided for @rub.
  ///
  /// In en, this message translates to:
  /// **'Rub'**
  String get rub;

  /// No description provided for @selectAyah.
  ///
  /// In en, this message translates to:
  /// **'Select Ayah'**
  String get selectAyah;

  /// No description provided for @surahAyahs.
  ///
  /// In en, this message translates to:
  /// **'{count} Ayahs'**
  String surahAyahs(Object count);

  /// No description provided for @showcaseAyahShare.
  ///
  /// In en, this message translates to:
  /// **'Share this Ayah text or image.'**
  String get showcaseAyahShare;

  /// No description provided for @showcaseAyahBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark this Ayah to read later.'**
  String get showcaseAyahBookmark;

  /// No description provided for @showcaseQuranNavigation.
  ///
  /// In en, this message translates to:
  /// **'Jump to specific Page, Juz, or Hizb.'**
  String get showcaseQuranNavigation;

  /// No description provided for @searchInAyahs.
  ///
  /// In en, this message translates to:
  /// **'Search \'{query}\' in Ayahs'**
  String searchInAyahs(Object query);

  /// No description provided for @searchResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Search results for \'{query}\''**
  String searchResultsFor(Object query);

  /// No description provided for @quranNavigationTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran Navigation'**
  String get quranNavigationTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
