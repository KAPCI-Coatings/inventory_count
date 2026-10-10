import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @scanPallets.
  ///
  /// In en, this message translates to:
  /// **'Pallets'**
  String get scanPallets;

  /// No description provided for @addNewPallet.
  ///
  /// In en, this message translates to:
  /// **'اضافه بالته جديده'**
  String get addNewPallet;

  /// No description provided for @confirmNewPallet.
  ///
  /// In en, this message translates to:
  /// **'هل أنت متأكد من إضافة بالتة جديدة؟'**
  String get confirmNewPallet;

  /// No description provided for @emptyPalletNotice.
  ///
  /// In en, this message translates to:
  /// **'يجب مسح صندوق واحد على الأقل للبالتة الحالية.'**
  String get emptyPalletNotice;

  /// No description provided for @currentPalletNumber.
  ///
  /// In en, this message translates to:
  /// **'Current Pallet Number'**
  String get currentPalletNumber;

  /// No description provided for @scanBoxes.
  ///
  /// In en, this message translates to:
  /// **'Boxes'**
  String get scanBoxes;

  /// No description provided for @errorScanPalletsOnly.
  ///
  /// In en, this message translates to:
  /// **'تم اختيار البالتات. امسح باركود بالتة أو اختر الصناديق لمسح باركود صندوق.'**
  String get errorScanPalletsOnly;

  /// No description provided for @errorScanBoxesOnly.
  ///
  /// In en, this message translates to:
  /// **'تم اختيار الصناديق. امسح باركود صندوق أو اختر البالتات لمسح باركود بالتة.'**
  String get errorScanBoxesOnly;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @devId.
  ///
  /// In en, this message translates to:
  /// **'Dev_ID'**
  String get devId;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @asset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get asset;

  /// No description provided for @rowMaterial.
  ///
  /// In en, this message translates to:
  /// **'Row Material'**
  String get rowMaterial;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'إرسال'**
  String get submit;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @settingsSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'تم حفظ الإعدادات بنجاح'**
  String get settingsSavedSuccessfully;

  /// No description provided for @assetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assetsTitle;

  /// No description provided for @assetNo.
  ///
  /// In en, this message translates to:
  /// **'Asset No'**
  String get assetNo;

  /// No description provided for @assetCount.
  ///
  /// In en, this message translates to:
  /// **'Asset Count'**
  String get assetCount;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'خروج'**
  String get exit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @material.
  ///
  /// In en, this message translates to:
  /// **'Matiral'**
  String get material;

  /// No description provided for @filterPatch.
  ///
  /// In en, this message translates to:
  /// **'Filter Patch'**
  String get filterPatch;

  /// No description provided for @selectedPatch.
  ///
  /// In en, this message translates to:
  /// **'Selected Patch'**
  String get selectedPatch;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @patch.
  ///
  /// In en, this message translates to:
  /// **'Patch'**
  String get patch;

  /// No description provided for @totalQty.
  ///
  /// In en, this message translates to:
  /// **'Total Qty'**
  String get totalQty;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'مسح'**
  String get clear;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'خطأ'**
  String get error;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @errorInitialization.
  ///
  /// In en, this message translates to:
  /// **'خطأ في التهيئة'**
  String get errorInitialization;

  /// No description provided for @errorEmptyPassword.
  ///
  /// In en, this message translates to:
  /// **'يرجى إدخال كلمة المرور.'**
  String get errorEmptyPassword;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'بيانات الدخول غير صحيحة.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'فشل تسجيل الدخول.'**
  String get errorLoginFailed;

  /// No description provided for @errorPasswordUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'فشل تحديث كلمة المرور. يلزم صلاحية الأدمن.'**
  String get errorPasswordUpdateFailed;

  /// No description provided for @successPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'تم تحديث كلمة المرور بنجاح.'**
  String get successPasswordUpdated;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @inventoryCount.
  ///
  /// In en, this message translates to:
  /// **'Inventory Count'**
  String get inventoryCount;

  /// No description provided for @confirm_duplicate_pallet.
  ///
  /// In en, this message translates to:
  /// **'هل أنت متأكد أنك تريد تكرار هذا الباليت؟'**
  String get confirm_duplicate_pallet;

  /// No description provided for @error_duplicate_barcode.
  ///
  /// In en, this message translates to:
  /// **'هذا الباركود مكرر داخل نفس الأوردر.'**
  String get error_duplicate_barcode;

  /// No description provided for @error_invalid_barcode_format.
  ///
  /// In en, this message translates to:
  /// **'باركود غير صحيح. يجب أن يكون 20 أو 21 حرف بالضبط.'**
  String get error_invalid_barcode_format;

  /// No description provided for @error_unexpected_scan.
  ///
  /// In en, this message translates to:
  /// **'حدث خطأ غير متوقع أثناء معالجة القراءة.'**
  String get error_unexpected_scan;

  /// No description provided for @error_scan_failed.
  ///
  /// In en, this message translates to:
  /// **'حدث خطأ أثناء قراءة الباركود.'**
  String get error_scan_failed;

  /// No description provided for @error_scanner_init.
  ///
  /// In en, this message translates to:
  /// **'تعذر تهيئة الماسح. تأكد من الإعدادات.'**
  String get error_scanner_init;

  /// No description provided for @error_no_scanned_data.
  ///
  /// In en, this message translates to:
  /// **'لا توجد بيانات ممسوحة للإرسال.'**
  String get error_no_scanned_data;

  /// No description provided for @success_post_clear_cache.
  ///
  /// In en, this message translates to:
  /// **'تم الإرسال بنجاح وتم مسح الكاش.'**
  String get success_post_clear_cache;

  /// No description provided for @error_scanner_restart.
  ///
  /// In en, this message translates to:
  /// **'تعذر إعادة تشغيل الماسح.'**
  String get error_scanner_restart;

  /// No description provided for @success_scanner_stopped.
  ///
  /// In en, this message translates to:
  /// **'تم إيقاف الماسح.'**
  String get success_scanner_stopped;

  /// No description provided for @error_scanner_status_change.
  ///
  /// In en, this message translates to:
  /// **'تعذر تغيير حالة الماسح.'**
  String get error_scanner_status_change;

  /// No description provided for @error_profile_empty.
  ///
  /// In en, this message translates to:
  /// **'اسم البروفايل لا يمكن أن يكون فارغا.'**
  String get error_profile_empty;

  /// No description provided for @success_profile_changed.
  ///
  /// In en, this message translates to:
  /// **'تم تغيير البروفايل بنجاح.'**
  String get success_profile_changed;

  /// No description provided for @error_profile_change_failed.
  ///
  /// In en, this message translates to:
  /// **'تعذر تغيير البروفايل.'**
  String get error_profile_change_failed;

  /// No description provided for @error_invalid_url.
  ///
  /// In en, this message translates to:
  /// **'الرابط غير صحيح. مثال: http://10.10.30.47:2604'**
  String get error_invalid_url;

  /// No description provided for @error_invalid_device_id.
  ///
  /// In en, this message translates to:
  /// **'رقم الجهاز غير صحيح.'**
  String get error_invalid_device_id;

  /// No description provided for @error_confirm_save_settings.
  ///
  /// In en, this message translates to:
  /// **'تعذر تأكيد حفظ إعدادات الإرسال.'**
  String get error_confirm_save_settings;

  /// No description provided for @success_save_settings.
  ///
  /// In en, this message translates to:
  /// **'تم حفظ إعدادات الإرسال بنجاح.\n{url}'**
  String success_save_settings(String url);

  /// No description provided for @error_save_settings.
  ///
  /// In en, this message translates to:
  /// **'تعذر حفظ الإعدادات.'**
  String get error_save_settings;

  /// No description provided for @error_post_no_connection.
  ///
  /// In en, this message translates to:
  /// **'فشل الإرسال. لا يوجد اتصال بالخادم. تأكد من نفس الشبكة والرابط.'**
  String get error_post_no_connection;

  /// No description provided for @error_post_server_connection.
  ///
  /// In en, this message translates to:
  /// **'فشل الإرسال. تعذر الاتصال بالخادم. {details}'**
  String error_post_server_connection(String details);

  /// No description provided for @error_post_http_not_allowed.
  ///
  /// In en, this message translates to:
  /// **'فشل الإرسال. اتصال HTTP غير مسموح على الجهاز.'**
  String get error_post_http_not_allowed;

  /// No description provided for @error_post_server_code.
  ///
  /// In en, this message translates to:
  /// **'فشل الإرسال. الخادم أرجع كود {code}.'**
  String error_post_server_code(String code);

  /// No description provided for @error_post_unknown.
  ///
  /// In en, this message translates to:
  /// **'فشل الإرسال. سبب الخطأ: {details}'**
  String error_post_unknown(String details);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'موافق'**
  String get ok;

  /// No description provided for @baseUrl.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get baseUrl;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'إرسال'**
  String get send;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'حفظ كملف'**
  String get export;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'نشر'**
  String get post;

  /// No description provided for @numberOfScan.
  ///
  /// In en, this message translates to:
  /// **'Number of Scan'**
  String get numberOfScan;

  /// No description provided for @noScannedBarcodesYet.
  ///
  /// In en, this message translates to:
  /// **'No scanned barcodes yet.'**
  String get noScannedBarcodesYet;

  /// No description provided for @columnNo.
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get columnNo;

  /// No description provided for @columnBarcodeFull.
  ///
  /// In en, this message translates to:
  /// **'Barcode Full'**
  String get columnBarcodeFull;

  /// No description provided for @batchNo.
  ///
  /// In en, this message translates to:
  /// **'Batch No'**
  String get batchNo;

  /// No description provided for @serialNo.
  ///
  /// In en, this message translates to:
  /// **'Serial No'**
  String get serialNo;

  /// No description provided for @palletBox.
  ///
  /// In en, this message translates to:
  /// **'Pallet Box'**
  String get palletBox;

  /// No description provided for @palletBoxCount.
  ///
  /// In en, this message translates to:
  /// **'Pallet Box Count'**
  String get palletBoxCount;

  /// No description provided for @boxCount.
  ///
  /// In en, this message translates to:
  /// **'Box Count'**
  String get boxCount;

  /// No description provided for @palletCount.
  ///
  /// In en, this message translates to:
  /// **'Pallet Count'**
  String get palletCount;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'تحذير'**
  String get warning;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'نجاح'**
  String get success;

  /// No description provided for @confirm_clear_screen.
  ///
  /// In en, this message translates to:
  /// **'هل انت متاكد من مسح جميع البيانات من الجهاز'**
  String get confirm_clear_screen;

  /// No description provided for @confirm_duplicate_barcode.
  ///
  /// In en, this message translates to:
  /// **'هل تريد تكرار هذا الباركود'**
  String get confirm_duplicate_barcode;

  /// No description provided for @columnSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get columnSent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
