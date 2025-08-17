// Generated file. Do not edit.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'FlowSense';

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
  String get dailyLogTitle => 'Registro Diario';

  @override
  String get logToday => 'Registrar Hoy';

  @override
  String get history => 'Historial';

  @override
  String get selectedDate => 'Fecha Seleccionada';

  @override
  String get quickLogTemplates => 'Plantillas de Registro Rápido';

  @override
  String get greatDay => 'Gran Día';

  @override
  String get goodDay => 'Buen Día';

  @override
  String get okayDay => 'Día Normal';

  @override
  String get toughDay => 'Día Difícil';

  @override
  String get periodDay => 'Día de Período';

  @override
  String get pms => 'SPM';

  @override
  String get mood => 'Estado de Ánimo';

  @override
  String get energy => 'Energía';

  @override
  String get painLevel => 'Nivel de Dolor';

  @override
  String get notesOptional => 'Notas (opcional)';

  @override
  String get saveDailyLog => 'Guardar Registro Diario';

  @override
  String get loggingFor => 'Registrando para';

  @override
  String get change => 'Cambiar';

  @override
  String get moodLevel => 'Nivel de Ánimo';

  @override
  String get energyLevel => 'Nivel de Energía';

  @override
  String get stressLevel => 'Nivel de Estrés';

  @override
  String get sleepQuality => 'Calidad del Sueño';

  @override
  String get waterIntake => 'Consumo de Agua';

  @override
  String get exercise => 'Ejercicio';

  @override
  String get symptomsToday => 'Síntomas de Hoy';

  @override
  String get dailyNotes => 'Notas Diarias';

  @override
  String get wellbeing => 'Bienestar';

  @override
  String get lifestyle => 'Estilo de Vida';

  @override
  String get symptoms => 'Síntomas';

  @override
  String get aiInsights => 'Perspectivas de IA';

  @override
  String get aiPredictions => 'Predicciones de IA';

  @override
  String get personalInsights => 'Perspectivas Personales';

  @override
  String get nextPeriod => 'Próximo Período';

  @override
  String get ovulation => 'Ovulación';

  @override
  String get cycleRegularity => 'Regularidad del Ciclo';

  @override
  String get confidence => 'confianza';

  @override
  String get glasses => 'vasos';

  @override
  String get minutes => 'minutos';

  @override
  String get dailyGoalAchieved => '🎉 ¡Meta diaria alcanzada!';

  @override
  String minToReachDailyGoal(int minutes) {
    return '$minutes min para alcanzar la meta diaria';
  }

  @override
  String get tapSymptomsExperienced =>
      'Toca cualquier síntoma que hayas experimentado hoy:';

  @override
  String symptomSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count síntomas seleccionados',
      one: '1 síntoma seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get howFeelingToday =>
      '¿Cómo te sientes hoy? ¿Algún pensamiento u observación?';

  @override
  String get feelingGreatToday =>
      'ej., Me siento genial hoy, hice un buen entrenamiento...';

  @override
  String get generatingAIInsights => 'Generando perspectivas de IA...';

  @override
  String get noInsightsYet => 'Aún no hay perspectivas';

  @override
  String get keepTrackingForInsights =>
      '¡Sigue registrando tus datos diarios para obtener perspectivas personalizadas de IA!';

  @override
  String get smartDailyLog => 'Registro Diario Inteligente';

  @override
  String get save => 'Guardar';

  @override
  String get saving => 'Guardando...';

  @override
  String dailyLogSavedFor(String date) {
    return 'Registro diario guardado para $date';
  }

  @override
  String errorSavingDailyLog(String error) {
    return 'Error al guardar el registro diario: $error';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get veryLow => 'Muy Bajo';

  @override
  String get low => 'Bajo';

  @override
  String get neutral => 'Neutral';

  @override
  String get good => 'Bueno';

  @override
  String get excellent => 'Excelente';

  @override
  String get exhausted => 'Agotada';

  @override
  String get normal => 'Normal';

  @override
  String get high => 'Alto';

  @override
  String get energetic => 'Enérgica';

  @override
  String get none => 'Ninguno';

  @override
  String get mild => 'Leve';

  @override
  String get moderate => 'Moderado';

  @override
  String get severe => 'Severo';

  @override
  String get extreme => 'Extremo';

  @override
  String get veryCalm => 'Muy Tranquila';

  @override
  String get relaxed => 'Relajada';

  @override
  String get stressed => 'Estresada';

  @override
  String get veryStressed => 'Muy Estresada';

  @override
  String get poor => 'Pobre';

  @override
  String get fair => 'Regular';

  @override
  String get veryGood => 'Muy Bueno';

  @override
  String get cramps => 'Cólicos';

  @override
  String get headache => 'Dolor de Cabeza';

  @override
  String get moodSwings => 'Cambios de Humor';

  @override
  String get fatigue => 'Fatiga';

  @override
  String get bloating => 'Hinchazón';

  @override
  String get breastTenderness => 'Sensibilidad en los Senos';

  @override
  String get nausea => 'Náuseas';

  @override
  String get backPain => 'Dolor de Espalda';

  @override
  String get acne => 'Acné';

  @override
  String get foodCravings => 'Antojos de Comida';

  @override
  String get sleepIssues => 'Problemas de Sueño';

  @override
  String get hotFlashes => 'Sofocos';

  @override
  String get noDailyLogsYet => 'Aún no hay registros diarios';

  @override
  String get startLoggingDailyMood =>
      'Comienza a registrar tu estado de ánimo y energía diarios';

  @override
  String failedToLoadLogs(String error) {
    return 'Error al cargar registros: $error';
  }

  @override
  String get notes => 'Notas';

  @override
  String get more => 'más';

  @override
  String get dailyLogSaved => '¡Registro diario guardado!';

  @override
  String failedToSaveLog(String error) {
    return 'Error al guardar registro: $error';
  }

  @override
  String failedToLoadExistingLog(String error) {
    return 'Error al cargar registro existente: $error';
  }

  @override
  String get howAreYouFeelingToday => '¿Cómo te sientes hoy?';

  @override
  String get updated => 'Actualizado';

  @override
  String get okay => 'Bien';

  @override
  String get tools => 'Herramientas';

  @override
  String get dataManagement => 'Gestión de Datos';

  @override
  String get account => 'Cuenta';

  @override
  String get verified => 'Verificado';

  @override
  String get healthIntegration => 'Integración de Salud';

  @override
  String get healthIntegrationDescription =>
      'Sincronizar con HealthKit y Google Fit';

  @override
  String get dataManagementDescription =>
      'Exportar, importar y respaldar tus datos';

  @override
  String get exportBackup => 'Exportar y Respaldar';

  @override
  String get exportBackupDescription =>
      'Generar reportes y respaldar tus datos';

  @override
  String get socialSharing => 'Compartir Social';

  @override
  String get socialSharingDescription =>
      'Compartir datos con proveedores y socios';

  @override
  String get syncStatus => 'Estado de Sincronización';

  @override
  String get syncStatusDescription => 'Verificar sincronización en la nube';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutDescription => 'Versión de la app y créditos';

  @override
  String get signOut => 'Cerrar Sesión';

  @override
  String get signOutDescription => 'Cerrar sesión de tu cuenta';

  @override
  String get getHelpUsingCycleSync => 'Obtener ayuda usando CycleSync';

  @override
  String get viewSymptomPatterns => 'Ver patrones de síntomas y perspectivas';

  @override
  String get viewAllCycles => 'Ver todos los ciclos';

  @override
  String get viewCycleInsights => 'Ver perspectivas del ciclo';

  @override
  String get testFirebaseConnection => 'Probar conexión Firebase';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String featureAvailableInFuture(String feature) {
    return '$feature estará disponible en una actualización futura.';
  }

  @override
  String get ok => 'OK';

  @override
  String get aboutCycleSync => 'Acerca de CycleSync';

  @override
  String get cycleSyncVersion => 'CycleSync v1.0.0';

  @override
  String get modernCycleTrackingApp =>
      'Una app moderna de seguimiento del ciclo construida con Flutter.';

  @override
  String get features => 'Características:';

  @override
  String get cycleLoggingTracking => '• Registro y seguimiento del ciclo';

  @override
  String get analyticsInsights => '• Análisis y perspectivas';

  @override
  String get darkModeSupport => '• Soporte de modo oscuro';

  @override
  String get cloudSynchronization => '• Sincronización en la nube';

  @override
  String get privacyFocusedDesign => '• Diseño enfocado en privacidad';

  @override
  String get areYouSureSignOut => '¿Estás segura de que quieres cerrar sesión?';

  @override
  String get firebaseAuthentication => 'Autenticación Firebase';

  @override
  String get connected => 'Conectado';

  @override
  String get cloudFirestore => 'Cloud Firestore';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Sincronizado hace $minutes minutos';
  }

  @override
  String get healthData => 'Datos de Salud';

  @override
  String get pendingSync => 'Sincronización pendiente';

  @override
  String get analyticsData => 'Datos de Análisis';

  @override
  String get upToDate => 'Actualizado';

  @override
  String get totalSyncedRecords => 'Total de registros sincronizados:';

  @override
  String get lastFullSync => 'Última sincronización completa:';

  @override
  String todayAt(String time) {
    return 'Hoy a las $time';
  }

  @override
  String get storageUsed => 'Almacenamiento usado:';

  @override
  String get syncNow => 'Sincronizar Ahora';

  @override
  String get manualSyncCompleted =>
      '¡Sincronización manual completada con éxito!';

  @override
  String get appSubtitle => 'Your Smart Clinical Period Tracker';

  @override
  String get smartTracking => 'Smart Tracking';

  @override
  String get clinicalInsights => 'Clinical Insights';

  @override
  String get personalizedForYou => 'Personalized for you';

  @override
  String get viewAllInsights => 'View All Insights';

  @override
  String get expectedOn => 'Expected on';

  @override
  String get appearance => 'Appearance';

  @override
  String get brandingAI => 'AI & Branding';

  @override
  String get advanced => 'Advanced';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get displaySettings => 'Display Settings';

  @override
  String get compactView => 'Compact View';

  @override
  String get compactViewDescription =>
      'Reduce spacing and use smaller elements';

  @override
  String get appBrandingTitle => 'App Branding';

  @override
  String get appBrandingDescription =>
      'Choose how you want to see the app name and branding';

  @override
  String get flowSenseDescription =>
      'Advanced AI-powered menstrual health insights';

  @override
  String get cycleSyncDescription => 'Simple, reliable cycle tracking';

  @override
  String get custom => 'Custom';

  @override
  String get customBrandingDescription => 'Set your own display name';

  @override
  String get classic => 'Classic';

  @override
  String get personal => 'Personal';

  @override
  String get appConnection => 'App Connection';

  @override
  String get appConnectionDescription =>
      'FlowSense AI and CycleSync share the same data and account, just with different branding and AI features.';

  @override
  String get dataSync =>
      'All your cycle data, settings, and preferences sync automatically between both app versions.';

  @override
  String get aiFeatures => 'AI Features';

  @override
  String get aiFeaturesList =>
      'Enhanced with advanced AI capabilities including cycle prediction, symptom pattern analysis, personalized insights, and health recommendations.';

  @override
  String get getHelpUsing => 'Get help using the app';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get customDisplayName => 'Custom Display Name';

  @override
  String get customDisplayNameDescription =>
      'Enter a custom name for the app display:';

  @override
  String get enterCustomName => 'Enter custom name';

  @override
  String get cancel => 'Cancel';

  @override
  String aboutTitle(String appName) {
    return 'About $appName';
  }

  @override
  String get appDescription =>
      'A modern cycle tracking app built with Flutter.';

  @override
  String get featureCycleTracking => 'Cycle logging and tracking';

  @override
  String get featureAnalytics => 'Analytics and insights';

  @override
  String get featureAI => 'AI-powered predictions';

  @override
  String get featureSmartInsights => 'Smart health insights';

  @override
  String get featureDarkMode => 'Dark mode support';

  @override
  String get featureCloudSync => 'Cloud synchronization';

  @override
  String get featurePrivacy => 'Privacy-focused design';

  @override
  String get close => 'Close';
}
