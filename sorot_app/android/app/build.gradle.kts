plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // pastikan SAMA dengan applicationId
    namespace = "com.example.sorot_app"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.sorot_app"   // <- samakan dengan namespace
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Opsi 1 (disarankan): inject @string/google_maps_key dari ENV
        resValue(
            "string",
            "google_maps_key",
            System.getenv("GOOGLE_MAPS_KEY_ANDROID") ?: "DEV_ONLY_KEY"
        )

        // Opsi 2 (alternatif): pakai manifestPlaceholders (Kotlin DSL)
        // manifestPlaceholders["GOOGLE_MAPS_KEY_ANDROID"] =
        //     System.getenv("GOOGLE_MAPS_KEY_ANDROID") ?: "DEV_ONLY_KEY"
        // lalu di AndroidManifest.xml gunakan: android:value="${GOOGLE_MAPS_KEY_ANDROID}"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

// Flutter block biarkan apa adanya
flutter {
    source = "../.."
}

// dependencies { }  // tidak wajib menambahkan apapun di sini untuk Maps jika pakai plugin google_maps_flutter
