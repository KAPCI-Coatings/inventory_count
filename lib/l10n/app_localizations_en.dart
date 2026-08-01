// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get submit => 'Submit';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get french => 'French';

  @override
  String get settingsSavedSuccessfully => 'Settings saved successfully';

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
  String get error => 'Error';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get errorInitialization => 'Error initializing';

  @override
  String get errorEmptyPassword => 'Password cannot be empty.';

  @override
  String get errorInvalidCredentials => 'Login data is incorrect.';

  @override
  String get errorLoginFailed => 'Login failed.';

  @override
  String get errorPasswordUpdateFailed =>
      'Password update failed. Admin privileges required.';

  @override
  String get successPasswordUpdated => 'Password updated successfully.';

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
      'Are you sure you want to duplicate this pallet?';

  @override
  String get error_duplicate_barcode =>
      'This barcode is duplicated in the same order.';

  @override
  String get error_invalid_barcode_format =>
      'Invalid barcode. Must be exactly 20 or 21 characters.';

  @override
  String get error_unexpected_scan =>
      'An unexpected error occurred during scan processing.';

  @override
  String get error_scan_failed =>
      'An error occurred while reading the barcode.';

  @override
  String get error_scanner_init =>
      'Failed to initialize scanner. Check settings.';

  @override
  String get error_no_scanned_data => 'No scanned data to post.';

  @override
  String get success_post_clear_cache =>
      'Posted successfully and cache cleared.';

  @override
  String get error_scanner_restart => 'Failed to restart scanner.';

  @override
  String get success_scanner_stopped => 'Scanner stopped.';

  @override
  String get error_scanner_status_change => 'Failed to change scanner status.';

  @override
  String get error_profile_empty => 'Profile name cannot be empty.';

  @override
  String get success_profile_changed => 'Profile changed successfully.';

  @override
  String get error_profile_change_failed => 'Failed to change profile.';

  @override
  String get error_invalid_url =>
      'Invalid URL. Example: http://10.10.30.47:2604';

  @override
  String get error_invalid_device_id => 'Invalid device ID.';

  @override
  String get error_confirm_save_settings =>
      'Could not confirm saving settings.';

  @override
  String success_save_settings(String url) {
    return 'Settings saved successfully.\n$url';
  }

  @override
  String get error_save_settings => 'Failed to save settings.';

  @override
  String get error_post_no_connection =>
      'Post failed. No connection to server. Check network and URL.';

  @override
  String error_post_server_connection(String details) {
    return 'Post failed. Could not connect to server. $details';
  }

  @override
  String get error_post_http_not_allowed =>
      'Post failed. Cleartext HTTP traffic not permitted.';

  @override
  String error_post_server_code(String code) {
    return 'Post failed. Server returned code $code.';
  }

  @override
  String error_post_unknown(String details) {
    return 'Post failed. Error reason: $details';
  }

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get baseUrl => 'Base URL';

  @override
  String get send => 'إرسال';

  @override
  String get export => 'ارفاق ملف';

  @override
  String get post => 'Post';

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
  String get warning => 'Warning';

  @override
  String get success => 'Success';

  @override
  String get confirm_clear_screen =>
      'هل انت متاكد من مسح جميع البيانات من الجهاز';

  @override
  String get confirm_duplicate_barcode => 'هل تريد تكرار هذا الباركود';

  @override
  String get columnSent => 'Sent';
}
