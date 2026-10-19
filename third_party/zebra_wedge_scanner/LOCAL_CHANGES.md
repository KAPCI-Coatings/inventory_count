# Local Zebra scanner build migration

Based on zebra_wedge_scanner 1.0.1 from pub.dev. The upstream license is preserved in LICENSE.

The Android build uses the host project's AGP 9 and built-in Kotlin instead of pinning AGP 8.7.3 and applying the separate Kotlin Gradle Plugin. JVM target 11 and all Dart and native scanner source code remain unchanged. Flutter 3.47+ is required.

This local dependency keeps the migration reproducible without modifying the shared Pub cache. Replace it with an upstream release once that release supports built-in Kotlin.
