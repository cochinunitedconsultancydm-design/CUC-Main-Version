# AWS Amplify ProGuard Rules
-keep class com.amplifyframework.** { *; }
-keep class amplify_models.** { *; }
-keepclassmembers class * extends com.amplifyframework.core.model.Model { *; }
-keep class com.amazonaws.** { *; }

# Supabase Rules
-keep class io.supabase.** { *; }
-keep class gotrue.** { *; }
-keep class postgrest.** { *; }
-keep class realtime.** { *; }
-keep class storage.** { *; }

# Flutter Wrapper Rules
-keep class io.flutter.plugins.** { *; }
