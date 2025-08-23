// Generated file. Do not edit.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'CycleSync';

  @override
  String get bottomNavHome => 'Nyumbani';

  @override
  String get bottomNavCycle => 'Mzunguko';

  @override
  String get bottomNavHealth => 'Afya';

  @override
  String get bottomNavSettings => 'Mipangilio';

  @override
  String get settingsTitle => 'Mipangilio';

  @override
  String get settingsLanguage => 'Lugha';

  @override
  String get settingsLanguageSubtitle => 'Chagua lugha unayopendelea';

  @override
  String get settingsNotifications => 'Arifa';

  @override
  String get settingsPrivacy => 'Faragha na Usalama';

  @override
  String get settingsTheme => 'Mandhari';

  @override
  String get settingsHelp => 'Msaada na Usaidizi';

  @override
  String get languageSelectorTitle => 'Chagua Lugha';

  @override
  String get languageSelectorSubtitle =>
      'Upatikanaji wa kimataifa kwa kila mtu';

  @override
  String get languageSelectorSearch => 'Tafuta lugha...';

  @override
  String languageSelectorResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lugha $count zimepatikana',
      one: 'Lugha 1 imepatikana',
      zero: 'Hakuna lugha zilizopatikana',
    );
    return '$_temp0';
  }

  @override
  String get cycleTitle => 'Ufuatiliaji wa Mzunguko';

  @override
  String get cycleCurrentPhase => 'Hatua ya Sasa';

  @override
  String get cycleNextPeriod => 'Hedhi Ijayo';

  @override
  String cycleDaysLeft(int days) {
    return 'Siku $days zimebaki';
  }

  @override
  String get healthTitle => 'Maarifa ya Afya';

  @override
  String get healthSymptoms => 'Dalili';

  @override
  String get healthMood => 'Hali ya Akili';

  @override
  String get healthEnergy => 'Kiwango cha Nguvu';

  @override
  String get profileTitle => 'Wasifu';

  @override
  String get profilePersonalInfo => 'Maelezo Binafsi';

  @override
  String get profileCycleHistory => 'Historia ya Mzunguko';

  @override
  String get profileDataExport => 'Hamisha Data';

  @override
  String get helpTitle => 'Msaada na Usaidizi';

  @override
  String get helpFaq => 'Maswali Yanayoulizwa Mara Kwa Mara';

  @override
  String get helpContactSupport => 'Wasiliana na Msaada';

  @override
  String get helpUserGuide => 'Mwongozo wa Mtumiaji';

  @override
  String get helpPrivacyPolicy => 'Sera ya Faragha';

  @override
  String get helpReportIssue => 'Ripoti Tatizo';

  @override
  String get commonSave => 'Hifadhi';

  @override
  String get commonCancel => 'Ghairi';

  @override
  String get commonClose => 'Funga';

  @override
  String get commonBack => 'Rudi Nyuma';

  @override
  String get commonNext => 'Ifuatayo';

  @override
  String get commonDone => 'Imemaliza';

  @override
  String get commonError => 'Kosa';

  @override
  String get commonSuccess => 'Mafanikio';

  @override
  String get commonLoading => 'Inapakia...';

  @override
  String get todayTitle => 'Leo';

  @override
  String get yesterdayTitle => 'Jana';

  @override
  String get tomorrowTitle => 'Kesho';

  @override
  String get phaseFollicular => 'Hatua ya Follicular';

  @override
  String get phaseOvulation => 'Uzazi';

  @override
  String get phaseLuteal => 'Hatua ya Luteal';

  @override
  String get phaseMenstruation => 'Hedhi';

  @override
  String get symptomCramps => 'Maumivu ya Tumbo';

  @override
  String get symptomHeadache => 'Maumivu ya Kichwa';

  @override
  String get symptomBackache => 'Maumivu ya Mgongo';

  @override
  String get symptomBloating => 'Uvimbe wa Tumbo';

  @override
  String get symptomFatigue => 'Uchovu';

  @override
  String get moodHappy => 'Furaha';

  @override
  String get moodSad => 'Huzuni';

  @override
  String get moodAnxious => 'Wasiwasi';

  @override
  String get moodIrritated => 'Hasira';

  @override
  String get moodCalm => 'Utulivu';

  @override
  String get energyHigh => 'Nguvu Nyingi';

  @override
  String get energyMedium => 'Nguvu za Kati';

  @override
  String get energyLow => 'Nguvu Kidogo';

  @override
  String get notificationTitle => 'Arifa ya CycleSync';

  @override
  String get notificationPeriodReminder =>
      'Hedhi yako inatarajiwa kuanza hivi karibuni';

  @override
  String get notificationOvulationReminder =>
      'Unakaribia kipindi chako cha uzazi';

  @override
  String get accessibilityMenuButton => 'Kitufe cha menyu';

  @override
  String get accessibilityCalendar => 'Mwonekano wa kalenda';

  @override
  String get accessibilitySettingsButton => 'Kitufe cha mipangilio';

  @override
  String get homeTitle => 'CycleSync';

  @override
  String homeWelcomeMessage(String name) {
    return 'Hujambo, $name!';
  }

  @override
  String get homeWelcomeSubtitle => 'Fuatilia mzunguko wako kwa ujasiri';

  @override
  String get homeMenstrualPhase => 'Hatua ya Hedhi';

  @override
  String homeCycleDayInfo(int day) {
    return 'Siku ya $day ya mzunguko wako';
  }

  @override
  String get homeUpcomingEvents => 'Matukio Yanayokuja';

  @override
  String get homeNextPeriod => 'Hedhi Ijayo';

  @override
  String get homeOvulation => 'Uzazi';

  @override
  String get homeFertileWindow => 'Dirisha la Uzazi';

  @override
  String get homeQuickActions => 'Vitendo vya Haraka';

  @override
  String get homeLogCycle => 'Rekodi Mzunguko';

  @override
  String get homeViewHistory => 'Ona Historia';

  @override
  String get homeCalendar => 'Kalenda';

  @override
  String get homeAnalytics => 'Uchanganuzi';

  @override
  String get homeAIInsights => 'Maarifa ya Akili Bandia';

  @override
  String get homeDailyLog => 'Kumbuka Kila Siku';

  @override
  String get homeTomorrow => 'Kesho';

  @override
  String homeDaysAgo(int days) {
    return 'Siku $days zilizopita';
  }

  @override
  String get appearanceTitle => 'Mwonekano';

  @override
  String get lightMode => 'Hali ya Mwanga';

  @override
  String get lightModeDescription => 'Tumia mandhari ya mwanga';

  @override
  String get darkMode => 'Hali ya Giza';

  @override
  String get darkModeDescription => 'Tumia mandhari ya giza';

  @override
  String get systemDefault => 'Chaguo-msingi la Mfumo';

  @override
  String get systemDefaultDescription => 'Fuata mipangilio ya mfumo';

  @override
  String get languageTitle => 'Lugha';

  @override
  String get languageSubtitle => 'Kiswahili • lugha 36 zinapatikana';

  @override
  String get swahiliLanguage => 'Kiswahili';

  @override
  String get toolsTitle => 'Vifaa';

  @override
  String get notificationsManage =>
      'Dhibiti vikumbusho vya mzunguko na tahadhari';

  @override
  String get smartNotifications => 'Arifa za Busara';

  @override
  String get smartNotificationsDescription =>
      'Maarifa na utabiri unaoendeshwa na akili bandia';

  @override
  String get diagnosticsTitle => 'Uchunguzi';

  @override
  String get diagnosticsDescription => 'Pima unganisho la Firebase';

  @override
  String get userTitle => 'Mtumiaji';

  @override
  String get homeHealthInsights => 'Maarifa ya Afya';

  @override
  String get homeSymptomTrends => 'Mienendo ya Dalili';

  @override
  String get homeAIHealthCoach => 'Mkufunzi wa Afya wa AI';

  @override
  String homeInDays(int days) {
    return 'Baada ya siku $days';
  }

  @override
  String get homeToday => 'Leo';

  @override
  String get homeYesterday => 'Jana';

  @override
  String get homeRecentCycles => 'Mizunguko ya Hivi Karibuni';

  @override
  String get homeViewAll => 'Ona Zote';

  @override
  String get homeStartTracking => 'Anza Kufuatilia Mzunguko Wako';

  @override
  String get homeStartTrackingDescription =>
      'Rekodi mzunguko wako wa kwanza ili kuona maarifa na utabiri wa kibinafsi.';

  @override
  String get homeLogFirstCycle => 'Rekodi Mzunguko wa Kwanza';

  @override
  String get homeUnableToLoad => 'Haiwezi kupakia mizunguko ya hivi karibuni';

  @override
  String get homeTryAgain => 'Jaribu Tena';

  @override
  String get homeNoCycles =>
      'Hakuna mizunguko iliyorekodiwa bado. Anza kufuatilia!';

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
  String get getHelpUsingFlowSense => 'Get help using FlowSense';

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
  String get aboutFlowSense => 'About FlowSense';

  @override
  String get flowSenseVersion => 'FlowSense v1.0.0';

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

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get signInWithApple => 'Continue with Apple';

  @override
  String get tryAsGuest => 'Try as Guest';

  @override
  String get orContinueWithEmail => 'or email';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinFlowSenseCommunity => 'Join the FlowSense community';

  @override
  String get passwordHelp => 'At least 6 characters';

  @override
  String get termsAgreement =>
      'By creating an account, you agree to our Terms of Service and Privacy Policy';
}
