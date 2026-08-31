# Android Gradle setup for Firebase

After you run `flutter create --org com.yourpie --project-name piecrew .`,
make these two small edits. They're additions to files Flutter already
generated — don't replace the whole file, just add the lines shown.

---

## 1. `android/build.gradle.kts` (project-level, at the repo root's android folder)

Add the Google Services plugin to the `plugins` block at the top:

```kotlin
plugins {
    // ...whatever Flutter already generated stays here...
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

If your generated file uses the older `buildscript { dependencies { classpath ... } }`
style instead of the `plugins {}` block, add this inside `dependencies`:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}
```

---

## 2. `android/app/build.gradle.kts` (app-level)

**a.** Apply the plugin — add to the `plugins` block at the top of the file:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")   // add this line
}
```

**b.** Set the package name and minimum SDK version — inside the `android { defaultConfig { ... } }` block:

```kotlin
android {
    defaultConfig {
        applicationId = "com.yourpie.piecrew"
        minSdk = 23          // Firebase Auth requires 23+
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

(`flutter create --org com.yourpie --project-name piecrew .` already sets
`applicationId` correctly, so you mainly need to bump `minSdk` to 23 if it's
lower.)

---

## 3. Place the config file

Copy `android-config/google-services.json` (from this project) into
`android/app/google-services.json`.

That's it — `flutter pub get` then `flutter run` should pick everything up.
