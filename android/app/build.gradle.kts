plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.froyo.ridekaro.ride_karo"
    compileSdk = flutter.compileSdkVersion
    // Pin NDK to the highest version required by transitive Flutter plugins (backward compatible).
    // This prevents Gradle from failing when a plugin requires a newer NDK than flutter.ndkVersion.
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.froyo.ridekaro.ride_karo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

/**
 * Workaround for CI/preview environments where Gradle/AGP can fail to chmod the final APK
 * under build/app/outputs/flutter-apk (Operation not permitted) if the directory contains
 * stale artifacts created by a different user or on a filesystem with restricted chmod.
 *
 * We proactively remove the flutter-apk output directory before assembling Release,
 * forcing Gradle to recreate it with correct ownership/permissions for the current user.
 */
val cleanFlutterApkOutputsForRelease = tasks.register<Delete>("cleanFlutterApkOutputsForRelease") {
    delete(layout.buildDirectory.dir("outputs/flutter-apk"))
}

tasks.matching { it.name == "assembleRelease" }.configureEach {
    dependsOn(cleanFlutterApkOutputsForRelease)
}
