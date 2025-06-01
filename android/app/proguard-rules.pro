# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }
-keep class com.google.firebase.messaging.FirebaseMessagingServiceCompat { *; }
-keep class com.google.firebase.messaging.FirebaseMessagingServiceCompat** { *; }
-keep class com.google.firebase.iid.FirebaseInstanceId { *; }
-keep class com.google.firebase.iid.FirebaseInstanceIdService { *; }
-keep class com.google.firebase.iid.FirebaseInstanceIdService** { *; }
-keep class com.google.firebase.messaging.FirebaseMessaging { *; }
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }
-keep class com.google.firebase.messaging.FirebaseMessagingService** { *; }
-keep class com.google.firebase.analytics.FirebaseAnalytics { *; }
-keep class com.google.firebase.analytics.FirebaseAnalyticsService { *; }
-keep class com.google.firebase.analytics.FirebaseAnalyticsService** { *; }

# Crashlytics
-keep class com.crashlytics.** { *; }
-keep class com.crashlytics.android.Crashlytics { *; }
-keep class com.crashlytics.android.CrashlyticsInitProvider { *; }
-keep class com.crashlytics.android.CrashlyticsInitProvider** { *; }
-keep class com.crashlytics.android.core.CrashlyticsCore { *; }
-keep class com.crashlytics.android.core.CrashlyticsCore** { *; }

# Performance Monitoring
-keep class com.google.firebase.perf.** { *; }
-keep class com.google.firebase.perf.FirebasePerformance { *; }
-keep class com.google.firebase.perf.FirebasePerformance** { *; }
-keep class com.google.firebase.perf.metrics.Trace { *; }
-keep class com.google.firebase.perf.metrics.Trace** { *; }

# Google Play Services
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.ads.identifier.** { *; }
-keep class com.google.android.gms.measurement.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep the special static methods that are required in all enumeration classes.
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep R classes and their static fields
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep serializable classes
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep the application class
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference
-keep public class com.android.vending.licensing.ILicensingService

# Keep View bindings
-keepclassmembers class * {
    @android.view.View *;
    @android.view.View.Initializer *;
}

# Keep the custom Application class
-keep public class * extends android.app.Application
-keep public class * extends android.app.Application {
    public void onCreate();
}

# Keep all activities
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Fragment
-keep public class * extends android.support.v4.app.Fragment
-keep public class * extends androidx.fragment.app.Fragment

# Keep the custom views
-keep public class * extends android.view.View
-keep public class * extends android.view.ViewGroup

# Keep the custom widgets
-keep public class * extends android.widget.*

# Keep the custom drawables
-keep public class * extends android.graphics.drawable.Drawable
-keep public class * extends android.graphics.drawable.BitmapDrawable
-keep public class * extends android.graphics.drawable.DrawableContainer
-keep public class * extends android.graphics.drawable.StateListDrawable
-keep public class * extends android.graphics.drawable.LevelListDrawable
-keep public class * extends android.graphics.drawable.ScaleDrawable
-keep public class * extends android.graphics.drawable.ShapeDrawable
-keep public class * extends android.graphics.drawable.AnimationDrawable
-keep public class * extends android.graphics.drawable.DrawableWrapper
-keep public class * extends android.graphics.drawable.LayerDrawable
-keep public class * extends android.graphics.drawable.ClipDrawable
-keep public class * extends android.graphics.drawable.RotateDrawable
-keep public class * extends android.graphics.drawable.BitmapDrawable
