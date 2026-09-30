# Instructions for an AI agent: fix Flutter Android build warnings

Give this file to an AI agent inside the Flutter project you want to update.

## Task

Inspect this project, resolve the applicable Android build warnings described below, and verify a release APK build. Make the changes directly, preserve existing work and application behavior, and report the exact changes and verification results. This is a migration guide, not a command to copy version numbers blindly.

Do not deploy, publish, change signing credentials, or send messages to plugin maintainers. Follow this project's repository instructions. Ask for approval only when required by the execution environment or for a consequential change outside this task.

## 1. Inspect before editing

- Read repository instructions and inspect `git status` and existing changes. Do not revert unrelated edits.
- Check `flutter --version`, `flutter doctor -v`, the Java version actually used by Flutter, and installed Android SDK/NDK versions.
- Read `pubspec.yaml`, `pubspec.lock`, `android/settings.gradle(.kts)`, `android/build.gradle(.kts)`, `android/app/build.gradle(.kts)`, `android/gradle.properties`, and `android/gradle/wrapper/gradle-wrapper.properties`.
- Run one `flutter build apk` and capture the output. Avoid concurrent builds of the same checkout.
- Consult the current official migration documentation and affected plugin changelogs before choosing versions.
- Check CI configuration: a migration must work with the SDK, Java, and NDK available there, not only on this computer.

References:

- [Flutter app migration to built-in Kotlin](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers)
- [Flutter plugin migration to built-in Kotlin](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-plugin-authors)
- [Android Gradle Plugin release documentation](https://developer.android.com/build/releases/gradle-plugin)
- [Install and configure the NDK](https://developer.android.com/studio/projects/install-ndk)
- [Kotlin compiler options](https://kotlinlang.org/docs/gradle-compiler-options.html)

## 2. Java restricted native-access warning

Typical message: `java.lang.System::load` was called by `NativeLibraryLoader`; use `--enable-native-access=ALL-UNNAMED`.

Determine which JVM emits the warning. The Gradle launcher and Gradle daemon are separate JVMs; configuring only the daemon may leave the launcher warning.

For a compatible Java version, preserve existing settings and add the flag to the relevant JVM:

```properties
# android/gradle.properties: append to the existing value, do not replace memory settings.
org.gradle.jvmargs=<existing options> --enable-native-access=ALL-UNNAMED
```

The `<existing options>` text is a placeholder, not a literal configuration value.

For project-local launcher defaults, preserve any existing options:

```bat
rem android/gradlew.bat
set DEFAULT_JVM_OPTS=--enable-native-access=ALL-UNNAMED
```

```sh
# android/gradlew
DEFAULT_JVM_OPTS="--enable-native-access=ALL-UNNAMED"
```

Check that the project's supported Java versions accept this option. Avoid changing global Java environment variables for all projects. If wrapper scripts are ignored, ensure these edits can be delivered reproducibly through version control or a documented setup step. Do not commit local SDK paths or credentials.

## 3. Migrate the app and plugins to built-in Kotlin

Typical warning: the app or plugins apply the Kotlin Gradle Plugin (KGP), which future Flutter versions will no longer support.

The documented baseline for enabling built-in Kotlin is Flutter 3.47+ and AGP 9+. Verify current requirements before migration. If the project is older, assess a supported toolchain upgrade; do not enable built-in Kotlin on an unsupported setup or bypass dependency validation.

### Migrate dependencies first

Inventory every plugin listed in the warning. Check its changelog and Android build file for built-in Kotlin support. Upgrade only the affected dependencies and necessary transitive dependencies, and handle any API or platform requirement changes.

Use targeted commands such as:

```sh
flutter pub upgrade <affected-package-names>
```

Replace the placeholders with actual package names. Avoid upgrading every dependency just to remove build warnings.

If a required plugin has no compatible release:

- Preserve its API and runtime source code where possible.
- Use a reproducible local fork under `third_party/<plugin>` when reasonable, with a `path:` dependency in `pubspec.yaml`.
- Preserve its license and document the upstream version, source URL, local changes, and eventual replacement plan.
- Copy the required package source and metadata, not generated build output, caches, or credentials.
- Migrate its Android Gradle configuration following the plugin-author guide.
- Remove an obsolete private AGP/KGP pin when the plugin should inherit the host toolchain; verify that inheritance actually works.
- Never patch the shared Pub cache as the final solution: those edits disappear on other computers and can affect unrelated projects.

### Migrate the application

Remove `id("kotlin-android")` or the equivalent legacy KGP application from the app's Gradle file. Preserve the Android and Flutter plugin order.

Replace deprecated `android { kotlinOptions { ... } }` with compiler options outside `android`, preserving the existing JVM bytecode target. For a project already targeting Java 17:

```kotlin
kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}
```

Keep Java `sourceCompatibility` and `targetCompatibility` aligned with the Kotlin target. A plugin that targets Java 11 should retain target 11 unless a dependency requires an upgrade.

Enable built-in Kotlin in `android/gradle.properties`:

```properties
android.builtInKotlin=true
```

Treat `android.newDsl` separately. Preserve Flutter's supported compatibility setting when required; do not change it just because built-in Kotlin is enabled. Prefer supported DSL APIs. If legacy APIs require a deprecation suppression during the transition, scope it narrowly and document why.

AGP's bundled Kotlin compiler may be older than Flutter's minimum. An `org.jetbrains.kotlin.android` declaration with `apply false` in settings can select a newer compatible compiler without applying legacy KGP to the app. Verify the effective compiler version and current AGP guidance before adding it. Do not delete this declaration blindly if it is needed for version alignment.

Update the project's declared minimum Flutter/Dart versions and CI setup to match the migrated dependencies and toolchain.

## 4. Resolve the Android NDK mismatch

Typical warning: the app pins one NDK version while plugins require a newer one.

Identify the highest required NDK version and choose an installed or installable compatible version. Prefer the required version; use a newer version only after checking compatibility and CI availability.

Configure it inside the app's Android block:

```kotlin
android {
    ndkVersion = "<chosen-installed-version>"
}
```

Install missing versions with Android Studio or the supported Android CLI. Inspect CLI help: newer installers may use `android sdk install 'ndk@<version>'`, while older SDK Manager installations use `sdkmanager 'ndk;<version>'`.

Do not substitute a version merely because installation failed. Investigate installer syntax, available packages, and download errors first. Document installation requirements for other developers and CI.

## 5. Address build blockers only when observed

### Gradle lock timeout

Inspect the owner PID and Gradle daemon log. Wait for an active build or stop only the confirmed stale project-related daemon. Do not kill every Java process or delete a lock that a live process still holds. Retry without concurrent builds.

### Kotlin caches across Windows drives

If the actual error says `this and base files have different roots` and the Pub cache and project are on different drives, a project-level workaround is:

```properties
# Disable only when needed for the observed cross-drive incremental-cache error.
kotlin.incremental=false
```

Explain that this disables Kotlin incremental compilation and can slow rebuilds. Do not add it to projects that do not exhibit the error. Do not confuse this with the Gradle build cache.

### Android SDK XML-format warning

Inspect AGP and SDK tooling versions, including obsolete AGP pins inside plugins. Align the tooling rather than editing SDK metadata or suppressing the warning. If unresolved, report it explicitly.

### AAR metadata / compile SDK failure

If a plugin compiles against an API level below its dependencies' requirements, prefer a compatible plugin release. Updating only the app's compile SDK may not change the plugin's compile SDK. Do not change min SDK or target SDK unnecessarily.

### Font tree-shaking message

`MaterialIcons-Regular.otf was tree-shaken` is expected release optimization. Keep it enabled unless the app uses dynamic icon references that require otherwise.

## 6. Verify and deliver

- Run `flutter analyze`; distinguish new errors from existing notices.
- Run relevant existing tests when meaningful. Report failures honestly; do not rewrite unrelated tests just to obtain a passing result.
- Run `flutter build apk` after the final change and inspect the complete output and exit code.
- Check `git diff --check`, review the diff, and ensure local plugin sources, licenses, launcher edits, and dependency lockfile changes are reproducible.
- Do not claim a warning is fixed unless the final build confirms it. Report remaining warnings and their cause.
- Provide the APK path and summarize changed files, minimum toolchain versions, and required NDK installation.
- State which behavior needs device testing, especially scanner input, CSV saving, sharing, and email flows after dependency upgrades. A successful build does not prove runtime behavior.

## Reference migration from inventory_count

This project's successful build used Flutter 3.47.5, Java 25, Gradle 9.8.0, AGP 9.0.1, Kotlin 2.3.20, and installed NDK 30.0.16248370. Its affected plugin versions were file_saver 0.6.0, flutter_email_sender 10.0.1, package_info_plus 10.2.1, share_plus 13.3.0, and shared_preferences_android 2.4.28. Zebra scanner 1.0.1 was migrated locally without changing its scanner source code.

These are reference values, not universal requirements or a promise of compatibility with another project. Inspect and verify that project independently.
