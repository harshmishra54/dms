# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Geolocator (Baseflow plugins)
-keep class com.baseflow.** { *; }
-dontwarn com.baseflow.**

# Prevent R8 stripping annotations
-keepattributes *Annotation*
