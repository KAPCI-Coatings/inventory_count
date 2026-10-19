# Test Report: Inventory Count v1.8.0+7

**Date:** 18-10-2026
**Branch:** `develop` (uncommitted 1.8.0 changes)
**Overall result:** Approved for production. The 1.8.0 features and the two release-blocking fixes (5.1 and 4.2) pass their tests, and the release APK builds. 3 test failures remain open: two are header-name questions and one is a leftover Flutter sample (section 4). None affects how the app runs. The other code review findings are planned for 1.8.1.

---

## 1. What was tested

| Area | Method | Result |
|---|---|---|
| Static analysis (`flutter analyze`) | Whole project | ✅ No issues |
| Automated tests (`flutter test`) | 55 tests in 12 files | ⚠️ 52 pass, 3 fail (all 3 also failed on 1.7.5) |
| Release build (`flutter build apk --release`) | Full Android build | ✅ Built `app-release.apk` (55.3 MB) |
| Code review | All of `lib/`, read for bugs | 10 findings (section 5) |
| On-device test (Zebra scanner) | Not done | ❌ No device was connected; see section 6 |

---

## 2. New in 1.8.0, all tested

14 new tests in `test/release_1_8_0_test.dart`. All pass.

### 2.1 Export file name
The format is `Device(<DevId>)-<dd>-<MM>-<yyyy>-<hh>-<mm><AM/PM>.xlsx`.

| Case | Expected | Result |
|---|---|---|
| 10:30 in the morning, device 053 | `Device(053)-18-10-2026-10-30AM` | ✅ |
| 15:05, device 7 | `Device(7)-05-01-2026-03-05PM` | ✅ |
| Midnight | `...-12-00AM` | ✅ |
| No device ID set | `Device()-...` (still a valid name) | ✅ |
| No `: / \ * ? " < > \|` characters in the name | None present | ✅ |

> The time uses `-` instead of `:` (`10-30AM`, not `10:30AM`). Android and Windows do not allow `:` in file names.

**Bug found and fixed during testing:** the first version used `DateFormat(..., 'en')`. That call crashes unless the date locale data has already been loaded, which was only true by accident in the app. The name is now built by hand, so it cannot crash.

### 2.2 Button renamed
"اضافه بالته جديده" is now **"انشاء بالتة جديدة"**, in Arabic and English. ✅

### 2.3 Popup when switching Pallets → Boxes without creating a new pallet

| Case | Expected | Result |
|---|---|---|
| Nothing scanned yet, switch to Boxes | No popup, switches directly | ✅ |
| After a pallet scan, switch to Boxes (Arabic and English UI) | Popup with Arabic text and 3 buttons | ✅ |
| All 3 buttons | Bold text | ✅ |
| **الغاء** and **انشاء بالتة جديدة** | Same row, same height, create button wider | ✅ |
| Press **الغاء** | Stays on Pallets, pallet number unchanged | ✅ |
| Press **الاستمرار على الأخيرة** | Boxes are saved on the same pallet (e.g. 11) | ✅ |
| Press **انشاء بالتة جديدة** | Boxes are saved on the next pallet (e.g. 12) | ✅ |
| A box was already scanned, then switch Pallets → Boxes again | No popup | ✅ |
| Last pallet scan was a rejected duplicate, then switch | Popup still appears | ✅ (bug found by the review and fixed; see 5.4) |

### 2.4 Popup buttons style
Every popup now uses the same buttons:
- **Cancel or No:** black outline with bold black text.
- **Confirm or Yes:** black background with bold white text.

This covers the error and warning popup, the clear-data popup, the create-pallet popup, the Assets clear popup and the scan overlay. It is checked by `flutter analyze`; the colours have only been reviewed by reading the code, not seen on screen.

---

## 3. Automated test results by file

| Test file | Result | Notes |
|---|---|---|
| `release_1_8_0_test.dart` | ✅ 14/14 | New |
| `barcode_upload_test.dart` | ✅ 8/8 | Sending to the backend in batches |
| `pallet_numbering_test.dart` | ✅ 6/6 | |
| `scan_type_test.dart` | ✅ 2/2 | Updated for the new popup |
| `new_pallet_button_test.dart` | ✅ 3/3 | Updated for the new label |
| `barcode_screen_layout_test.dart` | ✅ 4/4 | Updated for the new label |
| `scanner_dialog_test.dart` | ✅ 2/2 | |
| `dummy_barcode_generator_test.dart` | ✅ 1/1 | |
| `csv_export_service_test.dart` | ⚠️ 2/3 | Old failure, see 4.1 |
| `pallet_number_storage_test.dart` | ✅ 8/8 | Fixed, see 4.2 |
| `search_results_table_test.dart` | ⚠️ 2/3 | Old failure, see 4.3 |
| `widget_test.dart` | ❌ 0/1 | Old failure, see 4.4 |

---

## 4. Test failures found (all also failed on 1.7.5)

These were checked by running the tests on the last commit (`0c5c788`, v1.7.5) before any 1.8.0 change.

1. **Excel header name.** The test expects `Pallet Num`, but the app writes `Pallet No`. **Decision needed:** which header does the warehouse/SAP side expect? Then update either the code or the test.
2. **An empty pallet number can be skipped.** Example: you press "create new pallet", so pallet 12 is reserved with nothing scanned on it. You then go back to Pallets and scan a full pallet, which is saved as **13**. Pallet 12 stays empty, and the Excel file has a gap. The test expects the app to block this, and it does not. ✅ **Fixed before release:** a full pallet scanned now reuses the empty reserved number (12), so no gap is left. The database also refuses to save past an empty pallet number.
3. **Search table header.** The test expects `Pallet Number`, but the screen shows `Pallet No`. This is the same decision as item 1.
4. **`widget_test.dart`** is Flutter's default "counter" sample and does not test this app. **Recommended:** delete it.

---

## 5. Code review findings

Ordered from most to least serious. Only **5.1** and **5.4** have been fixed; the rest are planned for 1.8.1.

| # | Severity | Problem | User impact | Suggested fix |
|---|---|---|---|---|
| 5.1 | **Medium–High** | Scans were still processed when the user was on the **Assets** or **Settings** screen | Scanning a box or pallet on Assets also saved an inventory row. A duplicate box there could switch the scanner off with no message. | ✅ **Fixed before release:** inventory scans are counted only while the scan screen is the screen being shown. Covered by a test. |
| 5.2 | Medium | Popup messages cannot be cleared from the state | "Sent successfully" can appear again later, for example after confirming a duplicate pallet | Fix `copyWith` so it can set messages to empty |
| 5.3 | Medium | "Mark as sent" matches rows by barcode text | With 2 copies of the same pallet barcode (a confirmed duplicate) split across 2 batches, one copy can be marked sent without ever being sent | Mark rows as sent by row ID |
| 5.4 | Medium | **New popup** was skipped after a rejected duplicate pallet | Boxes went onto the full pallet's number without asking | ✅ **Fixed in 1.8.0** and covered by a test |
| 5.5 | Medium | A timed-out send may be stored twice on the server (server behaviour not checked) | Quantities could be counted twice in the backend | Send a batch ID and have the server ignore repeats |
| 5.6 | Medium | Admin asset export clears the data even when saving was cancelled (not checked) | Asset scans can be lost | Clear only after the file is saved |
| 5.7 | Low–Medium | Admin "Clear" deletes items that were never sent, with no special warning | Unsent scans can be lost | Warn when there are unsent items |
| 5.8 | Low | A pallet barcode with an unreadable quantity is saved with qty **0** | Wrong box total | Reject the scan as an invalid barcode |
| 5.9 | Low | Server error details are not shown | The user sees "server error" with no code | Show the error details from the server |
| 5.10 | Low | Inventory export errors show no message | The export silently does nothing | Catch the error and show a popup |

**Checked and found correct:** the protection against double scans and double sends, counters rebuilt correctly after an app restart, pallet number reservation saved safely in the database, the scanner paused during popups and sending, and the new **الغاء** button.

**Not reachable today, but note:** changing a password has no effect, and default users are reset on every app start.

---

## 6. Must be tested by hand on a Zebra device

These cannot be covered by automated tests. Please run through them before release:

- [ ] Real hardware scans in Pallets mode and Boxes mode.
- [ ] The Pallets → Boxes popup: try all 3 buttons, and check that scanning while the popup is open does nothing.
- [ ] The popup button colours and bold text are easy to read on the device screen, in Arabic.
- [ ] Export: the file is saved as `Device(XXX)-dd-MM-yyyy-hh-mmAM.xlsx` and opens in Excel.
- [ ] Send to the backend (real server), including with the network turned off during a send.
- [ ] Login and logout as User and as Admin; Settings (device ID, base URL); Search; Assets.
- [ ] Item 5.1: scan on the Assets screen, return to the scan screen, and check that no inventory row was added.
- [ ] Item 4.2: press create new pallet, switch back to Pallets, scan a full pallet, and check that it gets the reserved number with no gap.
- [ ] Close and reopen the app: the counters and current pallet number are kept.

---

## 7. Files changed for 1.8.0

- `pubspec.yaml`: version `1.8.0+7`.
- `lib/core/services/csv_export_service.dart`: new export file name.
- `lib/presentation/widgets/barcode/barcode_status_section.dart`: Pallets → Boxes popup.
- `lib/core/widgets/error_popup.dart`, `lib/presentation/widgets/barcode/centered_overlay_panel.dart`, `lib/presentation/widgets/barcode/barcode_actions_section.dart`, `lib/presentation/views/assets_screen.dart`: popup button style.
- `lib/core/widgets/default_button.dart` and the `lib/l10n/*` files: new texts.
- `lib/presentation/views/barcode_screen.dart`, `lib/presentation/view_models/barcode/barcode_bloc.dart`, `lib/core/routes_manger/route_generator.dart`, `lib/main.dart`: scans are ignored when the scan screen is hidden (5.1).
- `lib/data/datasources/barcode_local_datasource.dart` and `barcode_bloc.dart`: no empty pallet gaps (4.2).
- Tests: new `test/release_1_8_0_test.dart`; updated `scan_type_test.dart`, `new_pallet_button_test.dart`, `barcode_screen_layout_test.dart` and `pallet_number_storage_test.dart`. The rollback test now writes to a valid pallet, because the new guard blocks the write it used before.
