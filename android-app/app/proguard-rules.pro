# Keep WebView and JavaScript interface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepattributes JavascriptInterface

# Keep Activity
-keep public class * extends android.app.Activity
