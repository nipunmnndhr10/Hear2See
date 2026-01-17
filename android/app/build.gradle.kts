plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.slf_teachable_model"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

            
androidResources {
    noCompress += "tflite"
}

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.slf_teachable_model"
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

dependencies {
    // Required for some TFLite operations used in Google models
    // implementation "org.tensorflow:tensorflow-lite-select-tf-ops:+";
    // Option 2 – Safer / more reproducible (fixed version – good practice in 2026)
// implementation("org.tensorflow:tensorflow-lite-select-tf-ops:2.16.1")
// or try newer if available: 2.17.0 / 2.18.0 (check mvnrepository.com)



implementation("org.tensorflow:tensorflow-lite:2.10.0")
    implementation("org.tensorflow:tensorflow-lite-select-tf-ops:2.10.0")
}

flutter {
    source = "../.."
}
