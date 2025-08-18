// Generated file. Do not edit.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'CycleSync';

  @override
  String get bottomNavHome => 'Início';

  @override
  String get bottomNavCycle => 'Ciclo';

  @override
  String get bottomNavHealth => 'Saúde';

  @override
  String get bottomNavSettings => 'Configurações';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Escolha o seu idioma preferido';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsPrivacy => 'Privacidade e Segurança';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsHelp => 'Ajuda e Suporte';

  @override
  String get languageSelectorTitle => 'Escolher Idioma';

  @override
  String get languageSelectorSubtitle => 'Acessibilidade global para todos';

  @override
  String get languageSelectorSearch => 'Buscar idiomas...';

  @override
  String languageSelectorResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count idiomas encontrados',
      one: '1 idioma encontrado',
      zero: 'Nenhum idioma encontrado',
    );
    return '$_temp0';
  }

  @override
  String get cycleTitle => 'Acompanhamento do Ciclo';

  @override
  String get cycleCurrentPhase => 'Fase Atual';

  @override
  String get cycleNextPeriod => 'Próximo Período';

  @override
  String cycleDaysLeft(int days) {
    return '$days dias restantes';
  }

  @override
  String get healthTitle => 'Insights de Saúde';

  @override
  String get healthSymptoms => 'Sintomas';

  @override
  String get healthMood => 'Humor';

  @override
  String get healthEnergy => 'Nível de Energia';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profilePersonalInfo => 'Informações Pessoais';

  @override
  String get profileCycleHistory => 'Histórico do Ciclo';

  @override
  String get profileDataExport => 'Exportar Dados';

  @override
  String get helpTitle => 'Ajuda e Suporte';

  @override
  String get helpFaq => 'Perguntas Frequentes';

  @override
  String get helpContactSupport => 'Contactar Suporte';

  @override
  String get helpUserGuide => 'Guia do Utilizador';

  @override
  String get helpPrivacyPolicy => 'Política de Privacidade';

  @override
  String get helpReportIssue => 'Reportar Problema';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonBack => 'Voltar';

  @override
  String get commonNext => 'Seguinte';

  @override
  String get commonDone => 'Concluído';

  @override
  String get commonError => 'Erro';

  @override
  String get commonSuccess => 'Sucesso';

  @override
  String get commonLoading => 'Carregando...';

  @override
  String get todayTitle => 'Hoje';

  @override
  String get yesterdayTitle => 'Ontem';

  @override
  String get tomorrowTitle => 'Amanhã';

  @override
  String get phaseFollicular => 'Fase Folicular';

  @override
  String get phaseOvulation => 'Ovulação';

  @override
  String get phaseLuteal => 'Fase Lútea';

  @override
  String get phaseMenstruation => 'Menstruação';

  @override
  String get symptomCramps => 'Cólicas';

  @override
  String get symptomHeadache => 'Dor de Cabeça';

  @override
  String get symptomBackache => 'Dor nas Costas';

  @override
  String get symptomBloating => 'Inchaço';

  @override
  String get symptomFatigue => 'Fadiga';

  @override
  String get moodHappy => 'Feliz';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodAnxious => 'Ansioso';

  @override
  String get moodIrritated => 'Irritado';

  @override
  String get moodCalm => 'Calmo';

  @override
  String get energyHigh => 'Energia Alta';

  @override
  String get energyMedium => 'Energia Média';

  @override
  String get energyLow => 'Energia Baixa';

  @override
  String get notificationTitle => 'Notificação CycleSync';

  @override
  String get notificationPeriodReminder =>
      'O seu período deve começar em breve';

  @override
  String get notificationOvulationReminder =>
      'Está aproximando-se da sua janela fértil';

  @override
  String get accessibilityMenuButton => 'Botão do menu';

  @override
  String get accessibilityCalendar => 'Vista do calendário';

  @override
  String get accessibilitySettingsButton => 'Botão de configurações';

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
  String get joinCycleSyncCommunity => 'Join the CycleSync community';

  @override
  String get passwordHelp => 'At least 6 characters';

  @override
  String get termsAgreement =>
      'By creating an account, you agree to our Terms of Service and Privacy Policy';
}
