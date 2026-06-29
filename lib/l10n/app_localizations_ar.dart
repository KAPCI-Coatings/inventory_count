// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get devId => 'رقم الجهاز';

  @override
  String get inventory => 'الجرد';

  @override
  String get asset => 'الأصول';

  @override
  String get rowMaterial => 'المواد الخام';

  @override
  String get submit => 'إرسال';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get french => 'الفرنسية';

  @override
  String get settingsSavedSuccessfully => 'تم حفظ الإعدادات بنجاح';

  @override
  String get assetsTitle => 'الأصول';

  @override
  String get assetNo => 'رقم الأصل';

  @override
  String get assetCount => 'عدد الأصول';

  @override
  String get exit => 'خروج';

  @override
  String get search => 'بحث';

  @override
  String get material => 'المادة';

  @override
  String get filterPatch => 'تصفية الباتش';

  @override
  String get selectedPatch => 'الباتش المحدد';

  @override
  String get qty => 'الكمية';

  @override
  String get patch => 'الباتش';

  @override
  String get totalQty => 'إجمالي الكمية';

  @override
  String get clear => 'مسح';

  @override
  String get error => 'خطأ';

  @override
  String get close => 'إغلاق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get errorInitialization => 'خطأ في التهيئة';

  @override
  String get errorEmptyPassword => 'يرجى إدخال كلمة المرور.';

  @override
  String get errorInvalidCredentials => 'بيانات الدخول غير صحيحة.';

  @override
  String get errorLoginFailed => 'فشل تسجيل الدخول.';

  @override
  String get errorPasswordUpdateFailed =>
      'فشل تحديث كلمة المرور. يلزم صلاحية الأدمن.';

  @override
  String get successPasswordUpdated => 'تم تحديث كلمة المرور بنجاح.';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get inventoryCount => 'جرد المخزون';

  @override
  String get confirm_duplicate_pallet =>
      'هل أنت متأكد أنك تريد تكرار هذا الباليت؟';

  @override
  String get error_duplicate_barcode => 'هذا الباركود مكرر داخل نفس الأوردر.';

  @override
  String get error_invalid_barcode_format =>
      'باركود غير صحيح. يجب أن يكون 20 أو 21 حرف بالضبط.';

  @override
  String get error_unexpected_scan => 'حدث خطأ غير متوقع أثناء معالجة القراءة.';

  @override
  String get error_scan_failed => 'حدث خطأ أثناء قراءة الباركود.';

  @override
  String get error_scanner_init => 'تعذر تهيئة الماسح. تأكد من الإعدادات.';

  @override
  String get error_no_scanned_data => 'لا توجد بيانات ممسوحة للإرسال.';

  @override
  String get success_post_clear_cache => 'تم الإرسال بنجاح وتم مسح الكاش.';

  @override
  String get error_scanner_restart => 'تعذر إعادة تشغيل الماسح.';

  @override
  String get success_scanner_stopped => 'تم إيقاف الماسح.';

  @override
  String get error_scanner_status_change => 'تعذر تغيير حالة الماسح.';

  @override
  String get error_profile_empty => 'اسم البروفايل لا يمكن أن يكون فارغا.';

  @override
  String get success_profile_changed => 'تم تغيير البروفايل بنجاح.';

  @override
  String get error_profile_change_failed => 'تعذر تغيير البروفايل.';

  @override
  String get error_invalid_url =>
      'الرابط غير صحيح. مثال: http://10.10.30.47:2604';

  @override
  String get error_invalid_device_id => 'رقم الجهاز غير صحيح.';

  @override
  String get error_confirm_save_settings =>
      'تعذر تأكيد حفظ إعدادات الإرسال.';

  @override
  String success_save_settings(String url) {
    return 'تم حفظ إعدادات الإرسال بنجاح.\n$url';
  }

  @override
  String get error_save_settings => 'تعذر حفظ الإعدادات.';

  @override
  String get error_post_no_connection =>
      'فشل الإرسال. لا يوجد اتصال بالخادم. تأكد من نفس الشبكة والرابط.';

  @override
  String error_post_server_connection(String details) {
    return 'فشل الإرسال. تعذر الاتصال بالخادم. $details';
  }

  @override
  String get error_post_http_not_allowed =>
      'فشل الإرسال. اتصال HTTP غير مسموح على الجهاز.';

  @override
  String error_post_server_code(String code) {
    return 'فشل الإرسال. الخادم أرجع كود $code.';
  }

  @override
  String error_post_unknown(String details) {
    return 'فشل الإرسال. سبب الخطأ: $details';
  }

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get ok => 'موافق';
}
