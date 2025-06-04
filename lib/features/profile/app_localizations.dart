import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'language': 'Language',
      'choose_language': 'Choose your language',
      'logout': 'Logout',
      'cancel': 'Cancel',
      'confirm_logout': 'Are you sure you want to logout?',
      'profile': 'Profile',
      'settings': 'Settings',
      'performance': 'Performance',
      'study_plan': 'Study Plan',
      'notifications': 'Notifications',
      'dark_mode': 'Dark Mode',
      'change_appearance': 'Change the appearance of the application',
      'receive_alerts': 'Receive alerts for courses and exams',
      'privacy': 'Privacy',
      'about': 'About',
      'personal_information': 'Personal Information',
      'study_level': 'Study Level',
      'community': 'Community',
      'join_group_chat': 'Join the group chat',
      'view_study_plan': 'View my study plan',
      'track_progress': 'Track your progress',
      'test_knowledge': 'Test your knowledge',
      'collect_badges': 'Collect your badges',
      'discuss_peers': 'Discuss with your peers',
      'academic_progress': 'Academic Progress',
    },
    'fr': {
      'language': 'Langue',
      'choose_language': 'Choisissez votre langue',
      'logout': 'Déconnexion',
      'cancel': 'Annuler',
      'confirm_logout': 'Êtes-vous sûr de vouloir vous déconnecter ?',
      'profile': 'Profil',
      'settings': 'Paramètres',
      'performance': 'Parcours',
      'study_plan': 'Plan d\'étude',
      'notifications': 'Notifications',
      'dark_mode': 'Mode sombre',
      'change_appearance': 'Changer l\'apparence de l\'application',
      'receive_alerts': 'Recevoir des alertes pour les cours et examens',
      'privacy': 'Confidentialité',
      'about': 'À propos',
      'personal_information': 'Informations personnelles',
      'study_level': 'Niveau d\'étude',
      'community': 'Communauté',
      'join_group_chat': 'Rejoindre le chat de groupe',
      'view_study_plan': 'Voir mon plan d\'étude',
      'track_progress': 'Suivez vos progrès',
      'test_knowledge': 'Testez vos connaissances',
      'collect_badges': 'Collectez vos badges',
      'discuss_peers': 'Discutez avec vos pairs',
      'academic_progress': 'Parcours académique',
    },
    'es': {
      'language': 'Idioma',
      'choose_language': 'Elige tu idioma',
      'logout': 'Cerrar sesión',
      'cancel': 'Cancelar',
      'confirm_logout': '¿Estás seguro de que deseas cerrar sesión?',
      'profile': 'Perfil',
      'settings': 'Configuración',
      'performance': 'Rendimiento',
      'study_plan': 'Plan de estudio',
      'notifications': 'Notificaciones',
      'dark_mode': 'Modo oscuro',
      'change_appearance': 'Cambiar la apariencia de la aplicación',
      'receive_alerts': 'Recibir alertas para cursos y exámenes',
      'privacy': 'Privacidad',
      'about': 'Acerca de',
      'personal_information': 'Información personal',
      'study_level': 'Nivel de estudio',
      'community': 'Comunidad',
      'join_group_chat': 'Unirse al chat de grupo',
      'view_study_plan': 'Ver mi plan de estudio',
      'track_progress': 'Sigue tu progreso',
      'test_knowledge': 'Prueba tus conocimientos',
      'collect_badges': 'Colecta tus insignias',
      'discuss_peers': 'Discute con tus compañeros',
      'academic_progress': 'Progreso académico',
    },
    'ar': {
      'language': 'اللغة',
      'choose_language': 'اختر لغتك',
      'logout': 'تسجيل الخروج',
      'cancel': 'إلغاء',
      'confirm_logout': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',
      'performance': 'الأداء',
      'study_plan': 'خطة الدراسة',
      'notifications': 'الإشعارات',
      'dark_mode': 'الوضع الداكن',
      'change_appearance': 'تغيير مظهر التطبيق',
      'receive_alerts': 'تلقي تنبيهات للدورات والامتحانات',
      'privacy': 'الخصوصية',
      'about': 'حول',
      'personal_information': 'المعلومات الشخصية',
      'study_level': 'مستوى الدراسة',
      'community': 'المجتمع',
      'join_group_chat': 'الانضمام إلى الدردشة الجماعية',
      'view_study_plan': 'عرض خطة الدراسة الخاصة بي',
      'track_progress': 'تتبع تقدمك',
      'test_knowledge': 'اختبر معرفتك',
      'collect_badges': 'جمع شاراتك',
      'discuss_peers': 'ناقش مع أقرانك',
      'academic_progress': 'التقدم الأكاديمي',
    },
  };

  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get chooseLanguage => _localizedValues[locale.languageCode]!['choose_language']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get confirmLogout => _localizedValues[locale.languageCode]!['confirm_logout']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get performance => _localizedValues[locale.languageCode]!['performance']!;
  String get studyPlan => _localizedValues[locale.languageCode]!['study_plan']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get darkMode => _localizedValues[locale.languageCode]!['dark_mode']!;
  String get changeAppearance => _localizedValues[locale.languageCode]!['change_appearance']!;
  String get receiveAlerts => _localizedValues[locale.languageCode]!['receive_alerts']!;
  String get privacy => _localizedValues[locale.languageCode]!['privacy']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get personalInformation => _localizedValues[locale.languageCode]!['personal_information']!;
  String get studyLevel => _localizedValues[locale.languageCode]!['study_level']!;
  String get community => _localizedValues[locale.languageCode]!['community']!;
  String get joinGroupChat => _localizedValues[locale.languageCode]!['join_group_chat']!;
  String get viewStudyPlan => _localizedValues[locale.languageCode]!['view_study_plan']!;
  String get trackProgress => _localizedValues[locale.languageCode]!['track_progress']!;
  String get testKnowledge => _localizedValues[locale.languageCode]!['test_knowledge']!;
  String get collectBadges => _localizedValues[locale.languageCode]!['collect_badges']!;
  String get discussPeers => _localizedValues[locale.languageCode]!['discuss_peers']!;
  String get academicProgress => _localizedValues[locale.languageCode]!['academic_progress']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr', 'es', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}