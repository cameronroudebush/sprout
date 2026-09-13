-keep class io.flutter.plugin.platform.PlatformView { *; }
-keep class io.flutter.plugin.platform.PlatformViewFactory { *; }

-keep class com.mapbox.** { *; }
-keep class org.maplibre.** { *; }
-dontwarn com.mapbox.**
-dontwarn org.maplibre.**