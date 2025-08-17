// Generated file. Do not edit.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'CycleSync';

  @override
  String get bottomNavHome => 'Inicio';

  @override
  String get bottomNavCycle => 'Ciclo';

  @override
  String get bottomNavHealth => 'Salud';

  @override
  String get bottomNavSettings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Elige tu idioma preferido';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsPrivacy => 'Privacidad y Seguridad';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsHelp => 'Ayuda y Soporte';

  @override
  String get languageSelectorTitle => 'Elegir Idioma';

  @override
  String get languageSelectorSubtitle => 'Accesibilidad global para todos';

  @override
  String get languageSelectorSearch => 'Buscar idiomas...';

  @override
  String languageSelectorResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count idiomas encontrados',
      one: '1 idioma encontrado',
      zero: 'No se encontraron idiomas',
    );
    return '$_temp0';
  }

  @override
  String get cycleTitle => 'Seguimiento del Ciclo';

  @override
  String get cycleCurrentPhase => 'Fase Actual';

  @override
  String get cycleNextPeriod => 'Próxima Menstruación';

  @override
  String cycleDaysLeft(int days) {
    return '$days días restantes';
  }

  @override
  String get healthTitle => 'Información de Salud';

  @override
  String get healthSymptoms => 'Síntomas';

  @override
  String get healthMood => 'Estado de Ánimo';

  @override
  String get healthEnergy => 'Nivel de Energía';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profilePersonalInfo => 'Información Personal';

  @override
  String get profileCycleHistory => 'Historial de Ciclos';

  @override
  String get profileDataExport => 'Exportar Datos';

  @override
  String get helpTitle => 'Ayuda y Soporte';

  @override
  String get helpFaq => 'Preguntas Frecuentes';

  @override
  String get helpContactSupport => 'Contactar Soporte';

  @override
  String get helpUserGuide => 'Guía de Usuario';

  @override
  String get helpPrivacyPolicy => 'Política de Privacidad';

  @override
  String get helpReportIssue => 'Reportar Problema';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonNext => 'Siguiente';

  @override
  String get commonDone => 'Hecho';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Éxito';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get todayTitle => 'Hoy';

  @override
  String get yesterdayTitle => 'Ayer';

  @override
  String get tomorrowTitle => 'Mañana';

  @override
  String get phaseFollicular => 'Fase Folicular';

  @override
  String get phaseOvulation => 'Ovulación';

  @override
  String get phaseLuteal => 'Fase Lútea';

  @override
  String get phaseMenstruation => 'Menstruación';

  @override
  String get symptomCramps => 'Cólicos';

  @override
  String get symptomHeadache => 'Dolor de Cabeza';

  @override
  String get symptomBackache => 'Dolor de Espalda';

  @override
  String get symptomBloating => 'Hinchazón';

  @override
  String get symptomFatigue => 'Fatiga';

  @override
  String get moodHappy => 'Feliz';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodAnxious => 'Ansiosa';

  @override
  String get moodIrritated => 'Irritada';

  @override
  String get moodCalm => 'Tranquila';

  @override
  String get energyHigh => 'Energía Alta';

  @override
  String get energyMedium => 'Energía Media';

  @override
  String get energyLow => 'Energía Baja';

  @override
  String get notificationTitle => 'Notificación de CycleSync';

  @override
  String get notificationPeriodReminder => 'Tu período debería comenzar pronto';

  @override
  String get notificationOvulationReminder =>
      'Te estás acercando a tu ventana fértil';

  @override
  String get accessibilityMenuButton => 'Botón de menú';

  @override
  String get accessibilityCalendar => 'Vista de calendario';

  @override
  String get accessibilitySettingsButton => 'Botón de configuración';

  @override
  String get homeTitle => 'CycleSync';

  @override
  String homeWelcomeMessage(String name) {
    return '¡Hola, $name!';
  }

  @override
  String get homeWelcomeSubtitle => 'Rastrea tu ciclo con confianza';

  @override
  String get homeMenstrualPhase => 'Fase Menstrual';

  @override
  String homeCycleDayInfo(int day) {
    return 'Día $day de tu ciclo';
  }

  @override
  String get homeUpcomingEvents => 'Próximos Eventos';

  @override
  String get homeNextPeriod => 'Próxima Menstruación';

  @override
  String get homeOvulation => 'Ovulación';

  @override
  String get homeFertileWindow => 'Ventana Fértil';

  @override
  String get homeQuickActions => 'Acciones Rápidas';

  @override
  String get homeLogCycle => 'Registrar Ciclo';

  @override
  String get homeViewHistory => 'Ver Historial';

  @override
  String get homeCalendar => 'Calendario';

  @override
  String get homeAnalytics => 'Análisis';

  @override
  String get homeAIInsights => 'Perspectivas de IA';

  @override
  String get homeDailyLog => 'Registro Diario';

  @override
  String get homeTomorrow => 'Mañana';

  @override
  String homeDaysAgo(int days) {
    return 'Hace $days días';
  }

  @override
  String get appearanceTitle => 'Apariencia';

  @override
  String get lightMode => 'Modo Claro';

  @override
  String get lightModeDescription => 'Usar tema claro';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get darkModeDescription => 'Usar tema oscuro';

  @override
  String get systemDefault => 'Predeterminado del Sistema';

  @override
  String get systemDefaultDescription => 'Seguir configuración del sistema';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSubtitle => 'Español • 36 idiomas disponibles';

  @override
  String get swahiliLanguage => 'Kiswahili';

  @override
  String get toolsTitle => 'Herramientas';

  @override
  String get notificationsManage =>
      'Gestionar recordatorios del ciclo y alertas';

  @override
  String get smartNotifications => 'Notificaciones Inteligentes';

  @override
  String get smartNotificationsDescription =>
      'Perspectivas y predicciones basadas en IA';

  @override
  String get diagnosticsTitle => 'Diagnósticos';

  @override
  String get diagnosticsDescription => 'Probar conexión Firebase';

  @override
  String get userTitle => 'Usuario';

  @override
  String get homeHealthInsights => 'Perspectivas de Salud';

  @override
  String get homeSymptomTrends => 'Tendencias de Síntomas';

  @override
  String get homeAIHealthCoach => 'Entrenador de Salud IA';

  @override
  String homeInDays(int days) {
    return 'En $days días';
  }

  @override
  String get homeToday => 'Hoy';

  @override
  String get homeYesterday => 'Ayer';

  @override
  String get homeRecentCycles => 'Ciclos Recientes';

  @override
  String get homeViewAll => 'Ver Todo';

  @override
  String get homeStartTracking => 'Comenzar a Rastrear Tu Ciclo';

  @override
  String get homeStartTrackingDescription =>
      'Registra tu primer ciclo para ver perspectivas y predicciones personalizadas.';

  @override
  String get homeLogFirstCycle => 'Registrar Primer Ciclo';

  @override
  String get homeUnableToLoad => 'No se puede cargar los ciclos recientes';

  @override
  String get homeTryAgain => 'Intentar de Nuevo';

  @override
  String get homeNoCycles =>
      'Aún no hay ciclos registrados. ¡Comienza a rastrear!';

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
