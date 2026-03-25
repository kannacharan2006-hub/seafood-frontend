# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep FlutterEngine
-keep class io.flutter.embedding.engine.** { *; }

# Keep GeneratedPluginRegistrant
-keep class com.example.flutter_application_1.** { *; }
-keep class com.seafood.erp.** { *; }

# Http client
-keep class org.apache.http.** { *; }
-dontwarn org.apache.http.**
-dontwarn android.net.http.**

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# JSON
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}
