# Keep Flutter and Firebase classes used via reflection
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.internal.** { *; }
-keep class com.google.android.gms.ads.** { *; }

# Keep Gson default constructors if used
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

-dontwarn org.codehaus.mojo.**
-dontwarn javax.annotation.**
