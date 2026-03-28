@echo off
echo ---------------------------------------
echo Building Falahi Zirak APK...
echo ---------------------------------------

call flutter build apk --release

if exist build\app\outputs\flutter-apk\app-release.apk (
    move build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\Falahi_Zirak.apk
    echo.
    echo ✅ Done! Your APK is ready: 
    echo build\app\outputs\flutter-apk\Falahi_Zirak.apk
) else (
    echo ❌ Build failed! Check for errors.
)

pause