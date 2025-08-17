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
  String get helpUserGuide => 'Guide de l\'Utilisateur';

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
  String get symptomHeadache => 'Maux de Tête';

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
  String get accessibilityMenuButton => 'Bouton de menu';

  @override
  String get accessibilityCalendar => 'Vue calendrier';

  @override
  String get accessibilitySettingsButton => 'Bouton de paramètres';

  @override
  String get homeTitle => 'CycleSync';

  @override
  String homeWelcomeMessage(String name) {
    return 'Bonjour, $name !';
  }

  @override
  String get homeWelcomeSubtitle => 'Suivez votre cycle en toute confiance';

  @override
  String get homeMenstrualPhase => 'Phase Menstruelle';

  @override
  String homeCycleDayInfo(int day) {
    return 'Jour $day de votre cycle';
  }

  @override
  String get homeUpcomingEvents => 'Événements à Venir';

  @override
  String get homeNextPeriod => 'Prochaines Règles';

  @override
  String get homeOvulation => 'Ovulation';

  @override
  String get homeFertileWindow => 'Fenêtre Fertile';

  @override
  String get homeQuickActions => 'Actions Rapides';

  @override
  String get homeLogCycle => 'Enregistrer le Cycle';

  @override
  String get homeViewHistory => 'Voir l\'Historique';

  @override
  String get homeCalendar => 'Calendrier';

  @override
  String get homeAnalytics => 'Analyses';

  @override
  String get homeAIInsights => 'Insights IA';

  @override
  String get homeDailyLog => 'Journal Quotidien';

  @override
  String get homeTomorrow => 'Demain';

  @override
  String homeDaysAgo(int days) {
    return 'Il y a $days jours';
  }

  @override
  String get appearanceTitle => 'Apparence';

  @override
  String get lightMode => 'Mode Clair';

  @override
  String get lightModeDescription => 'Utiliser le thème clair';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get darkModeDescription => 'Utiliser le thème sombre';

  @override
  String get systemDefault => 'Par Défaut du Système';

  @override
  String get systemDefaultDescription => 'Suivre les paramètres du système';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSubtitle => 'Français • 36 langues disponibles';

  @override
  String get swahiliLanguage => 'Kiswahili';

  @override
  String get toolsTitle => 'Outils';

  @override
  String get notificationsManage => 'Gérer les rappels de cycle et les alertes';

  @override
  String get smartNotifications => 'Notifications Intelligentes';

  @override
  String get smartNotificationsDescription =>
      'Insights et prédictions alimentés par l\'IA';

  @override
  String get diagnosticsTitle => 'Diagnostiques';

  @override
  String get diagnosticsDescription => 'Tester la connexion Firebase';

  @override
  String get userTitle => 'Utilisateur';

  @override
  String get homeHealthInsights => 'Insights Santé';

  @override
  String get homeSymptomTrends => 'Tendances des Symptômes';

  @override
  String get homeAIHealthCoach => 'Coach Santé IA';

  @override
  String homeInDays(int days) {
    return 'Dans $days jours';
  }

  @override
  String get homeToday => 'Aujourd\'hui';

  @override
  String get homeYesterday => 'Hier';

  @override
  String get homeRecentCycles => 'Cycles Récents';

  @override
  String get homeViewAll => 'Voir Tout';

  @override
  String get homeStartTracking => 'Commencer à Suivre Votre Cycle';

  @override
  String get homeStartTrackingDescription =>
      'Enregistrez votre premier cycle pour voir des insights et prédictions personnalisés.';

  @override
  String get homeLogFirstCycle => 'Enregistrer le Premier Cycle';

  @override
  String get homeUnableToLoad => 'Impossible de charger les cycles récents';

  @override
  String get homeTryAgain => 'Réessayer';

  @override
  String get homeNoCycles =>
      'Aucun cycle enregistré pour le moment. Commencez le suivi !';

  @override
  String get dailyLogTitle => 'Journal quotidien';

  @override
  String get logToday => 'Enregistrer aujourd\'hui';

  @override
  String get history => 'Historique';

  @override
  String get selectedDate => 'Date sélectionnée';

  @override
  String get quickLogTemplates => 'Modèles de journal rapide';

  @override
  String get greatDay => 'Excellent jour';

  @override
  String get goodDay => 'Bonne journée';

  @override
  String get okayDay => 'Journée normale';

  @override
  String get toughDay => 'Journée difficile';

  @override
  String get periodDay => 'Jour de règles';

  @override
  String get pms => 'SPM';

  @override
  String get mood => 'Humeur';

  @override
  String get energy => 'Énergie';

  @override
  String get painLevel => 'Niveau de douleur';

  @override
  String get notesOptional => 'Notes (optionnel)';

  @override
  String get saveDailyLog => 'Enregistrer le journal quotidien';

  @override
  String get loggingFor => 'Enregistrement pour';

  @override
  String get change => 'Modifier';

  @override
  String get moodLevel => 'Niveau d\'humeur';

  @override
  String get energyLevel => 'Niveau d\'énergie';

  @override
  String get stressLevel => 'Niveau de stress';

  @override
  String get sleepQuality => 'Qualité du sommeil';

  @override
  String get waterIntake => 'Consommation d\'eau';

  @override
  String get exercise => 'Exercice';

  @override
  String get symptomsToday => 'Symptômes d\'aujourd\'hui';

  @override
  String get dailyNotes => 'Notes quotidiennes';

  @override
  String get wellbeing => 'Bien-être';

  @override
  String get lifestyle => 'Style de vie';

  @override
  String get symptoms => 'Symptômes';

  @override
  String get aiInsights => 'Aperçus IA';

  @override
  String get aiPredictions => 'Prédictions IA';

  @override
  String get personalInsights => 'Aperçus personnels';

  @override
  String get nextPeriod => 'Prochaines règles';

  @override
  String get ovulation => 'Ovulation';

  @override
  String get cycleRegularity => 'Régularité du cycle';

  @override
  String get confidence => 'confiance';

  @override
  String get glasses => 'verres';

  @override
  String get minutes => 'minutes';

  @override
  String get dailyGoalAchieved => '🎉 Objectif quotidien atteint !';

  @override
  String minToReachDailyGoal(int minutes) {
    return '$minutes min pour atteindre l\'objectif quotidien';
  }

  @override
  String get tapSymptomsExperienced =>
      'Appuyez sur tous les symptômes que vous avez ressentis aujourd\'hui :';

  @override
  String symptomSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count symptômes sélectionnés',
      one: '1 symptôme sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get howFeelingToday =>
      'Comment vous sentez-vous aujourd\'hui ? Des pensées ou observations ?';

  @override
  String get feelingGreatToday =>
      'ex., Je me sens super bien aujourd\'hui, j\'ai fait un bon entraînement...';

  @override
  String get generatingAIInsights => 'Génération des aperçus IA...';

  @override
  String get noInsightsYet => 'Aucun aperçu pour l\'instant';

  @override
  String get keepTrackingForInsights =>
      'Continuez à suivre vos données quotidiennes pour obtenir des aperçus IA personnalisés !';

  @override
  String get smartDailyLog => 'Journal quotidien intelligent';

  @override
  String get save => 'Enregistrer';

  @override
  String get saving => 'Enregistrement...';

  @override
  String dailyLogSavedFor(String date) {
    return 'Journal quotidien enregistré pour $date';
  }

  @override
  String errorSavingDailyLog(String error) {
    return 'Erreur lors de l\'enregistrement du journal quotidien : $error';
  }

  @override
  String get retry => 'Réessayer';

  @override
  String get veryLow => 'Très bas';

  @override
  String get low => 'Bas';

  @override
  String get neutral => 'Neutre';

  @override
  String get good => 'Bon';

  @override
  String get excellent => 'Excellent';

  @override
  String get exhausted => 'Épuisé';

  @override
  String get normal => 'Normal';

  @override
  String get high => 'Élevé';

  @override
  String get energetic => 'Énergique';

  @override
  String get none => 'Aucune';

  @override
  String get mild => 'Légère';

  @override
  String get moderate => 'Modérée';

  @override
  String get severe => 'Sévère';

  @override
  String get extreme => 'Extrême';

  @override
  String get veryCalm => 'Très calme';

  @override
  String get relaxed => 'Détendu';

  @override
  String get stressed => 'Stressé';

  @override
  String get veryStressed => 'Très stressé';

  @override
  String get poor => 'Mauvaise';

  @override
  String get fair => 'Correcte';

  @override
  String get veryGood => 'Très bonne';

  @override
  String get cramps => 'Crampes';

  @override
  String get headache => 'Mal de tête';

  @override
  String get moodSwings => 'Sautes d\'humeur';

  @override
  String get fatigue => 'Fatigue';

  @override
  String get bloating => 'Ballonnements';

  @override
  String get breastTenderness => 'Sensibilité des seins';

  @override
  String get nausea => 'Nausée';

  @override
  String get backPain => 'Mal de dos';

  @override
  String get acne => 'Acné';

  @override
  String get foodCravings => 'Envies alimentaires';

  @override
  String get sleepIssues => 'Problèmes de sommeil';

  @override
  String get hotFlashes => 'Bouffées de chaleur';

  @override
  String get noDailyLogsYet => 'Aucun journal quotidien pour l\'instant';

  @override
  String get startLoggingDailyMood =>
      'Commencez à enregistrer votre humeur et énergie quotidiennes';

  @override
  String failedToLoadLogs(String error) {
    return 'Échec du chargement des journaux : $error';
  }

  @override
  String get notes => 'Notes';

  @override
  String get more => 'plus';

  @override
  String get dailyLogSaved => 'Journal quotidien enregistré !';

  @override
  String failedToSaveLog(String error) {
    return 'Échec de l\'enregistrement du journal : $error';
  }

  @override
  String failedToLoadExistingLog(String error) {
    return 'Échec du chargement du journal existant : $error';
  }

  @override
  String get howAreYouFeelingToday => 'Comment vous sentez-vous aujourd\'hui ?';

  @override
  String get updated => 'Mis à jour';

  @override
  String get okay => 'OK';

  @override
  String get tools => 'Outils';

  @override
  String get dataManagement => 'Gestion des données';

  @override
  String get account => 'Compte';

  @override
  String get verified => 'Vérifié';

  @override
  String get healthIntegration => 'Intégration santé';

  @override
  String get healthIntegrationDescription =>
      'Synchroniser avec HealthKit et Google Fit';

  @override
  String get dataManagementDescription =>
      'Exporter, importer et sauvegarder vos données';

  @override
  String get exportBackup => 'Export & Sauvegarde';

  @override
  String get exportBackupDescription =>
      'Générer des rapports et sauvegarder vos données';

  @override
  String get socialSharing => 'Partage social';

  @override
  String get socialSharingDescription =>
      'Partager des données avec les fournisseurs et partenaires';

  @override
  String get syncStatus => 'État de synchronisation';

  @override
  String get syncStatusDescription => 'Vérifier la synchronisation cloud';

  @override
  String get about => 'À propos';

  @override
  String get aboutDescription => 'Version de l\'app et crédits';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutDescription => 'Se déconnecter de votre compte';

  @override
  String get getHelpUsingCycleSync =>
      'Obtenir de l\'aide pour utiliser CycleSync';

  @override
  String get viewSymptomPatterns => 'Voir les modèles de symptômes et aperçus';

  @override
  String get viewAllCycles => 'Voir tous les cycles';

  @override
  String get viewCycleInsights => 'Voir les aperçus du cycle';

  @override
  String get testFirebaseConnection => 'Tester la connexion Firebase';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String featureAvailableInFuture(String feature) {
    return '$feature sera disponible dans une mise à jour future.';
  }

  @override
  String get ok => 'OK';

  @override
  String get aboutCycleSync => 'À propos de CycleSync';

  @override
  String get cycleSyncVersion => 'CycleSync v1.0.0';

  @override
  String get modernCycleTrackingApp =>
      'Une app moderne de suivi des cycles construite avec Flutter.';

  @override
  String get features => 'Fonctionnalités :';

  @override
  String get cycleLoggingTracking => '• Enregistrement et suivi des cycles';

  @override
  String get analyticsInsights => '• Analyses et aperçus';

  @override
  String get darkModeSupport => '• Support du mode sombre';

  @override
  String get cloudSynchronization => '• Synchronisation cloud';

  @override
  String get privacyFocusedDesign => '• Design axé sur la confidentialité';

  @override
  String get areYouSureSignOut => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get firebaseAuthentication => 'Authentification Firebase';

  @override
  String get connected => 'Connecté';

  @override
  String get cloudFirestore => 'Cloud Firestore';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Synchronisé il y a $minutes minutes';
  }

  @override
  String get healthData => 'Données de santé';

  @override
  String get pendingSync => 'Synchronisation en attente';

  @override
  String get analyticsData => 'Données d\'analyse';

  @override
  String get upToDate => 'À jour';

  @override
  String get totalSyncedRecords => 'Total des enregistrements synchronisés :';

  @override
  String get lastFullSync => 'Dernière synchronisation complète :';

  @override
  String todayAt(String time) {
    return 'Aujourd\'hui à $time';
  }

  @override
  String get storageUsed => 'Stockage utilisé :';

  @override
  String get syncNow => 'Synchroniser maintenant';

  @override
  String get manualSyncCompleted =>
      'Synchronisation manuelle terminée avec succès !';

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
