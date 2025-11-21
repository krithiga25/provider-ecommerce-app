##### STRIPE #####
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**

-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

-keepattributes *Annotation*



##### GOOGLE ML KIT #####
# Keep all ML Kit classes
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Vision
-keep class com.google.mlkit.vision.** { *; }
-dontwarn com.google.mlkit.vision.**

# Text Recognition language modules
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-dontwarn com.google.mlkit.vision.text.chinese.**

-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-dontwarn com.google.mlkit.vision.text.devanagari.**

-keep class com.google.mlkit.vision.text.japanese.** { *; }
-dontwarn com.google.mlkit.vision.text.japanese.**

-keep class com.google.mlkit.vision.text.korean.** { *; }
-dontwarn com.google.mlkit.vision.text.korean.**