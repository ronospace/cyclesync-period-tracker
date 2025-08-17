// Generated file. Do not edit.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'FlowSense';

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
  String get dailyLogTitle => 'Kumbuka Kila Siku';

  @override
  String get logToday => 'Rekodi Leo';

  @override
  String get history => 'Historia';

  @override
  String get selectedDate => 'Tarehe Iliyochaguliwa';

  @override
  String get quickLogTemplates => 'Vielelezo vya Kurekodia Haraka';

  @override
  String get greatDay => 'Siku Nzuri';

  @override
  String get goodDay => 'Siku ya Kawaida';

  @override
  String get okayDay => 'Siku ya Wastani';

  @override
  String get toughDay => 'Siku Ngumu';

  @override
  String get periodDay => 'Siku ya Hedhi';

  @override
  String get pms => 'Dalili za Kabla ya Hedhi';

  @override
  String get mood => 'Hali ya Akili';

  @override
  String get energy => 'Nguvu';

  @override
  String get painLevel => 'Kiwango cha Maumivu';

  @override
  String get notesOptional => 'Maelezo (si lazima)';

  @override
  String get saveDailyLog => 'Hifadhi Kumbuka ya Kila Siku';

  @override
  String get loggingFor => 'Kurekodi kwa';

  @override
  String get change => 'Badilisha';

  @override
  String get moodLevel => 'Kiwango cha Hali ya Akili';

  @override
  String get energyLevel => 'Kiwango cha Nguvu';

  @override
  String get stressLevel => 'Kiwango cha Msongo wa Mawazo';

  @override
  String get sleepQuality => 'Ubora wa Kulala';

  @override
  String get waterIntake => 'Kunywa Maji';

  @override
  String get exercise => 'Mazoezi';

  @override
  String get symptomsToday => 'Dalili za Leo';

  @override
  String get dailyNotes => 'Maelezo ya Kila Siku';

  @override
  String get wellbeing => 'Ustawi';

  @override
  String get lifestyle => 'Mtindo wa Maisha';

  @override
  String get symptoms => 'Dalili';

  @override
  String get aiInsights => 'Maarifa ya Akili Bandia';

  @override
  String get aiPredictions => 'Utabiri wa Akili Bandia';

  @override
  String get personalInsights => 'Maarifa ya Kibinafsi';

  @override
  String get nextPeriod => 'Hedhi Ijayo';

  @override
  String get ovulation => 'Uzazi';

  @override
  String get cycleRegularity => 'Utaratibu wa Mzunguko';

  @override
  String get confidence => 'imani';

  @override
  String get glasses => 'miwani';

  @override
  String get minutes => 'dakika';

  @override
  String get dailyGoalAchieved => '🎉 Lengo la kila siku limefikiwa!';

  @override
  String minToReachDailyGoal(int minutes) {
    return 'Dakika $minutes kufikia lengo la kila siku';
  }

  @override
  String get tapSymptomsExperienced => 'Gusa dalili yoyote uliyopata leo:';

  @override
  String symptomSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dalili $count zimechaguliwa',
      one: 'Dalili 1 imechaguliwa',
    );
    return '$_temp0';
  }

  @override
  String get howFeelingToday => 'Unahisije leo? Mawazo yoyote au uchunguzi?';

  @override
  String get feelingGreatToday =>
      'mfano, Nahisi vizuri leo, nilifanya mazoezi mazuri...';

  @override
  String get generatingAIInsights => 'Kutengeneza maarifa ya akili bandia...';

  @override
  String get noInsightsYet => 'Hakuna maarifa bado';

  @override
  String get keepTrackingForInsights =>
      'Endelea kufuatilia data yako ya kila siku kupata maarifa ya kibinafsi ya akili bandia!';

  @override
  String get smartDailyLog => 'Kumbuka ya Kila Siku ya Akili';

  @override
  String get save => 'Hifadhi';

  @override
  String get saving => 'Inahifadhi...';

  @override
  String dailyLogSavedFor(String date) {
    return 'Kumbuka ya kila siku imehifadhiwa kwa $date';
  }

  @override
  String errorSavingDailyLog(String error) {
    return 'Hitilafu ya kuhifadhi kumbuka ya kila siku: $error';
  }

  @override
  String get retry => 'Jaribu Tena';

  @override
  String get veryLow => 'Chini Sana';

  @override
  String get low => 'Chini';

  @override
  String get neutral => 'Katikati';

  @override
  String get good => 'Nzuri';

  @override
  String get excellent => 'Bora Zaidi';

  @override
  String get exhausted => 'Umechoka';

  @override
  String get normal => 'Kawaida';

  @override
  String get high => 'Juu';

  @override
  String get energetic => 'Mwenye Nguvu';

  @override
  String get none => 'Hakuna';

  @override
  String get mild => 'Kidogo';

  @override
  String get moderate => 'Wastani';

  @override
  String get severe => 'Kali';

  @override
  String get extreme => 'Kupindukia';

  @override
  String get veryCalm => 'Mtulivu Sana';

  @override
  String get relaxed => 'Mlegavu';

  @override
  String get stressed => 'Mwenye Msongo wa Mawazo';

  @override
  String get veryStressed => 'Mwenye Msongo Mkubwa wa Mawazo';

  @override
  String get poor => 'Mbaya';

  @override
  String get fair => 'Ya Wastani';

  @override
  String get veryGood => 'Nzuri Sana';

  @override
  String get cramps => 'Maumivu ya Tumbo';

  @override
  String get headache => 'Maumivu ya Kichwa';

  @override
  String get moodSwings => 'Mabadiliko ya Hali ya Akili';

  @override
  String get fatigue => 'Uchovu';

  @override
  String get bloating => 'Uvimbe wa Tumbo';

  @override
  String get breastTenderness => 'Uchungu wa Matiti';

  @override
  String get nausea => 'Kichefuchefu';

  @override
  String get backPain => 'Maumivu ya Mgongo';

  @override
  String get acne => 'Vipele';

  @override
  String get foodCravings => 'Hamu ya Chakula';

  @override
  String get sleepIssues => 'Matatizo ya Usingizi';

  @override
  String get hotFlashes => 'Joto la Ghafla';

  @override
  String get noDailyLogsYet => 'Hakuna kumbuka za kila siku bado';

  @override
  String get startLoggingDailyMood =>
      'Anza kurekodi hali yako ya akili na nguvu za kila siku';

  @override
  String failedToLoadLogs(String error) {
    return 'Kushindwa kupakia kumbuka: $error';
  }

  @override
  String get notes => 'Maelezo';

  @override
  String get more => 'zaidi';

  @override
  String get dailyLogSaved => 'Kumbuka ya kila siku imehifadhiwa!';

  @override
  String failedToSaveLog(String error) {
    return 'Kushindwa kuhifadhi kumbuka: $error';
  }

  @override
  String failedToLoadExistingLog(String error) {
    return 'Kushindwa kupakia kumbuka iliyopo: $error';
  }

  @override
  String get howAreYouFeelingToday => 'Unahisije leo?';

  @override
  String get updated => 'Imesasishwa';

  @override
  String get okay => 'Sawa';

  @override
  String get tools => 'Vifaa';

  @override
  String get dataManagement => 'Usimamizi wa Data';

  @override
  String get account => 'Akaunti';

  @override
  String get verified => 'Imethibitishwa';

  @override
  String get healthIntegration => 'Muunganisho wa Afya';

  @override
  String get healthIntegrationDescription =>
      'Landanisha na HealthKit na Google Fit';

  @override
  String get dataManagementDescription => 'Hamisha, leta na hifadhi data yako';

  @override
  String get exportBackup => 'Hamisha na Hifadhi';

  @override
  String get exportBackupDescription => 'Tengeneza ripoti na hifadhi data yako';

  @override
  String get socialSharing => 'Kushiriki Kijamii';

  @override
  String get socialSharingDescription =>
      'Shiriki data na watoa huduma na washirika';

  @override
  String get syncStatus => 'Hali ya Ulandanisho';

  @override
  String get syncStatusDescription => 'Angalia ulandanisho wa anga';

  @override
  String get about => 'Kuhusu';

  @override
  String get aboutDescription => 'Toleo la programu na mikopo';

  @override
  String get signOut => 'Ondoka';

  @override
  String get signOutDescription => 'Ondoka kwenye akaunti yako';

  @override
  String get getHelpUsingCycleSync => 'Pata msaada wa kutumia CycleSync';

  @override
  String get viewSymptomPatterns => 'Ona mifumo ya dalili na maarifa';

  @override
  String get viewAllCycles => 'Ona mizunguko yote';

  @override
  String get viewCycleInsights => 'Ona maarifa ya mzunguko';

  @override
  String get testFirebaseConnection => 'Pima muunganisho wa Firebase';

  @override
  String get comingSoon => 'Inakuja Hivi Karibuni';

  @override
  String featureAvailableInFuture(String feature) {
    return '$feature itapatikana katika sasatisho la baadaye.';
  }

  @override
  String get ok => 'Sawa';

  @override
  String get aboutCycleSync => 'Kuhusu CycleSync';

  @override
  String get cycleSyncVersion => 'CycleSync toleo 1.0.0';

  @override
  String get modernCycleTrackingApp =>
      'Programu ya kisasa ya kufuatilia mzunguko iliyojengwa kwa Flutter.';

  @override
  String get features => 'Vipengele:';

  @override
  String get cycleLoggingTracking => '• Kurekodi na kufuatilia mzunguko';

  @override
  String get analyticsInsights => '• Uchanganuzi na maarifa';

  @override
  String get darkModeSupport => '• Msaada wa hali ya giza';

  @override
  String get cloudSynchronization => '• Ulandanisho wa anga';

  @override
  String get privacyFocusedDesign => '• Muundo unaozingatia faragha';

  @override
  String get areYouSureSignOut => 'Una uhakika unataka kuondoka?';

  @override
  String get firebaseAuthentication => 'Uthibitisho wa Firebase';

  @override
  String get connected => 'Imeunganishwa';

  @override
  String get cloudFirestore => 'Cloud Firestore';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'Imeladirikishwa dakika $minutes zilizopita';
  }

  @override
  String get healthData => 'Data ya Afya';

  @override
  String get pendingSync => 'Ulandanisho unasubiri';

  @override
  String get analyticsData => 'Data ya Uchanganuzi';

  @override
  String get upToDate => 'Imesasishwa';

  @override
  String get totalSyncedRecords => 'Jumla ya kumbukumbu zilizolandanishwa:';

  @override
  String get lastFullSync => 'Ulandanisho wa mwisho kamili:';

  @override
  String todayAt(String time) {
    return 'Leo saa $time';
  }

  @override
  String get storageUsed => 'Hifadhi iliyotumiwa:';

  @override
  String get syncNow => 'Landanisha Sasa';

  @override
  String get manualSyncCompleted =>
      'Ulandanisho wa mkono umekamilika kwa mafanikio!';

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
