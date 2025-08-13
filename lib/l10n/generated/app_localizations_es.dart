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
}
