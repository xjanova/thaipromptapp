# Flutter default rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Dart models accessed via reflection (freezed, json_annotation).
-keep class kotlin.Metadata { *; }

# mobile_scanner uses Google ML Kit
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# flutter_line_sdk (LINE login)
-keep class com.linecorp.** { *; }
-dontwarn com.linecorp.**

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Flutter references Play Core split-install APIs for deferred components.
# We don't use deferred components, so tell R8 to ignore the missing classes.
-dontwarn com.google.android.play.**
-keep class com.google.android.play.core.** { *; }

# dio / retrofit reflective types
-keep class * extends java.lang.Exception { *; }
