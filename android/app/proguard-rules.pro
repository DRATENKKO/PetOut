# ProGuard rules for PetOut Flutter app

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.petlife.pet_life.** { *; }

# Keep JSON serialization models
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# SharedPreferences
-keep class android.content.SharedPreferences { *; }

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# AudioPlayers
-keep class xyz.luan.audioplayers.** { *; }

# Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Play Core deferred components (not used but referenced by Flutter)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
}
