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

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
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
  /// **'Submit'**
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
  /// **'Settings saved successfully'**
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
  /// **'Exit'**
  String get exit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
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
  /// **'Clear'**
  String get clear;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorInitialization.
  ///
  /// In en, this message translates to:
  /// **'Error initializing'**
  String get errorInitialization;

  /// No description provided for @errorEmptyPassword.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty.'**
  String get errorEmptyPassword;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Login data is incorrect.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed.'**
  String get errorLoginFailed;

  /// No description provided for @errorPasswordUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Password update failed. Admin privileges required.'**
  String get errorPasswordUpdateFailed;

  /// No description provided for @successPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
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
  /// **'Login'**
  String get login;

  /// No description provided for @inventoryCount.
  ///
  /// In en, this message translates to:
  /// **'Inventory Count'**
  String get inventoryCount;

  /// No description provided for @confirm_duplicate_pallet.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to duplicate this pallet?'**
  String get confirm_duplicate_pallet;

  /// No description provided for @error_duplicate_barcode.
  ///
  /// In en, this message translates to:
  /// **'This barcode is duplicated in the same order.'**
  String get error_duplicate_barcode;

  /// No description provided for @error_invalid_barcode_format.
  ///
  /// In en, this message translates to:
  /// **'Invalid barcode. Must be exactly 20 or 21 characters.'**
  String get error_invalid_barcode_format;

  /// No description provided for @error_unexpected_scan.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred during scan processing.'**
  String get error_unexpected_scan;

  /// No description provided for @error_scan_failed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while reading the barcode.'**
  String get error_scan_failed;

  /// No description provided for @error_scanner_init.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize scanner. Check settings.'**
  String get error_scanner_init;

  /// No description provided for @error_no_scanned_data.
  ///
  /// In en, this message translates to:
  /// **'No scanned data to post.'**
  String get error_no_scanned_data;

  /// No description provided for @success_post_clear_cache.
  ///
  /// In en, this message translates to:
  /// **'Posted successfully and cache cleared.'**
  String get success_post_clear_cache;

  /// No description provided for @error_scanner_restart.
  ///
  /// In en, this message translates to:
  /// **'Failed to restart scanner.'**
  String get error_scanner_restart;

  /// No description provided for @success_scanner_stopped.
  ///
  /// In en, this message translates to:
  /// **'Scanner stopped.'**
  String get success_scanner_stopped;

  /// No description provided for @error_scanner_status_change.
  ///
  /// In en, this message translates to:
  /// **'Failed to change scanner status.'**
  String get error_scanner_status_change;

  /// No description provided for @error_profile_empty.
  ///
  /// In en, this message translates to:
  /// **'Profile name cannot be empty.'**
  String get error_profile_empty;

  /// No description provided for @success_profile_changed.
  ///
  /// In en, this message translates to:
  /// **'Profile changed successfully.'**
  String get success_profile_changed;

  /// No description provided for @error_profile_change_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change profile.'**
  String get error_profile_change_failed;

  /// No description provided for @error_invalid_url.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL. Example: http://10.10.30.47:2604'**
  String get error_invalid_url;

  /// No description provided for @error_invalid_device_id.
  ///
  /// In en, this message translates to:
  /// **'Invalid device ID.'**
  String get error_invalid_device_id;

  /// No description provided for @error_confirm_save_settings.
  ///
  /// In en, this message translates to:
  /// **'Could not confirm saving settings.'**
  String get error_confirm_save_settings;

  /// No description provided for @success_save_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully.\n{url}'**
  String success_save_settings(String url);

  /// No description provided for @error_save_settings.
  ///
  /// In en, this message translates to:
  /// **'Failed to save settings.'**
  String get error_save_settings;

  /// No description provided for @error_post_no_connection.
  ///
  /// In en, this message translates to:
  /// **'Post failed. No connection to server. Check network and URL.'**
  String get error_post_no_connection;

  /// No description provided for @error_post_server_connection.
  ///
  /// In en, this message translates to:
  /// **'Post failed. Could not connect to server. {details}'**
  String error_post_server_connection(String details);

  /// No description provided for @error_post_http_not_allowed.
  ///
  /// In en, this message translates to:
  /// **'Post failed. Cleartext HTTP traffic not permitted.'**
  String get error_post_http_not_allowed;

  /// No description provided for @error_post_server_code.
  ///
  /// In en, this message translates to:
  /// **'Post failed. Server returned code {code}.'**
  String error_post_server_code(String code);

  /// No description provided for @error_post_unknown.
  ///
  /// In en, this message translates to:
  /// **'Post failed. Error reason: {details}'**
  String error_post_unknown(String details);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @baseUrl.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get baseUrl;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
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
  /// **'Warning'**
  String get warning;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @confirm_clear_screen.
  ///
  /// In en, this message translates to:
  /// **'Reset the screen? Scanned data will remain saved in the database.'**
  String get confirm_clear_screen;
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
