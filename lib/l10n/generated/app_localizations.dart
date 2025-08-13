// Generated file. Do not edit.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

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
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'CycleSync'**
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
  /// **'CycleSync Notification'**
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
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
