// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get scanPallets => 'Pallets';

  @override
  String get addNewPallet => 'اضافه بالته جديده';

  @override
  String get confirmNewPallet => 'هل أنت متأكد من إضافة بالتة جديدة؟';

  @override
  String get emptyPalletNotice =>
      'يجب مسح صندوق واحد على الأقل للبالتة الحالية.';

  @override
  String get currentPalletNumber => 'Current Pallet Number';

  @override
  String get scanBoxes => 'Boxes';

  @override
  String get errorScanPalletsOnly =>
      'تم اختيار البالتات. امسح باركود بالتة أو اختر الصناديق لمسح باركود صندوق.';

  @override
  String get errorScanBoxesOnly =>
      'تم اختيار الصناديق. امسح باركود صندوق أو اختر البالتات لمسح باركود بالتة.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'Language';

  @override
  String get devId => 'Dev_ID';

  @override
  String get inventory => 'Inventory';

  @override
  String get asset => 'Asset';

  @override
  String get rowMaterial => 'Row Material';

  @override
  String get submit => 'إرسال';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get french => 'French';

  @override
  String get settingsSavedSuccessfully => 'تم حفظ الإعدادات بنجاح';

  @override
  String get assetsTitle => 'Assets';

  @override
  String get assetNo => 'Asset No';

  @override
  String get assetCount => 'Asset Count';

  @override
  String get exit => 'خروج';

  @override
  String get search => 'بحث';

  @override
  String get material => 'Matiral';

  @override
  String get filterPatch => 'Filter Patch';

  @override
  String get selectedPatch => 'Selected Patch';

  @override
  String get qty => 'Qty';

  @override
  String get patch => 'Patch';

  @override
  String get totalQty => 'Total Qty';

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
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get inventoryCount => 'Inventory Count';

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

  @override
  String get baseUrl => 'Base URL';

  @override
  String get send => 'إرسال';

  @override
  String get export => 'حفظ كملف';

  @override
  String get post => 'نشر';

  @override
  String get numberOfScan => 'Number of Scan';

  @override
  String get noScannedBarcodesYet => 'No scanned barcodes yet.';

  @override
  String get columnNo => 'No.';

  @override
  String get columnBarcodeFull => 'Barcode Full';

  @override
  String get batchNo => 'Batch No';

  @override
  String get serialNo => 'Serial No';

  @override
  String get palletBox => 'Pallet Box';

  @override
  String get palletBoxCount => 'Pallet Box Count';

  @override
  String get boxCount => 'Box Count';

  @override
  String get palletCount => 'Pallet Count';

  @override
  String get warning => 'تحذير';

  @override
  String get success => 'نجاح';

  @override
  String get confirm_clear_screen =>
      'هل انت متاكد من مسح جميع البيانات من الجهاز';

  @override
  String get confirm_duplicate_barcode => 'هل تريد تكرار هذا الباركود';

  @override
  String get columnSent => 'Sent';
}
