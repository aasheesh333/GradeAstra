# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-keepattributes *Annotation*

# Keep Play Core library classes
-keep class com.google.android.play.core.** { *; }

# General
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn kotlin.**
-dontwarn javax.**
-dontwarn com.google.android.play.core.**
