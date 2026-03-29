---
name: build-apk
description: 'Build Android APK for Homestay Expense app. Use when: building APK, assembling debug/release APK, deploying to emulator, installing on device, Android build errors, Gradle build issues.'
argument-hint: 'debug or release'
---

# Build Android APK

## 前提条件

- **JAVA_HOME**: `C:\Program Files\Android\Android Studio\jbr`
- **ANDROID_HOME**: `C:\Users\localad\AppData\Local\Android\Sdk`
- **Gradle**: 8.7（wrapper 已配置）
- **compileSdk**: 34, **minSdk**: 26, **targetSdk**: 34
- **Package**: `com.homestay.expense`

## 步骤

### 1. 同步前端文件（必须！）

先确保 `home_expense.htm` 已同步到 Android assets：

```powershell
Copy-Item home_expense.htm android-app/app/src/main/assets/home_expense.htm -Force
```

### 2. 清理缓存（如果之前 build 失败）

```powershell
Remove-Item "$env:USERPROFILE\.gradle\caches\transforms-3" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "android-app\.gradle" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "android-app\app\build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "android-app\build" -Recurse -Force -ErrorAction SilentlyContinue
```

### 3. Build Debug APK

```powershell
cmd /c 'cd /d c:\Users\localad\Desktop\homestay-expenses\android-app & set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr& set ANDROID_HOME=C:\Users\localad\AppData\Local\Android\Sdk& gradlew.bat assembleDebug --no-daemon 2>&1'
```

### 4. Build Release APK

```powershell
cmd /c 'cd /d c:\Users\localad\Desktop\homestay-expenses\android-app & set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr& set ANDROID_HOME=C:\Users\localad\AppData\Local\Android\Sdk& gradlew.bat assembleRelease --no-daemon 2>&1'
```

Release 签名配置已在 `android-app/app/build.gradle` 中（keystore: `release-key.jks`）。

### 5. APK 输出路径

- **Debug**: `android-app/app/build/outputs/apk/debug/app-debug.apk`
- **Release**: `android-app/app/build/outputs/apk/release/app-release.apk`

## 安装到模拟器/设备

```powershell
# 启动模拟器
& 'C:\Users\localad\AppData\Local\Android\Sdk\emulator\emulator.exe' -avd Medium_Phone_API_35

# 等待设备就绪并安装
$adb = 'C:\Users\localad\AppData\Local\Android\Sdk\platform-tools\adb.exe'
& $adb wait-for-device
& $adb install -r android-app/app/build/outputs/apk/debug/app-debug.apk
& $adb shell am start -n com.homestay.expense/.MainActivity
```

## 常见问题

| 问题 | 解决方案 |
|------|---------|
| `Could not determine java version` | 确认 JAVA_HOME 指向 Android Studio JBR |
| `Transform cache corrupted` | 执行步骤 2 清理缓存后重新 build |
| `SDK not found` | 确认 ANDROID_HOME 路径正确，或检查 `android-app/local.properties` |
| Build 成功但 app 行为旧 | 忘了步骤 1 同步 `home_expense.htm` |

## 版本更新

修改 `android-app/app/build.gradle` 中的 `versionCode` 和 `versionName`（当前 v12）。
