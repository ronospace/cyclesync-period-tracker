// Generated file. Do not edit.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'CycleSync';

  @override
  String get bottomNavHome => 'Accueil';

  @override
  String get bottomNavCycle => 'Cycle';

  @override
  String get bottomNavHealth => 'Santé';

  @override
  String get bottomNavSettings => 'Paramètres';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSubtitle => 'Choisissez votre langue préférée';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPrivacy => 'Confidentialité et Sécurité';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsHelp => 'Aide et Support';

  @override
  String get languageSelectorTitle => 'Choisir la Langue';

  @override
  String get languageSelectorSubtitle => 'Accessibilité mondiale pour tous';

  @override
  String get languageSelectorSearch => 'Rechercher des langues...';

  @override
  String languageSelectorResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count langues trouvées',
      one: '1 langue trouvée',
      zero: 'Aucune langue trouvée',
    );
    return '$_temp0';
  }

  @override
  String get cycleTitle => 'Suivi du Cycle';

  @override
  String get cycleCurrentPhase => 'Phase Actuelle';

  @override
  String get cycleNextPeriod => 'Prochaines Règles';

  @override
  String cycleDaysLeft(int days) {
    return '$days jours restants';
  }

  @override
  String get healthTitle => 'Informations Santé';

  @override
  String get healthSymptoms => 'Symptômes';

  @override
  String get healthMood => 'Humeur';

  @override
  String get healthEnergy => 'Niveau d\'Énergie';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePersonalInfo => 'Informations Personnelles';

  @override
  String get profileCycleHistory => 'Historique des Cycles';

  @override
  String get profileDataExport => 'Exporter les Données';

  @override
  String get helpTitle => 'Aide et Support';

  @override
  String get helpFaq => 'Questions Fréquemment Posées';

  @override
  String get helpContactSupport => 'Contacter le Support';

  @override
  String get helpUserGuide => 'Guide d\'Utilisateur';

  @override
  String get helpPrivacyPolicy => 'Politique de Confidentialité';

  @override
  String get helpReportIssue => 'Signaler un Problème';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonError => 'Erreur';

  @override
  String get commonSuccess => 'Succès';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get todayTitle => 'Aujourd\'hui';

  @override
  String get yesterdayTitle => 'Hier';

  @override
  String get tomorrowTitle => 'Demain';

  @override
  String get phaseFollicular => 'Phase Folliculaire';

  @override
  String get phaseOvulation => 'Ovulation';

  @override
  String get phaseLuteal => 'Phase Lutéale';

  @override
  String get phaseMenstruation => 'Menstruation';

  @override
  String get symptomCramps => 'Crampes';

  @override
  String get symptomHeadache => 'Mal de Tête';

  @override
  String get symptomBackache => 'Mal de Dos';

  @override
  String get symptomBloating => 'Ballonnements';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get moodHappy => 'Heureuse';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodAnxious => 'Anxieuse';

  @override
  String get moodIrritated => 'Irritée';

  @override
  String get moodCalm => 'Calme';

  @override
  String get energyHigh => 'Énergie Élevée';

  @override
  String get energyMedium => 'Énergie Moyenne';

  @override
  String get energyLow => 'Énergie Faible';

  @override
  String get notificationTitle => 'Notification CycleSync';

  @override
  String get notificationPeriodReminder =>
      'Vos règles devraient commencer bientôt';

  @override
  String get notificationOvulationReminder =>
      'Vous approchez de votre fenêtre fertile';

  @override
  String get accessibilityMenuButton => 'Bouton menu';

  @override
  String get accessibilityCalendar => 'Vue calendrier';

  @override
  String get accessibilitySettingsButton => 'Bouton paramètres';
}
