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

  /// No description provided for @settingsIbadah.
  ///
  /// In en, this message translates to:
  /// **'Worship'**
  String get settingsIbadah;

  /// No description provided for @hijriAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Hijri Date Adjustment'**
  String get hijriAdjustment;

  /// No description provided for @hijriAdjustmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust date if sighting varies'**
  String get hijriAdjustmentSubtitle;

  /// No description provided for @prayerCalculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Prayer Time Calculation Method'**
  String get prayerCalculationMethod;

  /// No description provided for @prayerCalculationMethodSingapore.
  ///
  /// In en, this message translates to:
  /// **'Singapore (JAKIM/MUIS)'**
  String get prayerCalculationMethodSingapore;

  /// No description provided for @prayerCalculationMethodKemenagRI.
  ///
  /// In en, this message translates to:
  /// **'Kemenag RI (Indonesia)'**
  String get prayerCalculationMethodKemenagRI;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

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
  /// **'Activity'**
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
  /// **'City name (e.g. London)'**
  String get searchCityHint;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @locationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Location not found'**
  String get locationNotFound;

  /// No description provided for @trySearchingWith.
  ///
  /// In en, this message translates to:
  /// **'Try searching with:'**
  String get trySearchingWith;

  /// No description provided for @searchSuggestionCity.
  ///
  /// In en, this message translates to:
  /// **'City name (e.g., Jakarta)'**
  String get searchSuggestionCity;

  /// No description provided for @searchSuggestionDistrict.
  ///
  /// In en, this message translates to:
  /// **'District (e.g., Bandung Barat)'**
  String get searchSuggestionDistrict;

  /// No description provided for @searchSuggestionAddress.
  ///
  /// In en, this message translates to:
  /// **'Full address'**
  String get searchSuggestionAddress;

  /// No description provided for @searchForLocation.
  ///
  /// In en, this message translates to:
  /// **'Search for a location'**
  String get searchForLocation;

  /// No description provided for @popularCities.
  ///
  /// In en, this message translates to:
  /// **'Popular cities:'**
  String get popularCities;

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

  /// No description provided for @settingsKidsMode.
  ///
  /// In en, this message translates to:
  /// **'Kids Mode (Hafalan)'**
  String get settingsKidsMode;

  /// No description provided for @settingsKidsModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mismatched words aren\'t shown as errors, and the wait time is longer.'**
  String get settingsKidsModeSubtitle;

  /// No description provided for @settingsRecordHafalan.
  ///
  /// In en, this message translates to:
  /// **'Record Audio while Memorizing'**
  String get settingsRecordHafalan;

  /// No description provided for @settingsRecordHafalanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your recitation to listen back to or send to a teacher/parent.'**
  String get settingsRecordHafalanSubtitle;

  /// No description provided for @settingsRecordHafalanExplainer.
  ///
  /// In en, this message translates to:
  /// **'Recordings are saved on your phone and never uploaded automatically. You can play them back or share them yourself via WhatsApp/Telegram anytime.'**
  String get settingsRecordHafalanExplainer;

  /// No description provided for @lblUnderstood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get lblUnderstood;

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
  /// **'15 minutes left until {prayerName} time. Don\'t forget to read Quran after prayer.'**
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

  /// No description provided for @prayerHeading.
  ///
  /// In en, this message translates to:
  /// **'Approaching, InshaAllah'**
  String get prayerHeading;

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
  /// **'Find various daily worship activities and learning guides here.'**
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

  /// No description provided for @lblFolderAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get lblFolderAll;

  /// No description provided for @lblFolderUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get lblFolderUncategorized;

  /// No description provided for @lblFolderHapalan.
  ///
  /// In en, this message translates to:
  /// **'Memorization'**
  String get lblFolderHapalan;

  /// No description provided for @lblFolderBacaan.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get lblFolderBacaan;

  /// No description provided for @lblAddFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get lblAddFolder;

  /// No description provided for @hintFolderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get hintFolderName;

  /// No description provided for @btnCreateFolder.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get btnCreateFolder;

  /// No description provided for @btnRenameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get btnRenameFolder;

  /// No description provided for @btnDeleteFolder.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDeleteFolder;

  /// No description provided for @dlgRenameFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get dlgRenameFolderTitle;

  /// No description provided for @dlgDeleteFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete folder?'**
  String get dlgDeleteFolderTitle;

  /// No description provided for @dlgDeleteFolderMessage.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks in this folder will become uncategorized.'**
  String get dlgDeleteFolderMessage;

  /// No description provided for @lblMoveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get lblMoveToFolder;

  /// No description provided for @lblSaveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Save to folder'**
  String get lblSaveToFolder;

  /// No description provided for @lblSaveWithoutFolder.
  ///
  /// In en, this message translates to:
  /// **'Save without folder'**
  String get lblSaveWithoutFolder;

  /// No description provided for @lblNoFolder.
  ///
  /// In en, this message translates to:
  /// **'No folder'**
  String get lblNoFolder;

  /// No description provided for @msgFolderCreated.
  ///
  /// In en, this message translates to:
  /// **'Folder created'**
  String get msgFolderCreated;

  /// No description provided for @msgFolderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Folder deleted'**
  String get msgFolderDeleted;

  /// No description provided for @msgBookmarkMoved.
  ///
  /// In en, this message translates to:
  /// **'Bookmark moved'**
  String get msgBookmarkMoved;

  /// No description provided for @errFolderNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Folder name is required'**
  String get errFolderNameRequired;

  /// No description provided for @msgNoBookmarksInFolder.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks in this folder yet'**
  String get msgNoBookmarksInFolder;

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

  /// No description provided for @murajaahNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to Review'**
  String get murajaahNotifTitle;

  /// No description provided for @murajaahNotifBody.
  ///
  /// In en, this message translates to:
  /// **'You have {count} page(s) due for review today. A quick re-read keeps it fresh.'**
  String murajaahNotifBody(Object count);

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

  /// No description provided for @qiblaCompass.
  ///
  /// In en, this message translates to:
  /// **'Qibla Compass'**
  String get qiblaCompass;

  /// No description provided for @findQiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Find Qibla Direction'**
  String get findQiblaDirection;

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Qibla Direction'**
  String get qiblaDirection;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionRequired;

  /// No description provided for @errorReadingCompass.
  ///
  /// In en, this message translates to:
  /// **'Error reading compass'**
  String get errorReadingCompass;

  /// No description provided for @deviceNoSensors.
  ///
  /// In en, this message translates to:
  /// **'Device does not have sensors'**
  String get deviceNoSensors;

  /// No description provided for @compassCalibrateHint.
  ///
  /// In en, this message translates to:
  /// **'Rotate your device in a figure 8 pattern to calibrate'**
  String get compassCalibrateHint;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Build a Reading Habit'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Set your daily target (e.g. 1 Juz or 4 Pages) and track your consistency every day.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Complete Worship Companion'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Accurate prayer times, precise Qibla direction, and daily Dzikir in one app.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Intercession in the Hereafter'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'\"Read the Quran, for indeed it will come on the Day of Resurrection as an intercessor for its companions.\" (Muslim)'**
  String get onboardingDesc3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @continueReadingAyah.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE READING (AYAH)'**
  String get continueReadingAyah;

  /// No description provided for @continueReadingPage.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE READING (PAGE)'**
  String get continueReadingPage;

  /// No description provided for @showcaseDzikirTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get showcaseDzikirTitle;

  /// No description provided for @showcaseSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get showcaseSettingsTitle;

  /// No description provided for @showcaseQuranTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get showcaseQuranTabTitle;

  /// No description provided for @showcaseDailyGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get showcaseDailyGoalTitle;

  /// No description provided for @showcaseQuickAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get showcaseQuickAccessTitle;

  /// No description provided for @showcasePrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get showcasePrayerTitle;

  /// No description provided for @sbJumpToAyah.
  ///
  /// In en, this message translates to:
  /// **'Jumped to Ayah {ayah} (Page {page})'**
  String sbJumpToAyah(Object ayah, Object page);

  /// No description provided for @sbPageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found in loaded data.'**
  String get sbPageNotFound;

  /// No description provided for @sbAyahNotFound.
  ///
  /// In en, this message translates to:
  /// **'Could not find Ayah {ayah}'**
  String sbAyahNotFound(Object ayah);

  /// No description provided for @sbDataNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Data not loaded yet.'**
  String get sbDataNotLoaded;

  /// No description provided for @sbOpeningSurah.
  ///
  /// In en, this message translates to:
  /// **'Opening {surah}...'**
  String sbOpeningSurah(Object surah);

  /// No description provided for @sbNextSurahNotFound.
  ///
  /// In en, this message translates to:
  /// **'Next Surah Not Found!'**
  String get sbNextSurahNotFound;

  /// No description provided for @sbEndOfQuran.
  ///
  /// In en, this message translates to:
  /// **'End of Quran'**
  String get sbEndOfQuran;

  /// No description provided for @sbStartOfQuran.
  ///
  /// In en, this message translates to:
  /// **'Start of Quran'**
  String get sbStartOfQuran;

  /// No description provided for @sbBookmarkedPage.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked Page {page}'**
  String sbBookmarkedPage(Object page);

  /// No description provided for @sbReadingSaved.
  ///
  /// In en, this message translates to:
  /// **'Reading progress saved!'**
  String get sbReadingSaved;

  /// No description provided for @sbAyahBookmarked.
  ///
  /// In en, this message translates to:
  /// **'Ayah Bookmarked!'**
  String get sbAyahBookmarked;

  /// No description provided for @searchSortedByRelevance.
  ///
  /// In en, this message translates to:
  /// **'Sorted by relevance, for details click on the ayah'**
  String get searchSortedByRelevance;

  /// No description provided for @qiblaFacing.
  ///
  /// In en, this message translates to:
  /// **'You are facing Qibla'**
  String get qiblaFacing;

  /// No description provided for @qiblaTurnRight.
  ///
  /// In en, this message translates to:
  /// **'Turn Right →'**
  String get qiblaTurnRight;

  /// No description provided for @qiblaTurnLeft.
  ///
  /// In en, this message translates to:
  /// **'← Turn Left'**
  String get qiblaTurnLeft;

  /// No description provided for @qiblaLocating.
  ///
  /// In en, this message translates to:
  /// **'Locating Qibla...'**
  String get qiblaLocating;

  /// No description provided for @qiblaAligned.
  ///
  /// In en, this message translates to:
  /// **'ALIGNED'**
  String get qiblaAligned;

  /// No description provided for @qiblaAlignArrow.
  ///
  /// In en, this message translates to:
  /// **'Align the arrow to the top'**
  String get qiblaAlignArrow;

  /// No description provided for @qiblaNoSensor.
  ///
  /// In en, this message translates to:
  /// **'No Compass Sensor'**
  String get qiblaNoSensor;

  /// No description provided for @sbBookmarkSaved.
  ///
  /// In en, this message translates to:
  /// **'Bookmark saved'**
  String get sbBookmarkSaved;

  /// No description provided for @sbBookmarkRemoved.
  ///
  /// In en, this message translates to:
  /// **'Bookmark removed'**
  String get sbBookmarkRemoved;

  /// No description provided for @sbJumpedToAyah.
  ///
  /// In en, this message translates to:
  /// **'Jumped to Ayah {ayah}'**
  String sbJumpedToAyah(Object ayah);

  /// No description provided for @markerAdded.
  ///
  /// In en, this message translates to:
  /// **'Marker added'**
  String get markerAdded;

  /// No description provided for @markerRemoved.
  ///
  /// In en, this message translates to:
  /// **'Marker removed'**
  String get markerRemoved;

  /// No description provided for @markerLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Marker limit reached'**
  String get markerLimitReached;

  /// No description provided for @nextFasting.
  ///
  /// In en, this message translates to:
  /// **'Next Fasting'**
  String get nextFasting;

  /// No description provided for @todayFasting.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Fasting'**
  String get todayFasting;

  /// No description provided for @countdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Time Until Prayer'**
  String get countdownLabel;

  /// No description provided for @sbRecordedAyahs.
  ///
  /// In en, this message translates to:
  /// **'Recorded {count} Ayahs read!'**
  String sbRecordedAyahs(Object count);

  /// No description provided for @sbLastReadUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last read position updated'**
  String get sbLastReadUpdated;

  /// No description provided for @emptyHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start reading to track your progress'**
  String get emptyHistorySubtitle;

  /// No description provided for @lblThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get lblThisWeek;

  /// No description provided for @sbPageReadLogged.
  ///
  /// In en, this message translates to:
  /// **'Page {page} recorded ({duration})'**
  String sbPageReadLogged(Object duration, Object page);

  /// No description provided for @lblLifetimeTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get lblLifetimeTotal;

  /// No description provided for @lblReadingStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get lblReadingStreak;

  /// No description provided for @lblDailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Avg/Day'**
  String get lblDailyAverage;

  /// No description provided for @lblAyahs.
  ///
  /// In en, this message translates to:
  /// **'Ayahs'**
  String get lblAyahs;

  /// No description provided for @lblDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get lblDays;

  /// No description provided for @insightStreakWarning.
  ///
  /// In en, this message translates to:
  /// **'Don\'t break your {streak}-day streak! Read at least 1 {unit} today.'**
  String insightStreakWarning(Object streak, Object unit);

  /// No description provided for @insightAheadTarget.
  ///
  /// In en, this message translates to:
  /// **'Great job! You\'re {percent}% ahead of your weekly target!'**
  String insightAheadTarget(Object percent);

  /// No description provided for @insightBehindTarget.
  ///
  /// In en, this message translates to:
  /// **'You\'re behind by {remaining} {unit}. Try reading {needed} {unit} today!'**
  String insightBehindTarget(Object needed, Object remaining, Object unit);

  /// No description provided for @insightStreakMilestone.
  ///
  /// In en, this message translates to:
  /// **'{streak}-day streak! Keep it up!'**
  String insightStreakMilestone(Object streak);

  /// No description provided for @insightPerfectWeek.
  ///
  /// In en, this message translates to:
  /// **'Perfect week! You\'ve reached your target every day!'**
  String get insightPerfectWeek;

  /// No description provided for @insightDailyRecord.
  ///
  /// In en, this message translates to:
  /// **'New Record! {max} {unit} in a single day!'**
  String insightDailyRecord(Object max, Object unit);

  /// No description provided for @insightLifetimeMilestone.
  ///
  /// In en, this message translates to:
  /// **'Amazing! You\'ve reached {total} {unit} lifetime total!'**
  String insightLifetimeMilestone(Object total, Object unit);

  /// No description provided for @insightTargetInfo.
  ///
  /// In en, this message translates to:
  /// **'Target: {daily} {unit}/Day • {weekly} {unit}/Week'**
  String insightTargetInfo(Object daily, Object unit, Object weekly);

  /// No description provided for @guideTitle.
  ///
  /// In en, this message translates to:
  /// **'App Guide'**
  String get guideTitle;

  /// No description provided for @guideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn about tracking and targets'**
  String get guideSubtitle;

  /// No description provided for @guideTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Targets & Goals'**
  String get guideTargetTitle;

  /// No description provided for @guideTargetDesc.
  ///
  /// In en, this message translates to:
  /// **'Set your Daily Target in Settings. **You can choose to track by Pages or Ayahs.** Your Weekly Target is simply your daily target x 7. You can accumulate reading on weekends to meet the weekly goal.'**
  String get guideTargetDesc;

  /// No description provided for @guideMushafTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Mushaf Mode (Page View)'**
  String get guideMushafTitle;

  /// No description provided for @guideMushafDesc.
  ///
  /// In en, this message translates to:
  /// **'• **Timer:** Starts automatically when you open a page.\n• **Progress:** Swiping to the next page counts the previous one as read (after reading for at least 20 seconds).\n• **Manual Mark:** Use the **Green Checklist Button** (bottom right) to save your last position without changing pages.'**
  String get guideMushafDesc;

  /// No description provided for @guideListTitle.
  ///
  /// In en, this message translates to:
  /// **'3. List Mode (Ayah View)'**
  String get guideListTitle;

  /// No description provided for @guideListDesc.
  ///
  /// In en, this message translates to:
  /// **'• **No Timer:** We focus on Ayah count here, not duration.\n• **Progress:** Tap an ayah and select **Mark as Last Read**. We calculate how many new ayahs you\'ve read since your last session.\n• *Example:* If you last read Ayah 5, and today mark Ayah 20, we record **15 new ayahs**.'**
  String get guideListDesc;

  /// No description provided for @guideInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Stats & Streak'**
  String get guideInsightTitle;

  /// No description provided for @guideInsightDesc.
  ///
  /// In en, this message translates to:
  /// **'• **Unique Pages:** In Mushaf Mode, we track *Unique Pages* for Khatam progress. Reading the same page twice won\'t double your \'Total Pages\' count, but the duration is added!\n• **Streak:** Read at least 1 ayah/page daily to keep your streak alive.'**
  String get guideInsightDesc;

  /// No description provided for @lblWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get lblWeekly;

  /// No description provided for @lblMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get lblMonthly;

  /// No description provided for @msgEndOfHistory.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the end of your history'**
  String get msgEndOfHistory;

  /// No description provided for @chartMonthlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Progress'**
  String get chartMonthlyTitle;

  /// No description provided for @calendarDayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get calendarDayMon;

  /// No description provided for @calendarDayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get calendarDayTue;

  /// No description provided for @calendarDayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get calendarDayWed;

  /// No description provided for @calendarDayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get calendarDayThu;

  /// No description provided for @calendarDayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get calendarDayFri;

  /// No description provided for @calendarDaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get calendarDaySat;

  /// No description provided for @calendarDaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get calendarDaySun;

  /// No description provided for @calendarLegendWajib.
  ///
  /// In en, this message translates to:
  /// **'Wajib'**
  String get calendarLegendWajib;

  /// No description provided for @calendarLegendSunnah.
  ///
  /// In en, this message translates to:
  /// **'Sunnah'**
  String get calendarLegendSunnah;

  /// No description provided for @calendarLegendHaram.
  ///
  /// In en, this message translates to:
  /// **'Forbidden'**
  String get calendarLegendHaram;

  /// No description provided for @fastingRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Fasting'**
  String get fastingRamadan;

  /// No description provided for @fastingArafah.
  ///
  /// In en, this message translates to:
  /// **'Arafah Fasting'**
  String get fastingArafah;

  /// No description provided for @fastingAshura.
  ///
  /// In en, this message translates to:
  /// **'Ashura Fasting'**
  String get fastingAshura;

  /// No description provided for @fastingTasua.
  ///
  /// In en, this message translates to:
  /// **'Tasu\'a Fasting'**
  String get fastingTasua;

  /// No description provided for @fastingAyyamulBidh.
  ///
  /// In en, this message translates to:
  /// **'Ayyamul Bidh'**
  String get fastingAyyamulBidh;

  /// No description provided for @fastingMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday Fasting'**
  String get fastingMonday;

  /// No description provided for @fastingThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday Fasting'**
  String get fastingThursday;

  /// No description provided for @eidFitr.
  ///
  /// In en, this message translates to:
  /// **'Eid Al-Fitr'**
  String get eidFitr;

  /// No description provided for @eidAdha.
  ///
  /// In en, this message translates to:
  /// **'Eid Al-Adha'**
  String get eidAdha;

  /// No description provided for @daysTasyrik.
  ///
  /// In en, this message translates to:
  /// **'Tasyrik Days'**
  String get daysTasyrik;

  /// No description provided for @reminderFasting.
  ///
  /// In en, this message translates to:
  /// **'FASTING'**
  String get reminderFasting;

  /// No description provided for @reminderDzikir.
  ///
  /// In en, this message translates to:
  /// **'DZIKIR'**
  String get reminderDzikir;

  /// No description provided for @reminderIftarIn.
  ///
  /// In en, this message translates to:
  /// **'Iftar in {duration}'**
  String reminderIftarIn(Object duration);

  /// No description provided for @reminderFastingType.
  ///
  /// In en, this message translates to:
  /// **'{type} Fasting'**
  String reminderFastingType(Object type);

  /// No description provided for @reminderDzikirTime.
  ///
  /// In en, this message translates to:
  /// **'Time for {type} Dzikir'**
  String reminderDzikirTime(Object type);

  /// No description provided for @showcaseMiniPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Mini Player'**
  String get showcaseMiniPlayerTitle;

  /// No description provided for @showcaseMiniPlayerDesc.
  ///
  /// In en, this message translates to:
  /// **'Swipe down or tap here (v) to minimize.'**
  String get showcaseMiniPlayerDesc;

  /// No description provided for @showcaseChangeQoriTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Reciter'**
  String get showcaseChangeQoriTitle;

  /// No description provided for @showcaseChangeQoriDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to change the reciter.'**
  String get showcaseChangeQoriDesc;

  /// No description provided for @showcaseRepeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Repeat Mode'**
  String get showcaseRepeatTitle;

  /// No description provided for @showcaseRepeatDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap to repeat single verse or full surah.'**
  String get showcaseRepeatDesc;

  /// No description provided for @showcaseSpeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Playback Speed'**
  String get showcaseSpeedTitle;

  /// No description provided for @showcaseSpeedDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap to adjust playback speed.'**
  String get showcaseSpeedDesc;

  /// No description provided for @ibadahPracticesSection.
  ///
  /// In en, this message translates to:
  /// **'Daily Practices'**
  String get ibadahPracticesSection;

  /// No description provided for @ibadahLearningSection.
  ///
  /// In en, this message translates to:
  /// **'Knowledge & Guides'**
  String get ibadahLearningSection;

  /// No description provided for @ibadahTajweedTitle.
  ///
  /// In en, this message translates to:
  /// **'Tajweed Learning'**
  String get ibadahTajweedTitle;

  /// No description provided for @ibadahTajweedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn Nun Sukun & Mim Sukun'**
  String get ibadahTajweedSubtitle;

  /// No description provided for @ibadahWudhuTitle.
  ///
  /// In en, this message translates to:
  /// **'Wudhu Guide'**
  String get ibadahWudhuTitle;

  /// No description provided for @ibadahPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Guide'**
  String get ibadahPrayerTitle;

  /// No description provided for @ibadahPrayerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Step by step prayer guide'**
  String get ibadahPrayerSubtitle;

  /// No description provided for @ibadahFastingTitle.
  ///
  /// In en, this message translates to:
  /// **'Fasting Guide'**
  String get ibadahFastingTitle;

  /// No description provided for @ibadahFastingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ramadan & Sunnah Fasting'**
  String get ibadahFastingSubtitle;

  /// No description provided for @lblNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get lblNext;

  /// No description provided for @lblPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get lblPrevious;

  /// No description provided for @lblDefinition.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get lblDefinition;

  /// No description provided for @lblLetters.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get lblLetters;

  /// No description provided for @lblExamples.
  ///
  /// In en, this message translates to:
  /// **'Examples'**
  String get lblExamples;

  /// No description provided for @lblSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get lblSchedule;

  /// No description provided for @lblCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get lblCalendar;

  /// No description provided for @lblFastingHeader.
  ///
  /// In en, this message translates to:
  /// **'FASTING'**
  String get lblFastingHeader;

  /// No description provided for @lblSearch.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get lblSearch;

  /// No description provided for @lblAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get lblAllCategories;

  /// No description provided for @msgNoData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get msgNoData;

  /// No description provided for @msgNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get msgNoResults;

  /// No description provided for @fastingGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Fasting Guide'**
  String get fastingGuideTitle;

  /// No description provided for @fastingGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Practical Fasting Fiqh'**
  String get fastingGuideSubtitle;

  /// No description provided for @searchFastingGuide.
  ///
  /// In en, this message translates to:
  /// **'Search fasting topic...'**
  String get searchFastingGuide;

  /// No description provided for @searchDoa.
  ///
  /// In en, this message translates to:
  /// **'Search Dua...'**
  String get searchDoa;

  /// No description provided for @msgNoDoaFound.
  ///
  /// In en, this message translates to:
  /// **'No Dua found'**
  String get msgNoDoaFound;

  /// No description provided for @wordByWord.
  ///
  /// In en, this message translates to:
  /// **'Word by Word'**
  String get wordByWord;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @readTafsirButton.
  ///
  /// In en, this message translates to:
  /// **'Read Tafsir'**
  String get readTafsirButton;

  /// No description provided for @tafsirTitle.
  ///
  /// In en, this message translates to:
  /// **'Tafsir'**
  String get tafsirTitle;

  /// No description provided for @tafsirSourceJalalayn.
  ///
  /// In en, this message translates to:
  /// **'Source: Tafsir Jalalayn (Indonesia)'**
  String get tafsirSourceJalalayn;

  /// No description provided for @tafsirSourceIbnKathir.
  ///
  /// In en, this message translates to:
  /// **'Source: Tafsir Ibn Kathir (English)'**
  String get tafsirSourceIbnKathir;

  /// No description provided for @backToTranslation.
  ///
  /// In en, this message translates to:
  /// **'Back to Translation'**
  String get backToTranslation;

  /// No description provided for @tafsirNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Tafsir not available for this ayah.'**
  String get tafsirNotAvailable;

  /// No description provided for @wudhuGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Wudhu Guide'**
  String get wudhuGuideTitle;

  /// No description provided for @wudhuGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Practical Wudhu Procedure'**
  String get wudhuGuideSubtitle;

  /// No description provided for @searchWudhuGuide.
  ///
  /// In en, this message translates to:
  /// **'Search Wudhu topic...'**
  String get searchWudhuGuide;

  /// No description provided for @prayerGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Prayer Guide according to Sunnah'**
  String get prayerGuideSubtitle;

  /// No description provided for @searchPrayerGuide.
  ///
  /// In en, this message translates to:
  /// **'Search Prayer topic...'**
  String get searchPrayerGuide;

  /// No description provided for @lblSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get lblSkip;

  /// No description provided for @articleTitle.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get articleTitle;

  /// No description provided for @articleSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get articleSeeAll;

  /// No description provided for @articleReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get articleReadMore;

  /// No description provided for @articleSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search articles...'**
  String get articleSearchHint;

  /// No description provided for @articleSearchStart.
  ///
  /// In en, this message translates to:
  /// **'Start searching...'**
  String get articleSearchStart;

  /// No description provided for @articleNoData.
  ///
  /// In en, this message translates to:
  /// **'No articles found.'**
  String get articleNoData;

  /// No description provided for @articleErrorLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load articles'**
  String get articleErrorLoad;

  /// No description provided for @articleErrorSearch.
  ///
  /// In en, this message translates to:
  /// **'Failed to search articles'**
  String get articleErrorSearch;

  /// No description provided for @articleListTitle.
  ///
  /// In en, this message translates to:
  /// **'Islamic Articles'**
  String get articleListTitle;

  /// No description provided for @articleListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No articles yet.'**
  String get articleListEmpty;

  /// No description provided for @modeHafalanTitle.
  ///
  /// In en, this message translates to:
  /// **'Memorization Mode'**
  String get modeHafalanTitle;

  /// No description provided for @modeHafalanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Test your memorization with voice'**
  String get modeHafalanSubtitle;

  /// No description provided for @hafalanAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Completed! Accuracy: {percent}%'**
  String hafalanAccuracy(Object percent);

  /// No description provided for @hafalanProgressAyat.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} Ayahs'**
  String hafalanProgressAyat(Object completed, Object total);

  /// No description provided for @hafalanProgressKata.
  ///
  /// In en, this message translates to:
  /// **'{matched}/{total} Words'**
  String hafalanProgressKata(Object matched, Object total);

  /// No description provided for @hafalanProgressPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Memorization Progress'**
  String get hafalanProgressPageTitle;

  /// No description provided for @hafalanProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is your own progress — not compared to anyone else.'**
  String get hafalanProgressSubtitle;

  /// No description provided for @hafalanParentViewTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent View'**
  String get hafalanParentViewTitle;

  /// No description provided for @hafalanAyatSudahHafalLabel.
  ///
  /// In en, this message translates to:
  /// **'ayahs memorized'**
  String get hafalanAyatSudahHafalLabel;

  /// No description provided for @hafalanSectionPerluDiulang.
  ///
  /// In en, this message translates to:
  /// **'NEEDS REVIEW'**
  String get hafalanSectionPerluDiulang;

  /// No description provided for @hafalanSectionPerJuz.
  ///
  /// In en, this message translates to:
  /// **'BY JUZ'**
  String get hafalanSectionPerJuz;

  /// No description provided for @hafalanSectionPerSurah.
  ///
  /// In en, this message translates to:
  /// **'BY SURAH'**
  String get hafalanSectionPerSurah;

  /// No description provided for @hafalanJuzLabel.
  ///
  /// In en, this message translates to:
  /// **'Juz {number}'**
  String hafalanJuzLabel(Object number);

  /// No description provided for @hafalanMurajaahTileTitle.
  ///
  /// In en, this message translates to:
  /// **'{surahName} · Page {pageNumber}'**
  String hafalanMurajaahTileTitle(Object pageNumber, Object surahName);

  /// No description provided for @hafalanMurajaahTileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Time to review, keep it fresh'**
  String get hafalanMurajaahTileSubtitle;

  /// No description provided for @hafalanStreakDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'days in a row'**
  String get hafalanStreakDaysLabel;

  /// No description provided for @hafalanNoSurahAttempted.
  ///
  /// In en, this message translates to:
  /// **'No surah started yet'**
  String get hafalanNoSurahAttempted;

  /// No description provided for @hafalanSectionAttemptedSurahs.
  ///
  /// In en, this message translates to:
  /// **'SURAHS IN PROGRESS/MEMORIZED'**
  String get hafalanSectionAttemptedSurahs;

  /// No description provided for @hafalanStatusSudahHafal.
  ///
  /// In en, this message translates to:
  /// **'Memorized'**
  String get hafalanStatusSudahHafal;

  /// No description provided for @hafalanStatusSedangDihafal.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get hafalanStatusSedangDihafal;

  /// No description provided for @hafalanStatusBelum.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get hafalanStatusBelum;

  /// No description provided for @hafalanSubtitleAyatOnly.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs'**
  String hafalanSubtitleAyatOnly(Object count);

  /// No description provided for @hafalanSubtitleAyatWithDate.
  ///
  /// In en, this message translates to:
  /// **'{count} ayahs · {date}'**
  String hafalanSubtitleAyatWithDate(Object count, Object date);

  /// No description provided for @hafalanDateToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get hafalanDateToday;

  /// No description provided for @hafalanDateYesterday.
  ///
  /// In en, this message translates to:
  /// **'yesterday'**
  String get hafalanDateYesterday;

  /// No description provided for @hafalanDateDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String hafalanDateDaysAgo(Object days);

  /// No description provided for @hafalanInsightStreakMessage.
  ///
  /// In en, this message translates to:
  /// **'{count}-day review streak — keep it up!'**
  String hafalanInsightStreakMessage(Object count);

  /// No description provided for @hafalanInsightAyatMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve memorized {count} ayahs!'**
  String hafalanInsightAyatMessage(Object count);

  /// No description provided for @hafalanStreakCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Memorization Streak'**
  String get hafalanStreakCardTitle;

  /// No description provided for @hafalanStreakUnitLandscape.
  ///
  /// In en, this message translates to:
  /// **'/ {target} days'**
  String hafalanStreakUnitLandscape(Object target);

  /// No description provided for @hafalanStreakCompletedBadge.
  ///
  /// In en, this message translates to:
  /// **'Reached'**
  String get hafalanStreakCompletedBadge;

  /// No description provided for @hafalanStreakUnitPortrait.
  ///
  /// In en, this message translates to:
  /// **'/ {target} days in a row'**
  String hafalanStreakUnitPortrait(Object target);

  /// No description provided for @hafalanLihatProgress.
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get hafalanLihatProgress;

  /// No description provided for @hafalanShareText.
  ///
  /// In en, this message translates to:
  /// **'My memorization recording'**
  String get hafalanShareText;

  /// No description provided for @hafalanTooltipPlay.
  ///
  /// In en, this message translates to:
  /// **'Play recording'**
  String get hafalanTooltipPlay;

  /// No description provided for @hafalanTooltipShare.
  ///
  /// In en, this message translates to:
  /// **'Share (send to teacher)'**
  String get hafalanTooltipShare;

  /// No description provided for @hafalanTooltipSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved — won\'t be auto-deleted'**
  String get hafalanTooltipSaved;

  /// No description provided for @hafalanTooltipSave.
  ///
  /// In en, this message translates to:
  /// **'Save so it isn\'t auto-deleted'**
  String get hafalanTooltipSave;

  /// No description provided for @authChoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get authChoiceTitle;

  /// No description provided for @authChoiceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you\'d like to continue'**
  String get authChoiceSubtitle;

  /// No description provided for @authChoiceLogin.
  ///
  /// In en, this message translates to:
  /// **'Login with Account'**
  String get authChoiceLogin;

  /// No description provided for @authChoiceLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync your data across devices'**
  String get authChoiceLoginSubtitle;

  /// No description provided for @authChoiceRegister.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get authChoiceRegister;

  /// No description provided for @authChoiceRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Muslimly for free'**
  String get authChoiceRegisterSubtitle;

  /// No description provided for @authChoiceGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get authChoiceGuest;

  /// No description provided for @authChoiceGuestNote.
  ///
  /// In en, this message translates to:
  /// **'You can always sign in later from Settings'**
  String get authChoiceGuestNote;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your daily worship space.'**
  String get loginSubtitle;

  /// No description provided for @loginHintPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginHintPassword;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get loginOr;

  /// No description provided for @loginContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get loginContinueAsGuest;

  /// No description provided for @loginNewHere.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get loginNewHere;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}!'**
  String loginWelcomeBack(Object name);

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Muslimly and sync your progress.'**
  String get registerSubtitle;

  /// No description provided for @registerLabelUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get registerLabelUsername;

  /// No description provided for @registerHintUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get registerHintUsername;

  /// No description provided for @registerLabelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerLabelEmail;

  /// No description provided for @registerHintEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get registerHintEmail;

  /// No description provided for @registerLabelPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerLabelPassword;

  /// No description provided for @registerHintPassword.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get registerHintPassword;

  /// No description provided for @registerErrorAllFields.
  ///
  /// In en, this message translates to:
  /// **'All fields are required.'**
  String get registerErrorAllFields;

  /// No description provided for @registerErrorPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get registerErrorPasswordLength;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created! Please log in.'**
  String get registerSuccess;

  /// No description provided for @registerErrorFallback.
  ///
  /// In en, this message translates to:
  /// **'Registration failed.'**
  String get registerErrorFallback;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerHaveAccount;

  /// No description provided for @registerLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get registerLogIn;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get settingsLogin;

  /// No description provided for @settingsLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your data across devices'**
  String get settingsLoginSubtitle;

  /// No description provided for @settingsCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get settingsCreateAccount;

  /// No description provided for @settingsCreateAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'New to Muslimly? Register here'**
  String get settingsCreateAccountSubtitle;

  /// No description provided for @targetChooseTarget.
  ///
  /// In en, this message translates to:
  /// **'Choose Target'**
  String get targetChooseTarget;

  /// No description provided for @settingsMonthAdjustment.
  ///
  /// In en, this message translates to:
  /// **'{month} Adjustment'**
  String settingsMonthAdjustment(Object month);

  /// No description provided for @settingsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settingsEmail;

  /// No description provided for @settingsEmailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email copied to clipboard'**
  String get settingsEmailCopied;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a verification code'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get forgotPasswordSendCode;

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @otpVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Code'**
  String get otpVerifyTitle;

  /// No description provided for @otpVerifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}'**
  String otpVerifySubtitle(String email);

  /// No description provided for @otpVerifyHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get otpVerifyHint;

  /// No description provided for @otpVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerifyButton;

  /// No description provided for @otpVerifyResend.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get otpVerifyResend;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password below'**
  String get newPasswordSubtitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'NEW PASSWORD'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PASSWORD'**
  String get newPasswordConfirmLabel;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Min. 8 characters'**
  String get newPasswordHint;

  /// No description provided for @newPasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat new password'**
  String get newPasswordConfirmHint;

  /// No description provided for @newPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get newPasswordButton;

  /// No description provided for @newPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get newPasswordMismatch;

  /// No description provided for @newPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset! Please login.'**
  String get newPasswordSuccess;

  /// No description provided for @settingsUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get settingsUsername;

  /// No description provided for @settingsEditUsername.
  ///
  /// In en, this message translates to:
  /// **'Edit Username'**
  String get settingsEditUsername;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get settingsCurrentPassword;

  /// No description provided for @settingsCurrentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get settingsCurrentPasswordHint;

  /// No description provided for @settingsPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get settingsPasswordChanged;

  /// No description provided for @settingsUsernameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Username updated'**
  String get settingsUsernameUpdated;

  /// No description provided for @settingsUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new username'**
  String get settingsUsernameHint;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. All your data will be deleted.'**
  String get settingsDeleteAccountWarning;

  /// No description provided for @settingsDeleteAccountReason.
  ///
  /// In en, this message translates to:
  /// **'Why are you leaving?'**
  String get settingsDeleteAccountReason;

  /// No description provided for @settingsDeleteReasonNoLongerNeed.
  ///
  /// In en, this message translates to:
  /// **'I no longer need the app'**
  String get settingsDeleteReasonNoLongerNeed;

  /// No description provided for @settingsDeleteReasonPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy concerns'**
  String get settingsDeleteReasonPrivacy;

  /// No description provided for @settingsDeleteReasonNotifications.
  ///
  /// In en, this message translates to:
  /// **'Too many notifications'**
  String get settingsDeleteReasonNotifications;

  /// No description provided for @settingsDeleteReasonBetterApp.
  ///
  /// In en, this message translates to:
  /// **'Found a better app'**
  String get settingsDeleteReasonBetterApp;

  /// No description provided for @settingsDeleteReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get settingsDeleteReasonOther;

  /// No description provided for @settingsDeleteReasonOtherHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us your reason...'**
  String get settingsDeleteReasonOtherHint;

  /// No description provided for @settingsDeleteOtherTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least 3 words'**
  String get settingsDeleteOtherTooShort;

  /// No description provided for @passwordComplexityHint.
  ///
  /// In en, this message translates to:
  /// **'Min. 8 characters, uppercase, lowercase, and number'**
  String get passwordComplexityHint;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters and contain uppercase, lowercase, and a number'**
  String get passwordTooWeak;

  /// No description provided for @settingsDeleteConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get settingsDeleteConfirmButton;

  /// No description provided for @settingsDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get settingsDeleteSuccess;

  /// No description provided for @settingsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get settingsDeleteConfirmTitle;

  /// No description provided for @settingsDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account and all data will be permanently deleted. This cannot be undone.'**
  String get settingsDeleteConfirmMessage;

  /// No description provided for @settingsDeleteConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get settingsDeleteConfirmYes;

  /// No description provided for @settingsDeleteConfirmNo.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsDeleteConfirmNo;

  /// No description provided for @trackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Tracker'**
  String get trackerTitle;

  /// No description provided for @trackerToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get trackerToday;

  /// No description provided for @trackerEarlier.
  ///
  /// In en, this message translates to:
  /// **'Not recorded yet'**
  String get trackerEarlier;

  /// No description provided for @trackerEarlierHint.
  ///
  /// In en, this message translates to:
  /// **'These times have passed. Tell us what happened; nothing is counted automatically.'**
  String get trackerEarlierHint;

  /// No description provided for @trackerEarlierCount.
  ///
  /// In en, this message translates to:
  /// **'{count} not recorded'**
  String trackerEarlierCount(int count);

  /// No description provided for @trackerYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get trackerYesterday;

  /// No description provided for @trackerTapToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap a prayer to record it'**
  String get trackerTapToRecord;

  /// No description provided for @trackerMarkAllPrayed.
  ///
  /// In en, this message translates to:
  /// **'Mark all as prayed'**
  String get trackerMarkAllPrayed;

  /// No description provided for @trackerMarkAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark {count} prayers as prayed?'**
  String trackerMarkAllTitle(int count);

  /// No description provided for @trackerMarkAllBody.
  ///
  /// In en, this message translates to:
  /// **'All prayers on {date} will be recorded as prayed. Only continue if it is true.'**
  String trackerMarkAllBody(String date);

  /// No description provided for @trackerMarkAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, I prayed'**
  String get trackerMarkAllConfirm;

  /// No description provided for @trackerStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String trackerStreak(int count);

  /// No description provided for @trackerStreakNone.
  ///
  /// In en, this message translates to:
  /// **'No streak yet'**
  String get trackerStreakNone;

  /// No description provided for @trackerStatusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get trackerStatusUpcoming;

  /// No description provided for @trackerStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Time is open'**
  String get trackerStatusOpen;

  /// No description provided for @trackerStatusPerformed.
  ///
  /// In en, this message translates to:
  /// **'Prayed'**
  String get trackerStatusPerformed;

  /// No description provided for @trackerStatusPerformedJamaah.
  ///
  /// In en, this message translates to:
  /// **'Prayed in congregation'**
  String get trackerStatusPerformedJamaah;

  /// No description provided for @trackerStatusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get trackerStatusMissed;

  /// No description provided for @trackerStatusUnrecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get trackerStatusUnrecorded;

  /// No description provided for @trackerActionPrayed.
  ///
  /// In en, this message translates to:
  /// **'I prayed'**
  String get trackerActionPrayed;

  /// No description provided for @trackerActionJamaah.
  ///
  /// In en, this message translates to:
  /// **'In congregation'**
  String get trackerActionJamaah;

  /// No description provided for @trackerActionMissed.
  ///
  /// In en, this message translates to:
  /// **'I missed it'**
  String get trackerActionMissed;

  /// No description provided for @trackerQadhaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qadha to make up'**
  String get trackerQadhaTitle;

  /// No description provided for @trackerQadhaNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing to make up'**
  String get trackerQadhaNone;

  /// No description provided for @trackerQadhaTotal.
  ///
  /// In en, this message translates to:
  /// **'{count} prayers'**
  String trackerQadhaTotal(int count);

  /// No description provided for @trackerNudgeSetting.
  ///
  /// In en, this message translates to:
  /// **'Gentle reminder before time ends'**
  String get trackerNudgeSetting;

  /// No description provided for @trackerNudgeSettingHint.
  ///
  /// In en, this message translates to:
  /// **'A quiet notification shortly before each prayer time ends, only if you have not recorded it.'**
  String get trackerNudgeSettingHint;

  /// No description provided for @trackerNudgeBody.
  ///
  /// In en, this message translates to:
  /// **'{prayer} time ends around {time}. Have you prayed?'**
  String trackerNudgeBody(String prayer, String time);

  /// No description provided for @trackerLocalNote.
  ///
  /// In en, this message translates to:
  /// **'This record is only kept on this device.'**
  String get trackerLocalNote;

  /// No description provided for @trackerFiqhNote.
  ///
  /// In en, this message translates to:
  /// **'A recording and estimating aid, not a fatwa. Please consult your ustadz.'**
  String get trackerFiqhNote;

  /// No description provided for @trackerApproxLocation.
  ///
  /// In en, this message translates to:
  /// **'Times are approximate: the sun does not rise or set at your latitude today.'**
  String get trackerApproxLocation;

  /// No description provided for @trackerLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load prayer times.'**
  String get trackerLoadError;

  /// No description provided for @widgetNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get widgetNext;

  /// No description provided for @widgetOpenApp.
  ///
  /// In en, this message translates to:
  /// **'Open Muslimly to load prayer times'**
  String get widgetOpenApp;

  /// No description provided for @qadhaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qadha'**
  String get qadhaTitle;

  /// No description provided for @qadhaMakeUp.
  ///
  /// In en, this message translates to:
  /// **'Made up 1'**
  String get qadhaMakeUp;

  /// No description provided for @qadhaUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get qadhaUndo;

  /// No description provided for @qadhaPaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily pace'**
  String get qadhaPaceTitle;

  /// No description provided for @qadhaPaceNone.
  ///
  /// In en, this message translates to:
  /// **'No pace set'**
  String get qadhaPaceNone;

  /// No description provided for @qadhaPacePerDay.
  ///
  /// In en, this message translates to:
  /// **'{count} per day'**
  String qadhaPacePerDay(int count);

  /// No description provided for @qadhaFinishEstimate.
  ///
  /// In en, this message translates to:
  /// **'At this pace, about {date}'**
  String qadhaFinishEstimate(String date);

  /// No description provided for @qadhaWizardButton.
  ///
  /// In en, this message translates to:
  /// **'Estimate old qadha'**
  String get qadhaWizardButton;

  /// No description provided for @qadhaWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimate qadha'**
  String get qadhaWizardTitle;

  /// No description provided for @qadhaStepRange.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get qadhaStepRange;

  /// No description provided for @qadhaStepPattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get qadhaStepPattern;

  /// No description provided for @qadhaStepExcuse.
  ///
  /// In en, this message translates to:
  /// **'Corrections'**
  String get qadhaStepExcuse;

  /// No description provided for @qadhaStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get qadhaStepReview;

  /// No description provided for @qadhaFrom.
  ///
  /// In en, this message translates to:
  /// **'Obligation began'**
  String get qadhaFrom;

  /// No description provided for @qadhaTo.
  ///
  /// In en, this message translates to:
  /// **'Started praying regularly'**
  String get qadhaTo;

  /// No description provided for @qadhaPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get qadhaPickDate;

  /// No description provided for @qadhaPatternNever.
  ///
  /// In en, this message translates to:
  /// **'I did not pray in this period'**
  String get qadhaPatternNever;

  /// No description provided for @qadhaPatternSometimes.
  ///
  /// In en, this message translates to:
  /// **'I prayed on some days'**
  String get qadhaPatternSometimes;

  /// No description provided for @qadhaPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{prayer}: {count} days a week'**
  String qadhaPerWeek(String prayer, int count);

  /// No description provided for @qadhaExcuseHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. Days with a valid excuse (such as menstruation or postnatal bleeding) are not owed. Estimated days per month:'**
  String get qadhaExcuseHint;

  /// No description provided for @qadhaReviewHint.
  ///
  /// In en, this message translates to:
  /// **'You can edit every number. Saving adds an adjustment; earlier history is kept.'**
  String get qadhaReviewHint;

  /// No description provided for @qadhaSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get qadhaSave;

  /// No description provided for @qadhaSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get qadhaSaved;

  /// No description provided for @qadhaNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get qadhaNext;

  /// No description provided for @qadhaBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get qadhaBack;

  /// No description provided for @qadhaFiqhNote.
  ///
  /// In en, this message translates to:
  /// **'This is an estimating aid, not a fatwa. Rules differ between madhhabs, so please consult your ustadz.'**
  String get qadhaFiqhNote;

  /// No description provided for @qadhaReminderNote.
  ///
  /// In en, this message translates to:
  /// **'Reminders for qadha are not available yet.'**
  String get qadhaReminderNote;

  /// No description provided for @trackerExcuseTitle.
  ///
  /// In en, this message translates to:
  /// **'Pause (excused)'**
  String get trackerExcuseTitle;

  /// No description provided for @trackerExcuseStart.
  ///
  /// In en, this message translates to:
  /// **'Start a pause'**
  String get trackerExcuseStart;

  /// No description provided for @trackerExcuseActive.
  ///
  /// In en, this message translates to:
  /// **'Paused since {date}'**
  String trackerExcuseActive(String date);

  /// No description provided for @trackerExcuseEnd.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get trackerExcuseEnd;

  /// No description provided for @trackerExcuseKindHaid.
  ///
  /// In en, this message translates to:
  /// **'Menstruation'**
  String get trackerExcuseKindHaid;

  /// No description provided for @trackerExcuseKindNifas.
  ///
  /// In en, this message translates to:
  /// **'Postnatal bleeding'**
  String get trackerExcuseKindNifas;

  /// No description provided for @trackerExcuseKindSakit.
  ///
  /// In en, this message translates to:
  /// **'Illness'**
  String get trackerExcuseKindSakit;

  /// No description provided for @trackerExcuseStatus.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get trackerExcuseStatus;

  /// No description provided for @trackerExcuseExpectedEnd.
  ///
  /// In en, this message translates to:
  /// **'Expected end (optional)'**
  String get trackerExcuseExpectedEnd;

  /// No description provided for @trackerExcuseNoExpected.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get trackerExcuseNoExpected;

  /// No description provided for @trackerExcuseHistory.
  ///
  /// In en, this message translates to:
  /// **'Earlier pauses'**
  String get trackerExcuseHistory;

  /// No description provided for @trackerExcuseDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get trackerExcuseDelete;

  /// No description provided for @trackerExcuseLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Kept only on this device. It is never uploaded, so another device will show these times as not recorded.'**
  String get trackerExcuseLocalOnly;

  /// No description provided for @trackerExcuseEndNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer tracking'**
  String get trackerExcuseEndNotifTitle;

  /// No description provided for @trackerExcuseEndNotifBody.
  ///
  /// In en, this message translates to:
  /// **'Tracking is paused. Ready to continue?'**
  String get trackerExcuseEndNotifBody;

  /// No description provided for @trackerExcuseSave.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get trackerExcuseSave;

  /// No description provided for @toolsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get toolsCancel;

  /// No description provided for @toolsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get toolsSave;

  /// No description provided for @tasbihTitle.
  ///
  /// In en, this message translates to:
  /// **'Tasbih counter'**
  String get tasbihTitle;

  /// No description provided for @tasbihSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dhikr counter'**
  String get tasbihSubtitle;

  /// No description provided for @tasbihFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get tasbihFree;

  /// No description provided for @tasbihCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get tasbihCustom;

  /// No description provided for @tasbihCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Target count'**
  String get tasbihCustomHint;

  /// No description provided for @tasbihRounds.
  ///
  /// In en, this message translates to:
  /// **'{count} rounds'**
  String tasbihRounds(int count);

  /// No description provided for @tasbihTotal.
  ///
  /// In en, this message translates to:
  /// **'Total {count}'**
  String tasbihTotal(int count);

  /// No description provided for @tasbihUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get tasbihUndo;

  /// No description provided for @tasbihReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get tasbihReset;

  /// No description provided for @tasbihSaveSession.
  ///
  /// In en, this message translates to:
  /// **'Save session'**
  String get tasbihSaveSession;

  /// No description provided for @tasbihSaved.
  ///
  /// In en, this message translates to:
  /// **'Session saved'**
  String get tasbihSaved;

  /// No description provided for @tasbihHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tasbihHistory;

  /// No description provided for @tasbihNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No saved sessions yet'**
  String get tasbihNoHistory;

  /// No description provided for @asmaulHusnaTitle.
  ///
  /// In en, this message translates to:
  /// **'Asmaul Husna'**
  String get asmaulHusnaTitle;

  /// No description provided for @asmaulHusnaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The 99 names of Allah with meanings'**
  String get asmaulHusnaSubtitle;

  /// No description provided for @asmaulHusnaSearch.
  ///
  /// In en, this message translates to:
  /// **'Search name or meaning'**
  String get asmaulHusnaSearch;

  /// No description provided for @hadithTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Hadith'**
  String get hadithTitle;

  /// No description provided for @hadithSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One selected hadith each day'**
  String get hadithSubtitle;

  /// No description provided for @hadithOfDay.
  ///
  /// In en, this message translates to:
  /// **'Today\'s hadith'**
  String get hadithOfDay;

  /// No description provided for @hadithAll.
  ///
  /// In en, this message translates to:
  /// **'All hadiths'**
  String get hadithAll;

  /// No description provided for @hadithReviewNote.
  ///
  /// In en, this message translates to:
  /// **'Text and translation are still under review. Refer to the original books for certainty.'**
  String get hadithReviewNote;

  /// No description provided for @khatamTitle.
  ///
  /// In en, this message translates to:
  /// **'Khatam Planner'**
  String get khatamTitle;

  /// No description provided for @khatamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily target until you finish'**
  String get khatamSubtitle;

  /// No description provided for @khatamEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit plan'**
  String get khatamEdit;

  /// No description provided for @khatamDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete plan'**
  String get khatamDelete;

  /// No description provided for @khatamSetupHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a start and target date; the app works out pages per day from your reading.'**
  String get khatamSetupHint;

  /// No description provided for @khatamPresetRamadan.
  ///
  /// In en, this message translates to:
  /// **'Finish in Ramadan'**
  String get khatamPresetRamadan;

  /// No description provided for @khatamRamadanAdjust.
  ///
  /// In en, this message translates to:
  /// **'Shift Ramadan start: {count} days'**
  String khatamRamadanAdjust(int count);

  /// No description provided for @khatamStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get khatamStartDate;

  /// No description provided for @khatamTargetDate.
  ///
  /// In en, this message translates to:
  /// **'Target date'**
  String get khatamTargetDate;

  /// No description provided for @khatamCount.
  ///
  /// In en, this message translates to:
  /// **'Number of khatams: {count}'**
  String khatamCount(int count);

  /// No description provided for @khatamOffDays.
  ///
  /// In en, this message translates to:
  /// **'Days off reading (optional)'**
  String get khatamOffDays;

  /// No description provided for @khatamPagesRead.
  ///
  /// In en, this message translates to:
  /// **'{read} of {total} pages'**
  String khatamPagesRead(int read, int total);

  /// No description provided for @khatamDone.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah, plan complete.'**
  String get khatamDone;

  /// No description provided for @khatamNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Starts {date}'**
  String khatamNotStarted(String date);

  /// No description provided for @khatamOverdue.
  ///
  /// In en, this message translates to:
  /// **'The target date has passed. Edit the plan to continue.'**
  String get khatamOverdue;

  /// No description provided for @khatamBehind.
  ///
  /// In en, this message translates to:
  /// **'About {count} pages behind schedule.'**
  String khatamBehind(int count);

  /// No description provided for @khatamOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track.'**
  String get khatamOnTrack;

  /// No description provided for @khatamDailyTarget.
  ///
  /// In en, this message translates to:
  /// **'Today\'s target: {count} pages'**
  String khatamDailyTarget(int count);

  /// No description provided for @khatamPerPrayer.
  ///
  /// In en, this message translates to:
  /// **'About {count} pages per prayer'**
  String khatamPerPrayer(int count);

  /// No description provided for @khatamDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} reading days left'**
  String khatamDaysLeft(int count);

  /// No description provided for @khatamPlanRange.
  ///
  /// In en, this message translates to:
  /// **'{start} - {end} · {count}× khatam'**
  String khatamPlanRange(String start, String end, int count);

  /// No description provided for @khatamUniqueNote.
  ///
  /// In en, this message translates to:
  /// **'Pages count once since the start date (for a single khatam); re-reading a page does not add progress.'**
  String get khatamUniqueNote;

  /// No description provided for @zakatTitle.
  ///
  /// In en, this message translates to:
  /// **'Zakat'**
  String get zakatTitle;

  /// No description provided for @zakatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mal and fitrah zakat calculator'**
  String get zakatSubtitle;

  /// No description provided for @zakatTabMal.
  ///
  /// In en, this message translates to:
  /// **'Mal'**
  String get zakatTabMal;

  /// No description provided for @zakatTabFitrah.
  ///
  /// In en, this message translates to:
  /// **'Fitrah'**
  String get zakatTabFitrah;

  /// No description provided for @zakatTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get zakatTabHistory;

  /// No description provided for @zakatGoldPrice.
  ///
  /// In en, this message translates to:
  /// **'24-carat gold price per gram'**
  String get zakatGoldPrice;

  /// No description provided for @zakatGoldNote.
  ///
  /// In en, this message translates to:
  /// **'Enter the current gold price yourself. Nisab = 85 g of 24-carat gold. Automatic prices are not available yet.'**
  String get zakatGoldNote;

  /// No description provided for @zakatWealth.
  ///
  /// In en, this message translates to:
  /// **'Total wealth you own'**
  String get zakatWealth;

  /// No description provided for @zakatDebts.
  ///
  /// In en, this message translates to:
  /// **'Debts due now'**
  String get zakatDebts;

  /// No description provided for @zakatHaul.
  ///
  /// In en, this message translates to:
  /// **'Wealth held for 1 year (haul)'**
  String get zakatHaul;

  /// No description provided for @zakatNisab.
  ///
  /// In en, this message translates to:
  /// **'Nisab: {amount}'**
  String zakatNisab(String amount);

  /// No description provided for @zakatNeedGold.
  ///
  /// In en, this message translates to:
  /// **'Enter the gold price to compute nisab.'**
  String get zakatNeedGold;

  /// No description provided for @zakatBelowNisab.
  ///
  /// In en, this message translates to:
  /// **'Wealth has not reached nisab.'**
  String get zakatBelowNisab;

  /// No description provided for @zakatNoHaul.
  ///
  /// In en, this message translates to:
  /// **'Haul not yet reached.'**
  String get zakatNoHaul;

  /// No description provided for @zakatDue.
  ///
  /// In en, this message translates to:
  /// **'Zakat: {amount}'**
  String zakatDue(String amount);

  /// No description provided for @zakatSaveResult.
  ///
  /// In en, this message translates to:
  /// **'Save to history'**
  String get zakatSaveResult;

  /// No description provided for @zakatSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device'**
  String get zakatSaved;

  /// No description provided for @zakatPeople.
  ///
  /// In en, this message translates to:
  /// **'Number of people'**
  String get zakatPeople;

  /// No description provided for @zakatFitrahRate.
  ///
  /// In en, this message translates to:
  /// **'Fitrah per person'**
  String get zakatFitrahRate;

  /// No description provided for @zakatFitrahNote.
  ///
  /// In en, this message translates to:
  /// **'Reference: {rice} kg rice per person. The cash value may differ by region. Source: {source}.'**
  String zakatFitrahNote(String rice, String source);

  /// No description provided for @zakatNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No saved calculations yet'**
  String get zakatNoHistory;

  /// No description provided for @zakatLocalNote.
  ///
  /// In en, this message translates to:
  /// **'History is stored on this device only.'**
  String get zakatLocalNote;

  /// No description provided for @zakatDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is a helper tool, not a fatwa. Consult a scholar or an official zakat institution.'**
  String get zakatDisclaimer;

  /// No description provided for @widgetEndsAt.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get widgetEndsAt;

  /// No description provided for @widgetDoneShort.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get widgetDoneShort;

  /// No description provided for @widgetSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Widget Settings'**
  String get widgetSettingsTitle;

  /// No description provided for @widgetSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme, opacity, text size and info'**
  String get widgetSettingsSubtitle;

  /// No description provided for @widgetSettingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Colour theme'**
  String get widgetSettingsTheme;

  /// No description provided for @widgetSettingsOpacity.
  ///
  /// In en, this message translates to:
  /// **'Background opacity'**
  String get widgetSettingsOpacity;

  /// No description provided for @widgetSettingsTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get widgetSettingsTextSize;

  /// No description provided for @widgetSettingsSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get widgetSettingsSizeSmall;

  /// No description provided for @widgetSettingsSizeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get widgetSettingsSizeNormal;

  /// No description provided for @widgetSettingsSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get widgetSettingsSizeLarge;

  /// No description provided for @widgetSettingsInfo.
  ///
  /// In en, this message translates to:
  /// **'Information shown'**
  String get widgetSettingsInfo;

  /// No description provided for @widgetSettingsHijri.
  ///
  /// In en, this message translates to:
  /// **'Hijri date'**
  String get widgetSettingsHijri;

  /// No description provided for @widgetSettingsGregorian.
  ///
  /// In en, this message translates to:
  /// **'Gregorian date'**
  String get widgetSettingsGregorian;

  /// No description provided for @widgetSettingsLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get widgetSettingsLocation;

  /// No description provided for @widgetSettingsProgress.
  ///
  /// In en, this message translates to:
  /// **'Prayer progress and time limit'**
  String get widgetSettingsProgress;

  /// No description provided for @widgetSettingsNote.
  ///
  /// In en, this message translates to:
  /// **'Date and location appear on the Strip and List widgets. The Small widget only uses theme, opacity and text size.'**
  String get widgetSettingsNote;

  /// No description provided for @widgetPreviewGregorian.
  ///
  /// In en, this message translates to:
  /// **'Tuesday, 10 November 2026'**
  String get widgetPreviewGregorian;

  /// No description provided for @widgetPreviewHijri.
  ///
  /// In en, this message translates to:
  /// **'30 Jumada Al-Awwal 1448 H'**
  String get widgetPreviewHijri;

  /// No description provided for @widgetPreviewCity.
  ///
  /// In en, this message translates to:
  /// **'Jakarta'**
  String get widgetPreviewCity;

  /// No description provided for @widgetPreviewProgress.
  ///
  /// In en, this message translates to:
  /// **'2/5 done · Ends 15:12'**
  String get widgetPreviewProgress;

  /// No description provided for @hadithCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get hadithCopy;

  /// No description provided for @hadithCopied.
  ///
  /// In en, this message translates to:
  /// **'Hadith copied'**
  String get hadithCopied;

  /// No description provided for @zakatWealthHelp.
  ///
  /// In en, this message translates to:
  /// **'The total of all zakatable wealth: cash, savings, value of gold/silver, collectible receivables and trade goods, in rupiah.'**
  String get zakatWealthHelp;

  /// No description provided for @zakatDebtsHelp.
  ///
  /// In en, this message translates to:
  /// **'Debts you must pay now (optional).'**
  String get zakatDebtsHelp;
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
