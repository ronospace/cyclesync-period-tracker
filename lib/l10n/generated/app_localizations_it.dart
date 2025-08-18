// Generated file. Do not edit.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'CycleSync';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavCycle => 'Ciclo';

  @override
  String get bottomNavHealth => 'Salute';

  @override
  String get bottomNavSettings => 'Impostazioni';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageSubtitle => 'Scegli la tua lingua preferita';

  @override
  String get settingsNotifications => 'Notifiche';

  @override
  String get settingsPrivacy => 'Privacy e Sicurezza';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsHelp => 'Aiuto e Supporto';

  @override
  String get languageSelectorTitle => 'Scegli Lingua';

  @override
  String get languageSelectorSubtitle => 'Accessibilità globale per tutti';

  @override
  String get languageSelectorSearch => 'Cerca lingue...';

  @override
  String languageSelectorResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lingue trovate',
      one: '1 lingua trovata',
      zero: 'Nessuna lingua trovata',
    );
    return '$_temp0';
  }

  @override
  String get cycleTitle => 'Tracciamento Ciclo';

  @override
  String get cycleCurrentPhase => 'Fase Attuale';

  @override
  String get cycleNextPeriod => 'Prossimo Periodo';

  @override
  String cycleDaysLeft(int days) {
    return '$days giorni rimanenti';
  }

  @override
  String get healthTitle => 'Insight Salute';

  @override
  String get healthSymptoms => 'Sintomi';

  @override
  String get healthMood => 'Umore';

  @override
  String get healthEnergy => 'Livello di Energia';

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
  String get commonSave => 'Salva';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonBack => 'Indietro';

  @override
  String get commonNext => 'Avanti';

  @override
  String get commonDone => 'Fatto';

  @override
  String get commonError => 'Errore';

  @override
  String get commonSuccess => 'Successo';

  @override
  String get commonLoading => 'Caricamento...';

  @override
  String get todayTitle => 'Today';

  @override
  String get yesterdayTitle => 'Yesterday';

  @override
  String get tomorrowTitle => 'Tomorrow';

  @override
  String get phaseFollicular => 'Fase Follicolare';

  @override
  String get phaseOvulation => 'Ovulazione';

  @override
  String get phaseLuteal => 'Fase Luteale';

  @override
  String get phaseMenstruation => 'Mestruazioni';

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
  String get moodHappy => 'Felice';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodAnxious => 'Ansioso';

  @override
  String get moodIrritated => 'Irritato';

  @override
  String get moodCalm => 'Calmo';

  @override
  String get energyHigh => 'High Energy';

  @override
  String get energyMedium => 'Medium Energy';

  @override
  String get energyLow => 'Low Energy';

  @override
  String get notificationTitle => 'Notifica CycleSync';

  @override
  String get notificationPeriodReminder =>
      'Il tuo periodo dovrebbe iniziare presto';

  @override
  String get notificationOvulationReminder =>
      'Ti stai avvicinando alla finestra fertile';

  @override
  String get accessibilityMenuButton => 'Menu button';

  @override
  String get accessibilityCalendar => 'Calendar view';

  @override
  String get accessibilitySettingsButton => 'Settings button';

  @override
  String get homeTitle => 'CycleSync';

  @override
  String homeWelcomeMessage(String name) {
    return 'Hello, $name!';
  }

  @override
  String get homeWelcomeSubtitle => 'Track your cycle with confidence';

  @override
  String get homeMenstrualPhase => 'Menstrual Phase';

  @override
  String homeCycleDayInfo(int day) {
    return 'Day $day of your cycle';
  }

  @override
  String get homeUpcomingEvents => 'Upcoming Events';

  @override
  String get homeNextPeriod => 'Next Period';

  @override
  String get homeOvulation => 'Ovulation';

  @override
  String get homeFertileWindow => 'Fertile Window';

  @override
  String get homeQuickActions => 'Quick Actions';

  @override
  String get homeLogCycle => 'Log Cycle';

  @override
  String get homeViewHistory => 'View History';

  @override
  String get homeCalendar => 'Calendar';

  @override
  String get homeAnalytics => 'Analytics';

  @override
  String get homeAIInsights => 'AI Insights';

  @override
  String get homeDailyLog => 'Daily Log';

  @override
  String get homeTomorrow => 'Tomorrow';

  @override
  String homeDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get lightModeDescription => 'Use light theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDescription => 'Use dark theme';

  @override
  String get systemDefault => 'System Default';

  @override
  String get systemDefaultDescription => 'Follow system settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Swahili • 36 languages available';

  @override
  String get swahiliLanguage => 'Kiswahili';

  @override
  String get toolsTitle => 'Tools';

  @override
  String get notificationsManage => 'Manage cycle reminders and alerts';

  @override
  String get smartNotifications => 'Smart Notifications';

  @override
  String get smartNotificationsDescription =>
      'AI-powered insights and predictions';

  @override
  String get diagnosticsTitle => 'Diagnostics';

  @override
  String get diagnosticsDescription => 'Test Firebase connection';

  @override
  String get userTitle => 'User';

  @override
  String get homeHealthInsights => 'Health Insights';

  @override
  String get homeSymptomTrends => 'Symptom Trends';

  @override
  String get homeAIHealthCoach => 'AI Health Coach';

  @override
  String homeInDays(int days) {
    return 'In $days days';
  }

  @override
  String get homeToday => 'Today';

  @override
  String get homeYesterday => 'Yesterday';

  @override
  String get homeRecentCycles => 'Recent Cycles';

  @override
  String get homeViewAll => 'View All';

  @override
  String get homeStartTracking => 'Start Tracking Your Cycle';

  @override
  String get homeStartTrackingDescription =>
      'Log your first cycle to see personalized insights and predictions.';

  @override
  String get homeLogFirstCycle => 'Log First Cycle';

  @override
  String get homeUnableToLoad => 'Unable to load recent cycles';

  @override
  String get homeTryAgain => 'Try Again';

  @override
  String get homeNoCycles => 'No cycles logged yet. Start tracking!';

  @override
  String get dailyLogTitle => 'Daily Log';

  @override
  String get logToday => 'Log Today';

  @override
  String get history => 'History';

  @override
  String get selectedDate => 'Selected Date';

  @override
  String get quickLogTemplates => 'Quick Log Templates';

  @override
  String get greatDay => 'Great Day';

  @override
  String get goodDay => 'Good Day';

  @override
  String get okayDay => 'Okay Day';

  @override
  String get toughDay => 'Tough Day';

  @override
  String get periodDay => 'Period Day';

  @override
  String get pms => 'PMS';

  @override
  String get mood => 'Mood';

  @override
  String get energy => 'Energy';

  @override
  String get painLevel => 'Pain Level';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get saveDailyLog => 'Save Daily Log';

  @override
  String get loggingFor => 'Logging for';

  @override
  String get change => 'Change';

  @override
  String get moodLevel => 'Mood Level';

  @override
  String get energyLevel => 'Energy Level';

  @override
  String get stressLevel => 'Stress Level';

  @override
  String get sleepQuality => 'Sleep Quality';

  @override
  String get waterIntake => 'Water Intake';

  @override
  String get exercise => 'Exercise';

  @override
  String get symptomsToday => 'Symptoms Today';

  @override
  String get dailyNotes => 'Daily Notes';

  @override
  String get wellbeing => 'Wellbeing';

  @override
  String get lifestyle => 'Lifestyle';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get aiPredictions => 'AI Predictions';

  @override
  String get personalInsights => 'Personal Insights';

  @override
  String get nextPeriod => 'Next Period';

  @override
  String get ovulation => 'Ovulation';

  @override
  String get cycleRegularity => 'Cycle Regularity';

  @override
  String get confidence => 'confidence';

  @override
  String get glasses => 'glasses';

  @override
  String get minutes => 'minutes';

  @override
  String get dailyGoalAchieved => '🎉 Daily goal achieved!';

  @override
  String minToReachDailyGoal(int minutes) {
    return '$minutes min to reach daily goal';
  }

  @override
  String get tapSymptomsExperienced =>
      'Tap any symptoms you experienced today:';

  @override
  String symptomSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count symptoms selected',
      one: '1 symptom selected',
    );
    return '$_temp0';
  }

  @override
  String get howFeelingToday =>
      'How are you feeling today? Any thoughts or observations?';

  @override
  String get feelingGreatToday =>
      'e.g., Feeling great today, had a good workout...';

  @override
  String get generatingAIInsights => 'Generating AI insights...';

  @override
  String get noInsightsYet => 'No insights yet';

  @override
  String get keepTrackingForInsights =>
      'Keep tracking your daily data to get personalized AI insights!';

  @override
  String get smartDailyLog => 'Smart Daily Log';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving...';

  @override
  String dailyLogSavedFor(String date) {
    return 'Daily log saved for $date';
  }

  @override
  String errorSavingDailyLog(String error) {
    return 'Error saving daily log: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get veryLow => 'Very Low';

  @override
  String get low => 'Low';

  @override
  String get neutral => 'Neutral';

  @override
  String get good => 'Good';

  @override
  String get excellent => 'Excellent';

  @override
  String get exhausted => 'Exhausted';

  @override
  String get normal => 'Normal';

  @override
  String get high => 'High';

  @override
  String get energetic => 'Energetic';

  @override
  String get none => 'None';

  @override
  String get mild => 'Mild';

  @override
  String get moderate => 'Moderate';

  @override
  String get severe => 'Severe';

  @override
  String get extreme => 'Extreme';

  @override
  String get veryCalm => 'Very Calm';

  @override
  String get relaxed => 'Relaxed';

  @override
  String get stressed => 'Stressed';

  @override
  String get veryStressed => 'Very Stressed';

  @override
  String get poor => 'Poor';

  @override
  String get fair => 'Fair';

  @override
  String get veryGood => 'Very Good';

  @override
  String get cramps => 'Cramps';

  @override
  String get headache => 'Headache';

  @override
  String get moodSwings => 'Mood Swings';

  @override
  String get fatigue => 'Fatigue';

  @override
  String get bloating => 'Bloating';

  @override
  String get breastTenderness => 'Breast Tenderness';

  @override
  String get nausea => 'Nausea';

  @override
  String get backPain => 'Back Pain';

  @override
  String get acne => 'Acne';

  @override
  String get foodCravings => 'Food Cravings';

  @override
  String get sleepIssues => 'Sleep Issues';

  @override
  String get hotFlashes => 'Hot Flashes';

  @override
  String get noDailyLogsYet => 'No daily logs yet';

  @override
  String get startLoggingDailyMood =>
      'Start logging your daily mood and energy';

  @override
  String failedToLoadLogs(String error) {
    return 'Failed to load logs: $error';
  }

  @override
  String get notes => 'Notes';

  @override
  String get more => 'more';

  @override
  String get dailyLogSaved => 'Daily log saved!';

  @override
  String failedToSaveLog(String error) {
    return 'Failed to save log: $error';
  }

  @override
  String failedToLoadExistingLog(String error) {
    return 'Failed to load existing log: $error';
  }

  @override
  String get howAreYouFeelingToday => 'How are you feeling today?';

  @override
  String get updated => 'Updated';

  @override
  String get okay => 'Okay';

  @override
  String get tools => 'Tools';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get account => 'Account';

  @override
  String get verified => 'Verified';

  @override
  String get healthIntegration => 'Health Integration';

  @override
  String get healthIntegrationDescription =>
      'Sync with HealthKit and Google Fit';

  @override
  String get dataManagementDescription =>
      'Export, import, and backup your data';

  @override
  String get exportBackup => 'Export & Backup';

  @override
  String get exportBackupDescription => 'Generate reports and backup your data';

  @override
  String get socialSharing => 'Social Sharing';

  @override
  String get socialSharingDescription =>
      'Share data with providers and partners';

  @override
  String get syncStatus => 'Sync Status';

  @override
  String get syncStatusDescription => 'Check cloud synchronization';

  @override
  String get about => 'About';

  @override
  String get aboutDescription => 'App version and credits';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutDescription => 'Sign out of your account';

  @override
  String get getHelpUsingCycleSync => 'Get help using CycleSync';

  @override
  String get viewSymptomPatterns => 'View symptom patterns and insights';

  @override
  String get viewAllCycles => 'View all cycles';

  @override
  String get viewCycleInsights => 'View cycle insights';

  @override
  String get testFirebaseConnection => 'Test Firebase connection';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String featureAvailableInFuture(String feature) {
    return '$feature will be available in a future update.';
  }

  @override
  String get ok => 'OK';

  @override
  String get aboutCycleSync => 'About CycleSync';

  @override
  String get cycleSyncVersion => 'CycleSync v1.0.0';

  @override
  String get modernCycleTrackingApp =>
      'A modern cycle tracking app built with Flutter.';

  @override
  String get features => 'Features:';

  @override
  String get cycleLoggingTracking => '• Cycle logging and tracking';

  @override
  String get analyticsInsights => '• Analytics and insights';

  @override
  String get darkModeSupport => '• Dark mode support';

  @override
  String get cloudSynchronization => '• Cloud synchronization';

  @override
  String get privacyFocusedDesign => '• Privacy-focused design';

  @override
  String get areYouSureSignOut => 'Are you sure you want to sign out?';

  @override
  String get firebaseAuthentication => 'Firebase Authentication';

  @override
  String get connected => 'Connected';

  @override
  String get cloudFirestore => 'Cloud Firestore';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Synced $minutes minutes ago';
  }

  @override
  String get healthData => 'Health Data';

  @override
  String get pendingSync => 'Pending sync';

  @override
  String get analyticsData => 'Analytics Data';

  @override
  String get upToDate => 'Up to date';

  @override
  String get totalSyncedRecords => 'Total synced records:';

  @override
  String get lastFullSync => 'Last full sync:';

  @override
  String todayAt(String time) {
    return 'Today at $time';
  }

  @override
  String get storageUsed => 'Storage used:';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get manualSyncCompleted => 'Manual sync completed successfully!';
}
