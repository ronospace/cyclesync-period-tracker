// Generated file. Do not edit.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CycleSync';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavCycle => 'Cycle';

  @override
  String get bottomNavHealth => 'Health';

  @override
  String get bottomNavSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose your preferred language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPrivacy => 'Privacy & Security';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsHelp => 'Help & Support';

  @override
  String get languageSelectorTitle => 'Choose Language';

  @override
  String get languageSelectorSubtitle => 'Global accessibility for everyone';

  @override
  String get languageSelectorSearch => 'Search languages...';

  @override
  String languageSelectorResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count languages found',
      one: '1 language found',
      zero: 'No languages found',
    );
    return '$_temp0';
  }

  @override
  String get cycleTitle => 'Cycle Tracking';

  @override
  String get cycleCurrentPhase => 'Current Phase';

  @override
  String get cycleNextPeriod => 'Next Period';

  @override
  String cycleDaysLeft(int days) {
    return '$days days left';
  }

  @override
  String get healthTitle => 'Health Insights';

  @override
  String get healthSymptoms => 'Symptoms';

  @override
  String get healthMood => 'Mood';

  @override
  String get healthEnergy => 'Energy Level';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profilePersonalInfo => 'Personal Information';

  @override
  String get profileCycleHistory => 'Cycle History';

  @override
  String get profileDataExport => 'Export Data';

  @override
  String get helpTitle => 'Help & Support';

  @override
  String get helpFaq => 'Frequently Asked Questions';

  @override
  String get helpContactSupport => 'Contact Support';

  @override
  String get helpUserGuide => 'User Guide';

  @override
  String get helpPrivacyPolicy => 'Privacy Policy';

  @override
  String get helpReportIssue => 'Report Issue';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonDone => 'Done';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get todayTitle => 'Today';

  @override
  String get yesterdayTitle => 'Yesterday';

  @override
  String get tomorrowTitle => 'Tomorrow';

  @override
  String get phaseFollicular => 'Follicular Phase';

  @override
  String get phaseOvulation => 'Ovulation';

  @override
  String get phaseLuteal => 'Luteal Phase';

  @override
  String get phaseMenstruation => 'Menstruation';

  @override
  String get symptomCramps => 'Cramps';

  @override
  String get symptomHeadache => 'Headache';

  @override
  String get symptomBackache => 'Backache';

  @override
  String get symptomBloating => 'Bloating';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodIrritated => 'Irritated';

  @override
  String get moodCalm => 'Calm';

  @override
  String get energyHigh => 'High Energy';

  @override
  String get energyMedium => 'Medium Energy';

  @override
  String get energyLow => 'Low Energy';

  @override
  String get notificationTitle => 'CycleSync Notification';

  @override
  String get notificationPeriodReminder =>
      'Your period is expected to start soon';

  @override
  String get notificationOvulationReminder =>
      'You\'re approaching your fertile window';

  @override
  String get accessibilityMenuButton => 'Menu button';

  @override
  String get accessibilityCalendar => 'Calendar view';

  @override
  String get accessibilitySettingsButton => 'Settings button';
}
