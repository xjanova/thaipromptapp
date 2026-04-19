import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Optional upload keystore. Not present in CI → we still fall back to the
// debug keystore so `flutter build` succeeds in PR branches.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "app.thaiprompt.thaipromptapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "app.thaiprompt.thaipromptapp"
        minSdk = 24                      // required for mobile_scanner + modern APIs
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ───────── ABI filtering ─────────────────────────────────────────────
        // We ship arm64-v8a ONLY. flutter_gemma's MediaPipe + sherpa_onnx +
        // mobile_scanner each carry ~50–90 MB of native .so per ABI, so a
        // universal APK with all three ABIs balloons to ~370 MB.
        //
        // Modern Android phones (minSdk 24 / Android 7.0+) are virtually all
        // 64-bit ARM — armeabi-v7a phones are negligible in TH 2026 and
        // x86_64 only exists on emulators. Dropping the other ABIs cuts
        // ~170 MB off the APK and ~50% off CI build time.
        //
        // To re-add an ABI later (e.g. for a low-end TH market segment),
        // append "armeabi-v7a" or "x86_64" to the list and rebuild.
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
