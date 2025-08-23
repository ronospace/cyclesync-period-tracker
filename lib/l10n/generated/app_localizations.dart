// Generated file. Do not edit.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('sw'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'FlowSense'**
  String get appTitle;

  /// Home tab in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// Cycle tab in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get bottomNavCycle;

  /// Health tab in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get bottomNavHealth;

  /// Settings tab in bottom navigation
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get bottomNavSettings;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Language settings option
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Subtitle for language settings
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get settingsLanguageSubtitle;

  /// Notifications settings option
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Privacy settings option
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get settingsPrivacy;

  /// Theme settings option
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Help and support option
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settingsHelp;

  /// Title for language selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get languageSelectorTitle;

  /// Subtitle for language selection screen
  ///
  /// In en, this message translates to:
  /// **'Global accessibility for everyone'**
  String get languageSelectorSubtitle;

  /// Placeholder text for language search
  ///
  /// In en, this message translates to:
  /// **'Search languages...'**
  String get languageSelectorSearch;

  /// Number of languages found in search
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No languages found} =1{1 language found} other{{count} languages found}}'**
  String languageSelectorResults(int count);

  /// Cycle tracking screen title
  ///
  /// In en, this message translates to:
  /// **'Cycle Tracking'**
  String get cycleTitle;

  /// Label for current cycle phase
  ///
  /// In en, this message translates to:
  /// **'Current Phase'**
  String get cycleCurrentPhase;

  /// Label for next period prediction
  ///
  /// In en, this message translates to:
  /// **'Next Period'**
  String get cycleNextPeriod;

  /// Days remaining until next period
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String cycleDaysLeft(int days);

  /// Health screen title
  ///
  /// In en, this message translates to:
  /// **'Health Insights'**
  String get healthTitle;

  /// Health symptoms section
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get healthSymptoms;

  /// Mood tracking section
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get healthMood;

  /// Energy level tracking
  ///
  /// In en, this message translates to:
  /// **'Energy Level'**
  String get healthEnergy;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Personal information section
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInfo;

  /// Cycle history section
  ///
  /// In en, this message translates to:
  /// **'Cycle History'**
  String get profileCycleHistory;

  /// Data export option
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get profileDataExport;

  /// Help and support screen title
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpTitle;

  /// FAQ section title
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get helpFaq;

  /// Contact support option
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get helpContactSupport;

  /// User guide option
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get helpUserGuide;

  /// Privacy policy option
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get helpPrivacyPolicy;

  /// Report issue option
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get helpReportIssue;

  /// Common save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Common cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Common close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Common back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// Common next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// Common done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// Common error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// Common success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// Common loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// Today section title
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTitle;

  /// Yesterday section title
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayTitle;

  /// Tomorrow section title
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrowTitle;

  /// Follicular phase of menstrual cycle
  ///
  /// In en, this message translates to:
  /// **'Follicular Phase'**
  String get phaseFollicular;

  /// Ovulation phase of menstrual cycle
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get phaseOvulation;

  /// Luteal phase of menstrual cycle
  ///
  /// In en, this message translates to:
  /// **'Luteal Phase'**
  String get phaseLuteal;

  /// Menstruation phase of menstrual cycle
  ///
  /// In en, this message translates to:
  /// **'Menstruation'**
  String get phaseMenstruation;

  /// Menstrual cramps symptom
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get symptomCramps;

  /// Headache symptom
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get symptomHeadache;

  /// Backache symptom
  ///
  /// In en, this message translates to:
  /// **'Backache'**
  String get symptomBackache;

  /// Bloating symptom
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get symptomBloating;

  /// Fatigue symptom
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomFatigue;

  /// Happy mood
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// Sad mood
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// Anxious mood
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// Irritated mood
  ///
  /// In en, this message translates to:
  /// **'Irritated'**
  String get moodIrritated;

  /// Calm mood
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodCalm;

  /// High energy level
  ///
  /// In en, this message translates to:
  /// **'High Energy'**
  String get energyHigh;

  /// Medium energy level
  ///
  /// In en, this message translates to:
  /// **'Medium Energy'**
  String get energyMedium;

  /// Low energy level
  ///
  /// In en, this message translates to:
  /// **'Low Energy'**
  String get energyLow;

  /// Default notification title
  ///
  /// In en, this message translates to:
  /// **'FlowSense Notification'**
  String get notificationTitle;

  /// Period reminder notification
  ///
  /// In en, this message translates to:
  /// **'Your period is expected to start soon'**
  String get notificationPeriodReminder;

  /// Ovulation reminder notification
  ///
  /// In en, this message translates to:
  /// **'You\'re approaching your fertile window'**
  String get notificationOvulationReminder;

  /// Accessibility label for menu button
  ///
  /// In en, this message translates to:
  /// **'Menu button'**
  String get accessibilityMenuButton;

  /// Accessibility label for calendar
  ///
  /// In en, this message translates to:
  /// **'Calendar view'**
  String get accessibilityCalendar;

  /// Accessibility label for settings button
  ///
  /// In en, this message translates to:
  /// **'Settings button'**
  String get accessibilitySettingsButton;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'FlowSense'**
  String get homeTitle;

  /// Welcome message on home screen
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String homeWelcomeMessage(String name);

  /// Subtitle under welcome message
  ///
  /// In en, this message translates to:
  /// **'Track your cycle with confidence'**
  String get homeWelcomeSubtitle;

  /// Current menstrual phase display
  ///
  /// In en, this message translates to:
  /// **'Menstrual Phase'**
  String get homeMenstrualPhase;

  /// Current cycle day information
  ///
  /// In en, this message translates to:
  /// **'Day {day} of your cycle'**
  String homeCycleDayInfo(int day);

  /// Upcoming events section title
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get homeUpcomingEvents;

  /// Next period event label
  ///
  /// In en, this message translates to:
  /// **'Next Period'**
  String get homeNextPeriod;

  /// Ovulation event label
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get homeOvulation;

  /// Fertile window event label
  ///
  /// In en, this message translates to:
  /// **'Fertile Window'**
  String get homeFertileWindow;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActions;

  /// Log cycle quick action
  ///
  /// In en, this message translates to:
  /// **'Log Cycle'**
  String get homeLogCycle;

  /// View history quick action
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get homeViewHistory;

  /// Calendar quick action
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get homeCalendar;

  /// Analytics quick action
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get homeAnalytics;

  /// AI insights quick action
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get homeAIInsights;

  /// Daily log quick action
  ///
  /// In en, this message translates to:
  /// **'Daily Log'**
  String get homeDailyLog;

  /// Tomorrow label for events
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get homeTomorrow;

  /// Days ago label for past events
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String homeDaysAgo(int days);

  /// Appearance settings section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Light theme description
  ///
  /// In en, this message translates to:
  /// **'Use light theme'**
  String get lightModeDescription;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Dark theme description
  ///
  /// In en, this message translates to:
  /// **'Use dark theme'**
  String get darkModeDescription;

  /// System default theme option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// System default theme description
  ///
  /// In en, this message translates to:
  /// **'Follow system settings'**
  String get systemDefaultDescription;

  /// Language settings section title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// Language settings subtitle with current selection
  ///
  /// In en, this message translates to:
  /// **'Swahili • 36 languages available'**
  String get languageSubtitle;

  /// Swahili language name in Swahili
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get swahiliLanguage;

  /// Tools settings section title
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsTitle;

  /// Notifications management description
  ///
  /// In en, this message translates to:
  /// **'Manage cycle reminders and alerts'**
  String get notificationsManage;

  /// Smart notifications option
  ///
  /// In en, this message translates to:
  /// **'Smart Notifications'**
  String get smartNotifications;

  /// Smart notifications description
  ///
  /// In en, this message translates to:
  /// **'AI-powered insights and predictions'**
  String get smartNotificationsDescription;

  /// Diagnostics option
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnosticsTitle;

  /// Diagnostics description
  ///
  /// In en, this message translates to:
  /// **'Test Firebase connection'**
  String get diagnosticsDescription;

  /// User section title
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userTitle;

  /// Health insights quick action
  ///
  /// In en, this message translates to:
  /// **'Health Insights'**
  String get homeHealthInsights;

  /// Symptom trends quick action
  ///
  /// In en, this message translates to:
  /// **'Symptom Trends'**
  String get homeSymptomTrends;

  /// AI health coach quick action
  ///
  /// In en, this message translates to:
  /// **'AI Health Coach'**
  String get homeAIHealthCoach;

  /// Days in the future format
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String homeInDays(int days);

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get homeYesterday;

  /// Recent cycles section title
  ///
  /// In en, this message translates to:
  /// **'Recent Cycles'**
  String get homeRecentCycles;

  /// View all button text
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get homeViewAll;

  /// Start tracking message
  ///
  /// In en, this message translates to:
  /// **'Start Tracking Your Cycle'**
  String get homeStartTracking;

  /// Start tracking description
  ///
  /// In en, this message translates to:
  /// **'Log your first cycle to see personalized insights and predictions.'**
  String get homeStartTrackingDescription;

  /// Log first cycle button
  ///
  /// In en, this message translates to:
  /// **'Log First Cycle'**
  String get homeLogFirstCycle;

  /// Error message for loading cycles
  ///
  /// In en, this message translates to:
  /// **'Unable to load recent cycles'**
  String get homeUnableToLoad;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get homeTryAgain;

  /// No cycles message
  ///
  /// In en, this message translates to:
  /// **'No cycles logged yet. Start tracking!'**
  String get homeNoCycles;

  /// Daily log screen title
  ///
  /// In en, this message translates to:
  /// **'Daily Log'**
  String get dailyLogTitle;

  /// Log today tab
  ///
  /// In en, this message translates to:
  /// **'Log Today'**
  String get logToday;

  /// History tab
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Selected date label
  ///
  /// In en, this message translates to:
  /// **'Selected Date'**
  String get selectedDate;

  /// Quick log templates section
  ///
  /// In en, this message translates to:
  /// **'Quick Log Templates'**
  String get quickLogTemplates;

  /// Great day template
  ///
  /// In en, this message translates to:
  /// **'Great Day'**
  String get greatDay;

  /// Good day template
  ///
  /// In en, this message translates to:
  /// **'Good Day'**
  String get goodDay;

  /// Okay day template
  ///
  /// In en, this message translates to:
  /// **'Okay Day'**
  String get okayDay;

  /// Tough day template
  ///
  /// In en, this message translates to:
  /// **'Tough Day'**
  String get toughDay;

  /// Period day template
  ///
  /// In en, this message translates to:
  /// **'Period Day'**
  String get periodDay;

  /// PMS template
  ///
  /// In en, this message translates to:
  /// **'PMS'**
  String get pms;

  /// Mood label
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// Energy label
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// Pain level label
  ///
  /// In en, this message translates to:
  /// **'Pain Level'**
  String get painLevel;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// Save daily log button
  ///
  /// In en, this message translates to:
  /// **'Save Daily Log'**
  String get saveDailyLog;

  /// Logging for date label
  ///
  /// In en, this message translates to:
  /// **'Logging for'**
  String get loggingFor;

  /// Change button
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Mood level label
  ///
  /// In en, this message translates to:
  /// **'Mood Level'**
  String get moodLevel;

  /// Energy level label
  ///
  /// In en, this message translates to:
  /// **'Energy Level'**
  String get energyLevel;

  /// Stress level label
  ///
  /// In en, this message translates to:
  /// **'Stress Level'**
  String get stressLevel;

  /// Sleep quality label
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get sleepQuality;

  /// Water intake label
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get waterIntake;

  /// Exercise label
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// Symptoms today label
  ///
  /// In en, this message translates to:
  /// **'Symptoms Today'**
  String get symptomsToday;

  /// Daily notes label
  ///
  /// In en, this message translates to:
  /// **'Daily Notes'**
  String get dailyNotes;

  /// Wellbeing tab
  ///
  /// In en, this message translates to:
  /// **'Wellbeing'**
  String get wellbeing;

  /// Lifestyle tab
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get lifestyle;

  /// Symptoms tab
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// AI insights tab
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsights;

  /// AI predictions section
  ///
  /// In en, this message translates to:
  /// **'AI Predictions'**
  String get aiPredictions;

  /// Personal insights section
  ///
  /// In en, this message translates to:
  /// **'Personal Insights'**
  String get personalInsights;

  /// Next period prediction
  ///
  /// In en, this message translates to:
  /// **'Next Period'**
  String get nextPeriod;

  /// Ovulation prediction
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get ovulation;

  /// Cycle regularity prediction
  ///
  /// In en, this message translates to:
  /// **'Cycle Regularity'**
  String get cycleRegularity;

  /// Confidence percentage
  ///
  /// In en, this message translates to:
  /// **'confidence'**
  String get confidence;

  /// Glasses unit for water
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get glasses;

  /// Minutes unit
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// Daily goal achieved message
  ///
  /// In en, this message translates to:
  /// **'🎉 Daily goal achieved!'**
  String get dailyGoalAchieved;

  /// Minutes to reach daily goal
  ///
  /// In en, this message translates to:
  /// **'{minutes} min to reach daily goal'**
  String minToReachDailyGoal(int minutes);

  /// Instructions for symptom selection
  ///
  /// In en, this message translates to:
  /// **'Tap any symptoms you experienced today:'**
  String get tapSymptomsExperienced;

  /// Number of symptoms selected
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 symptom selected} other{{count} symptoms selected}}'**
  String symptomSelected(int count);

  /// Daily notes prompt
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today? Any thoughts or observations?'**
  String get howFeelingToday;

  /// Daily notes placeholder
  ///
  /// In en, this message translates to:
  /// **'e.g., Feeling great today, had a good workout...'**
  String get feelingGreatToday;

  /// Loading message for AI insights
  ///
  /// In en, this message translates to:
  /// **'Generating AI insights...'**
  String get generatingAIInsights;

  /// No insights available message
  ///
  /// In en, this message translates to:
  /// **'No insights yet'**
  String get noInsightsYet;

  /// Instruction to keep tracking for insights
  ///
  /// In en, this message translates to:
  /// **'Keep tracking your daily data to get personalized AI insights!'**
  String get keepTrackingForInsights;

  /// Smart daily log title
  ///
  /// In en, this message translates to:
  /// **'Smart Daily Log'**
  String get smartDailyLog;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Saving status
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// Daily log saved message
  ///
  /// In en, this message translates to:
  /// **'Daily log saved for {date}'**
  String dailyLogSavedFor(String date);

  /// Error saving daily log
  ///
  /// In en, this message translates to:
  /// **'Error saving daily log: {error}'**
  String errorSavingDailyLog(String error);

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Very low level
  ///
  /// In en, this message translates to:
  /// **'Very Low'**
  String get veryLow;

  /// Low level
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// Neutral level
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get neutral;

  /// Good level
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// Excellent level
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// Exhausted energy level
  ///
  /// In en, this message translates to:
  /// **'Exhausted'**
  String get exhausted;

  /// Normal level
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// High level
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// Energetic level
  ///
  /// In en, this message translates to:
  /// **'Energetic'**
  String get energetic;

  /// No pain
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Mild pain
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get mild;

  /// Moderate pain
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// Severe pain
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severe;

  /// Extreme pain
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get extreme;

  /// Very calm stress level
  ///
  /// In en, this message translates to:
  /// **'Very Calm'**
  String get veryCalm;

  /// Relaxed stress level
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get relaxed;

  /// Stressed level
  ///
  /// In en, this message translates to:
  /// **'Stressed'**
  String get stressed;

  /// Very stressed level
  ///
  /// In en, this message translates to:
  /// **'Very Stressed'**
  String get veryStressed;

  /// Poor sleep quality
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// Fair sleep quality
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// Very good sleep quality
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get veryGood;

  /// Cramps symptom
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get cramps;

  /// Headache symptom
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get headache;

  /// Mood swings symptom
  ///
  /// In en, this message translates to:
  /// **'Mood Swings'**
  String get moodSwings;

  /// Fatigue symptom
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get fatigue;

  /// Bloating symptom
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get bloating;

  /// Breast tenderness symptom
  ///
  /// In en, this message translates to:
  /// **'Breast Tenderness'**
  String get breastTenderness;

  /// Nausea symptom
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get nausea;

  /// Back pain symptom
  ///
  /// In en, this message translates to:
  /// **'Back Pain'**
  String get backPain;

  /// Acne symptom
  ///
  /// In en, this message translates to:
  /// **'Acne'**
  String get acne;

  /// Food cravings symptom
  ///
  /// In en, this message translates to:
  /// **'Food Cravings'**
  String get foodCravings;

  /// Sleep issues symptom
  ///
  /// In en, this message translates to:
  /// **'Sleep Issues'**
  String get sleepIssues;

  /// Hot flashes symptom
  ///
  /// In en, this message translates to:
  /// **'Hot Flashes'**
  String get hotFlashes;

  /// No daily logs message
  ///
  /// In en, this message translates to:
  /// **'No daily logs yet'**
  String get noDailyLogsYet;

  /// Start logging instruction
  ///
  /// In en, this message translates to:
  /// **'Start logging your daily mood and energy'**
  String get startLoggingDailyMood;

  /// Failed to load logs error
  ///
  /// In en, this message translates to:
  /// **'Failed to load logs: {error}'**
  String failedToLoadLogs(String error);

  /// Notes label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// More items indicator
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get more;

  /// Daily log saved success message
  ///
  /// In en, this message translates to:
  /// **'Daily log saved!'**
  String get dailyLogSaved;

  /// Failed to save log error
  ///
  /// In en, this message translates to:
  /// **'Failed to save log: {error}'**
  String failedToSaveLog(String error);

  /// Failed to load existing log error
  ///
  /// In en, this message translates to:
  /// **'Failed to load existing log: {error}'**
  String failedToLoadExistingLog(String error);

  /// Notes field hint
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get howAreYouFeelingToday;

  /// Updated status
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// Okay level
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// Tools section title
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// Data management section
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// Account section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Verified status
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Health integration option
  ///
  /// In en, this message translates to:
  /// **'Health Integration'**
  String get healthIntegration;

  /// Health integration description
  ///
  /// In en, this message translates to:
  /// **'Sync with HealthKit and Google Fit'**
  String get healthIntegrationDescription;

  /// Data management description
  ///
  /// In en, this message translates to:
  /// **'Export, import, and backup your data'**
  String get dataManagementDescription;

  /// Export & backup option
  ///
  /// In en, this message translates to:
  /// **'Export & Backup'**
  String get exportBackup;

  /// Export & backup description
  ///
  /// In en, this message translates to:
  /// **'Generate reports and backup your data'**
  String get exportBackupDescription;

  /// Social sharing option
  ///
  /// In en, this message translates to:
  /// **'Social Sharing'**
  String get socialSharing;

  /// Social sharing description
  ///
  /// In en, this message translates to:
  /// **'Share data with providers and partners'**
  String get socialSharingDescription;

  /// Sync status option
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get syncStatus;

  /// Sync status description
  ///
  /// In en, this message translates to:
  /// **'Check cloud synchronization'**
  String get syncStatusDescription;

  /// About option
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// About description
  ///
  /// In en, this message translates to:
  /// **'App version and credits'**
  String get aboutDescription;

  /// Sign out option
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Sign out description
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get signOutDescription;

  /// No description provided for @getHelpUsingFlowSense.
  ///
  /// In en, this message translates to:
  /// **'Get help using FlowSense'**
  String get getHelpUsingFlowSense;

  /// Symptom trends description
  ///
  /// In en, this message translates to:
  /// **'View symptom patterns and insights'**
  String get viewSymptomPatterns;

  /// Cycle history description
  ///
  /// In en, this message translates to:
  /// **'View all cycles'**
  String get viewAllCycles;

  /// Analytics description
  ///
  /// In en, this message translates to:
  /// **'View cycle insights'**
  String get viewCycleInsights;

  /// Diagnostics description
  ///
  /// In en, this message translates to:
  /// **'Test Firebase connection'**
  String get testFirebaseConnection;

  /// Coming soon dialog title
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Feature coming soon message
  ///
  /// In en, this message translates to:
  /// **'{feature} will be available in a future update.'**
  String featureAvailableInFuture(String feature);

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @aboutFlowSense.
  ///
  /// In en, this message translates to:
  /// **'About FlowSense'**
  String get aboutFlowSense;

  /// No description provided for @flowSenseVersion.
  ///
  /// In en, this message translates to:
  /// **'FlowSense v1.0.0'**
  String get flowSenseVersion;

  /// App description
  ///
  /// In en, this message translates to:
  /// **'A modern cycle tracking app built with Flutter.'**
  String get modernCycleTrackingApp;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'Features:'**
  String get features;

  /// Feature: cycle logging
  ///
  /// In en, this message translates to:
  /// **'• Cycle logging and tracking'**
  String get cycleLoggingTracking;

  /// Feature: analytics
  ///
  /// In en, this message translates to:
  /// **'• Analytics and insights'**
  String get analyticsInsights;

  /// Feature: dark mode
  ///
  /// In en, this message translates to:
  /// **'• Dark mode support'**
  String get darkModeSupport;

  /// Feature: cloud sync
  ///
  /// In en, this message translates to:
  /// **'• Cloud synchronization'**
  String get cloudSynchronization;

  /// Feature: privacy
  ///
  /// In en, this message translates to:
  /// **'• Privacy-focused design'**
  String get privacyFocusedDesign;

  /// Sign out confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get areYouSureSignOut;

  /// Firebase auth sync item
  ///
  /// In en, this message translates to:
  /// **'Firebase Authentication'**
  String get firebaseAuthentication;

  /// Connected status
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Firestore sync item
  ///
  /// In en, this message translates to:
  /// **'Cloud Firestore'**
  String get cloudFirestore;

  /// Synced time ago
  ///
  /// In en, this message translates to:
  /// **'Synced {minutes} minutes ago'**
  String syncedMinutesAgo(int minutes);

  /// Health data sync item
  ///
  /// In en, this message translates to:
  /// **'Health Data'**
  String get healthData;

  /// Pending sync status
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get pendingSync;

  /// Analytics data sync item
  ///
  /// In en, this message translates to:
  /// **'Analytics Data'**
  String get analyticsData;

  /// Up to date status
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get upToDate;

  /// Total synced records label
  ///
  /// In en, this message translates to:
  /// **'Total synced records:'**
  String get totalSyncedRecords;

  /// Last full sync label
  ///
  /// In en, this message translates to:
  /// **'Last full sync:'**
  String get lastFullSync;

  /// Today at time format
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String todayAt(String time);

  /// Storage used label
  ///
  /// In en, this message translates to:
  /// **'Storage used:'**
  String get storageUsed;

  /// Sync now button
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// Manual sync success message
  ///
  /// In en, this message translates to:
  /// **'Manual sync completed successfully!'**
  String get manualSyncCompleted;

  /// Sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// Apple sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get signInWithApple;

  /// Guest sign-in button
  ///
  /// In en, this message translates to:
  /// **'Try as Guest'**
  String get tryAsGuest;

  /// Email option divider
  ///
  /// In en, this message translates to:
  /// **'or email'**
  String get orContinueWithEmail;

  /// Sign up prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// Sign in prompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Create account title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinFlowSenseCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join the FlowSense community'**
  String get joinFlowSenseCommunity;

  /// Password field help text
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHelp;

  /// Terms agreement text
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our Terms of Service and Privacy Policy'**
  String get termsAgreement;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'es',
    'fa',
    'fr',
    'hi',
    'id',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'sw',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fa':
      return AppLocalizationsFa();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sw':
      return AppLocalizationsSw();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
