// Generated file. Do not edit.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'FlowSense';

  @override
  String get bottomNavHome => 'الرئيسية';

  @override
  String get bottomNavCycle => 'الدورة';

  @override
  String get bottomNavHealth => 'الصحة';

  @override
  String get bottomNavSettings => 'الإعدادات';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageSubtitle => 'اختر لغتك المفضلة';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsPrivacy => 'الخصوصية والأمان';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsHelp => 'المساعدة والدعم';

  @override
  String get languageSelectorTitle => 'اختيار اللغة';

  @override
  String get languageSelectorSubtitle => 'إمكانية الوصول العالمي للجميع';

  @override
  String get languageSelectorSearch => 'البحث عن اللغات...';

  @override
  String languageSelectorResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم العثور على $count لغة',
      one: 'تم العثور على لغة واحدة',
      zero: 'لا توجد لغات',
    );
    return '$_temp0';
  }

  @override
  String get cycleTitle => 'تتبع الدورة';

  @override
  String get cycleCurrentPhase => 'المرحلة الحالية';

  @override
  String get cycleNextPeriod => 'الدورة التالية';

  @override
  String cycleDaysLeft(int days) {
    return '$days أيام متبقية';
  }

  @override
  String get healthTitle => 'نصائح صحية';

  @override
  String get healthSymptoms => 'الأعراض';

  @override
  String get healthMood => 'الحالة المزاجية';

  @override
  String get healthEnergy => 'مستوى الطاقة';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profilePersonalInfo => 'المعلومات الشخصية';

  @override
  String get profileCycleHistory => 'تاريخ الدورات';

  @override
  String get profileDataExport => 'تصدير البيانات';

  @override
  String get helpTitle => 'المساعدة والدعم';

  @override
  String get helpFaq => 'الأسئلة الشائعة';

  @override
  String get helpContactSupport => 'التواصل مع الدعم';

  @override
  String get helpUserGuide => 'دليل المستخدم';

  @override
  String get helpPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get helpReportIssue => 'الإبلاغ عن مشكلة';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonDone => 'تم';

  @override
  String get commonError => 'خطأ';

  @override
  String get commonSuccess => 'نجح';

  @override
  String get commonLoading => 'جاري التحميل...';

  @override
  String get todayTitle => 'اليوم';

  @override
  String get yesterdayTitle => 'أمس';

  @override
  String get tomorrowTitle => 'غداً';

  @override
  String get phaseFollicular => 'المرحلة الجريبية';

  @override
  String get phaseOvulation => 'التبويض';

  @override
  String get phaseLuteal => 'المرحلة الصفراء';

  @override
  String get phaseMenstruation => 'الحيض';

  @override
  String get symptomCramps => 'تقلصات';

  @override
  String get symptomHeadache => 'صداع';

  @override
  String get symptomBackache => 'ألم في الظهر';

  @override
  String get symptomBloating => 'انتفاخ';

  @override
  String get symptomFatigue => 'تعب';

  @override
  String get moodHappy => 'سعيدة';

  @override
  String get moodSad => 'حزينة';

  @override
  String get moodAnxious => 'قلقة';

  @override
  String get moodIrritated => 'منزعجة';

  @override
  String get moodCalm => 'هادئة';

  @override
  String get energyHigh => 'طاقة عالية';

  @override
  String get energyMedium => 'طاقة متوسطة';

  @override
  String get energyLow => 'طاقة منخفضة';

  @override
  String get notificationTitle => 'إشعار CycleSync';

  @override
  String get notificationPeriodReminder => 'من المتوقع أن تبدأ دورتك قريباً';

  @override
  String get notificationOvulationReminder => 'أنت تقتربين من فترة الخصوبة';

  @override
  String get accessibilityMenuButton => 'زر القائمة';

  @override
  String get accessibilityCalendar => 'عرض التقويم';

  @override
  String get accessibilitySettingsButton => 'زر الإعدادات';

  @override
  String get homeTitle => 'CycleSync';

  @override
  String homeWelcomeMessage(String name) {
    return 'مرحباً، $name!';
  }

  @override
  String get homeWelcomeSubtitle => 'تتبعي دورتك بثقة';

  @override
  String get homeMenstrualPhase => 'مرحلة الحيض';

  @override
  String homeCycleDayInfo(int day) {
    return 'اليوم $day من دورتك';
  }

  @override
  String get homeUpcomingEvents => 'الأحداث القادمة';

  @override
  String get homeNextPeriod => 'الدورة التالية';

  @override
  String get homeOvulation => 'التبويض';

  @override
  String get homeFertileWindow => 'نافذة الخصوبة';

  @override
  String get homeQuickActions => 'إجراءات سريعة';

  @override
  String get homeLogCycle => 'تسجيل الدورة';

  @override
  String get homeViewHistory => 'عرض التاريخ';

  @override
  String get homeCalendar => 'التقويم';

  @override
  String get homeAnalytics => 'التحليلات';

  @override
  String get homeAIInsights => 'رؤى الذكاء الاصطناعي';

  @override
  String get homeDailyLog => 'السجل اليومي';

  @override
  String get homeTomorrow => 'غداً';

  @override
  String homeDaysAgo(int days) {
    return 'منذ $days أيام';
  }

  @override
  String get appearanceTitle => 'المظهر';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get lightModeDescription => 'استخدام المظهر الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get darkModeDescription => 'استخدام المظهر الداكن';

  @override
  String get systemDefault => 'افتراضي النظام';

  @override
  String get systemDefaultDescription => 'اتباع إعدادات النظام';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get languageSubtitle => 'العربية • 36 لغة متاحة';

  @override
  String get swahiliLanguage => 'السواحيلية';

  @override
  String get toolsTitle => 'الأدوات';

  @override
  String get notificationsManage => 'إدارة تذكيرات الدورة والتنبيهات';

  @override
  String get smartNotifications => 'الإشعارات الذكية';

  @override
  String get smartNotificationsDescription =>
      'رؤى وتوقعات مدعومة بالذكاء الاصطناعي';

  @override
  String get diagnosticsTitle => 'التشخيص';

  @override
  String get diagnosticsDescription => 'اختبار اتصال Firebase';

  @override
  String get userTitle => 'المستخدم';

  @override
  String get homeHealthInsights => 'رؤى صحية';

  @override
  String get homeSymptomTrends => 'اتجاهات الأعراض';

  @override
  String get homeAIHealthCoach => 'مدرب الصحة الذكي';

  @override
  String homeInDays(int days) {
    return 'خلال $days أيام';
  }

  @override
  String get homeToday => 'اليوم';

  @override
  String get homeYesterday => 'أمس';

  @override
  String get homeRecentCycles => 'الدورات الأخيرة';

  @override
  String get homeViewAll => 'عرض الكل';

  @override
  String get homeStartTracking => 'ابدئي تتبع دورتك';

  @override
  String get homeStartTrackingDescription =>
      'سجلي دورتك الأولى لرؤية رؤى وتوقعات شخصية.';

  @override
  String get homeLogFirstCycle => 'تسجيل الدورة الأولى';

  @override
  String get homeUnableToLoad => 'لا يمكن تحميل الدورات الأخيرة';

  @override
  String get homeTryAgain => 'حاولي مرة أخرى';

  @override
  String get homeNoCycles => 'لا توجد دورات مسجلة بعد. ابدئي التتبع!';

  @override
  String get dailyLogTitle => 'السجل اليومي';

  @override
  String get logToday => 'سجل اليوم';

  @override
  String get history => 'التاريخ';

  @override
  String get selectedDate => 'التاريخ المحدد';

  @override
  String get quickLogTemplates => 'قوالب سريعة للتسجيل';

  @override
  String get greatDay => 'يوم رائع';

  @override
  String get goodDay => 'يوم جيد';

  @override
  String get okayDay => 'يوم عادي';

  @override
  String get toughDay => 'يوم صعب';

  @override
  String get periodDay => 'يوم الدورة';

  @override
  String get pms => 'متلازمة ما قبل الحيض';

  @override
  String get mood => 'المزاج';

  @override
  String get energy => 'الطاقة';

  @override
  String get painLevel => 'مستوى الألم';

  @override
  String get notesOptional => 'ملاحظات (اختيارية)';

  @override
  String get saveDailyLog => 'حفظ السجل اليومي';

  @override
  String get loggingFor => 'تسجيل لـ';

  @override
  String get change => 'تغيير';

  @override
  String get moodLevel => 'مستوى المزاج';

  @override
  String get energyLevel => 'مستوى الطاقة';

  @override
  String get stressLevel => 'مستوى التوتر';

  @override
  String get sleepQuality => 'جودة النوم';

  @override
  String get waterIntake => 'كمية الماء';

  @override
  String get exercise => 'التمارين';

  @override
  String get symptomsToday => 'أعراض اليوم';

  @override
  String get dailyNotes => 'ملاحظات يومية';

  @override
  String get wellbeing => 'الرفاهية';

  @override
  String get lifestyle => 'نمط الحياة';

  @override
  String get symptoms => 'الأعراض';

  @override
  String get aiInsights => 'رؤى الذكاء الاصطناعي';

  @override
  String get aiPredictions => 'توقعات الذكاء الاصطناعي';

  @override
  String get personalInsights => 'رؤى شخصية';

  @override
  String get nextPeriod => 'الدورة التالية';

  @override
  String get ovulation => 'التبويض';

  @override
  String get cycleRegularity => 'انتظام الدورة';

  @override
  String get confidence => 'ثقة';

  @override
  String get glasses => 'أكواب';

  @override
  String get minutes => 'دقائق';

  @override
  String get dailyGoalAchieved => '🎉 تم تحقيق الهدف اليومي!';

  @override
  String minToReachDailyGoal(int minutes) {
    return '$minutes دقيقة للوصول للهدف اليومي';
  }

  @override
  String get tapSymptomsExperienced => 'انقري على الأعراض التي واجهتها اليوم:';

  @override
  String symptomSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أعراض محددة',
      one: 'عرض واحد محدد',
    );
    return '$_temp0';
  }

  @override
  String get howFeelingToday => 'كيف تشعرين اليوم؟ أي أفكار أو ملاحظات؟';

  @override
  String get feelingGreatToday =>
      'مثال، أشعر بالرائع اليوم، مارست تمريناً جيداً...';

  @override
  String get generatingAIInsights => 'جاري توليد رؤى الذكاء الاصطناعي...';

  @override
  String get noInsightsYet => 'لا توجد رؤى بعد';

  @override
  String get keepTrackingForInsights =>
      'استمري في تتبع بياناتك اليومية للحصول على رؤى مخصصة من الذكاء الاصطناعي!';

  @override
  String get smartDailyLog => 'السجل اليومي الذكي';

  @override
  String get save => 'حفظ';

  @override
  String get saving => 'جاري الحفظ...';

  @override
  String dailyLogSavedFor(String date) {
    return 'تم حفظ السجل اليومي لـ $date';
  }

  @override
  String errorSavingDailyLog(String error) {
    return 'خطأ في حفظ السجل اليومي: $error';
  }

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get veryLow => 'منخفض جداً';

  @override
  String get low => 'منخفض';

  @override
  String get neutral => 'محايد';

  @override
  String get good => 'جيد';

  @override
  String get excellent => 'ممتاز';

  @override
  String get exhausted => 'مرهقة';

  @override
  String get normal => 'عادي';

  @override
  String get high => 'عالي';

  @override
  String get energetic => 'نشيطة';

  @override
  String get none => 'لا شيء';

  @override
  String get mild => 'خفيف';

  @override
  String get moderate => 'متوسط';

  @override
  String get severe => 'شديد';

  @override
  String get extreme => 'مفرط';

  @override
  String get veryCalm => 'هادئة جداً';

  @override
  String get relaxed => 'مسترخية';

  @override
  String get stressed => 'متوترة';

  @override
  String get veryStressed => 'متوترة جداً';

  @override
  String get poor => 'ضعيف';

  @override
  String get fair => 'مقبول';

  @override
  String get veryGood => 'جيد جداً';

  @override
  String get cramps => 'تقلصات';

  @override
  String get headache => 'صداع';

  @override
  String get moodSwings => 'تقلبات مزاجية';

  @override
  String get fatigue => 'إرهاق';

  @override
  String get bloating => 'انتفاخ';

  @override
  String get breastTenderness => 'حساسية الثدي';

  @override
  String get nausea => 'غثيان';

  @override
  String get backPain => 'ألم الظهر';

  @override
  String get acne => 'حب الشباب';

  @override
  String get foodCravings => 'اشتهاء الطعام';

  @override
  String get sleepIssues => 'مشاكل النوم';

  @override
  String get hotFlashes => 'هبات ساخنة';

  @override
  String get noDailyLogsYet => 'لا توجد سجلات يومية بعد';

  @override
  String get startLoggingDailyMood => 'ابدئي بتسجيل مزاجك وطاقتك اليومية';

  @override
  String failedToLoadLogs(String error) {
    return 'فشل في تحميل السجلات: $error';
  }

  @override
  String get notes => 'ملاحظات';

  @override
  String get more => 'المزيد';

  @override
  String get dailyLogSaved => 'تم حفظ السجل اليومي!';

  @override
  String failedToSaveLog(String error) {
    return 'فشل في حفظ السجل: $error';
  }

  @override
  String failedToLoadExistingLog(String error) {
    return 'فشل في تحميل السجل الموجود: $error';
  }

  @override
  String get howAreYouFeelingToday => 'كيف تشعرين اليوم؟';

  @override
  String get updated => 'محدث';

  @override
  String get okay => 'حسناً';

  @override
  String get tools => 'الأدوات';

  @override
  String get dataManagement => 'إدارة البيانات';

  @override
  String get account => 'الحساب';

  @override
  String get verified => 'موثق';

  @override
  String get healthIntegration => 'التكامل الصحي';

  @override
  String get healthIntegrationDescription =>
      'المزامنة مع HealthKit و Google Fit';

  @override
  String get dataManagementDescription =>
      'تصدير واستيراد ونسخ بياناتك احتياطياً';

  @override
  String get exportBackup => 'تصدير ونسخ احتياطي';

  @override
  String get exportBackupDescription => 'إنشاء تقارير ونسخ بياناتك احتياطياً';

  @override
  String get socialSharing => 'المشاركة الاجتماعية';

  @override
  String get socialSharingDescription =>
      'مشاركة البيانات مع مقدمي الخدمة والشركاء';

  @override
  String get syncStatus => 'حالة المزامنة';

  @override
  String get syncStatusDescription => 'فحص مزامنة السحابة';

  @override
  String get about => 'حول';

  @override
  String get aboutDescription => 'إصدار التطبيق والاعتمادات';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutDescription => 'تسجيل الخروج من حسابك';

  @override
  String get getHelpUsingCycleSync => 'احصلي على المساعدة باستخدام CycleSync';

  @override
  String get viewSymptomPatterns => 'عرض أنماط الأعراض والرؤى';

  @override
  String get viewAllCycles => 'عرض جميع الدورات';

  @override
  String get viewCycleInsights => 'عرض رؤى الدورة';

  @override
  String get testFirebaseConnection => 'اختبار اتصال Firebase';

  @override
  String get comingSoon => 'قريباً';

  @override
  String featureAvailableInFuture(String feature) {
    return '$feature ستكون متاحة في تحديث مستقبلي.';
  }

  @override
  String get ok => 'موافق';

  @override
  String get aboutCycleSync => 'حول CycleSync';

  @override
  String get cycleSyncVersion => 'CycleSync الإصدار 1.0.0';

  @override
  String get modernCycleTrackingApp =>
      'تطبيق حديث لتتبع الدورة الشهرية مبني بـ Flutter.';

  @override
  String get features => 'الميزات:';

  @override
  String get cycleLoggingTracking => '• تسجيل وتتبع الدورة';

  @override
  String get analyticsInsights => '• التحليلات والرؤى';

  @override
  String get darkModeSupport => '• دعم الوضع الداكن';

  @override
  String get cloudSynchronization => '• مزامنة السحابة';

  @override
  String get privacyFocusedDesign => '• تصميم يركز على الخصوصية';

  @override
  String get areYouSureSignOut => 'هل أنت متأكدة من رغبتك في تسجيل الخروج؟';

  @override
  String get firebaseAuthentication => 'مصادقة Firebase';

  @override
  String get connected => 'متصل';

  @override
  String get cloudFirestore => 'Cloud Firestore';

  @override
  String syncedMinutesAgo(int minutes) {
    return 'متزامن منذ $minutes دقيقة';
  }

  @override
  String get healthData => 'البيانات الصحية';

  @override
  String get pendingSync => 'في انتظار المزامنة';

  @override
  String get analyticsData => 'بيانات التحليلات';

  @override
  String get upToDate => 'محدث';

  @override
  String get totalSyncedRecords => 'إجمالي السجلات المتزامنة:';

  @override
  String get lastFullSync => 'آخر مزامنة كاملة:';

  @override
  String todayAt(String time) {
    return 'اليوم في $time';
  }

  @override
  String get storageUsed => 'التخزين المستخدم:';

  @override
  String get syncNow => 'زامن الآن';

  @override
  String get manualSyncCompleted => 'اكتملت المزامنة اليدوية بنجاح!';

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
