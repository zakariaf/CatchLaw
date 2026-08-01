plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "app.catchlaw.catchlaw"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Set at `flutter create --org app.catchlaw`. It is the store identity and
        // cannot change after the first release without shipping a second app.
        applicationId = "app.catchlaw.catchlaw"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // SPEC.md §11: Android 7.0. The target device is a three-year-old
        // mid-range phone; a higher floor drops it, a lower one ships to
        // devices the app was never measured on.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Debug keys, deliberately, until E21 (release readiness) introduces the
            // upload key. CI builds this bundle UNSIGNED and only reads its merged
            // manifest, so no signing secret belongs in this repository yet — and the
            // INTERNET question is answered identically by an unsigned bundle.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
