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

    }

    // ───────── ABI filtering — done via `splits.abi`, not `ndk.abiFilters`
    //
    // `defaultConfig.ndk.abiFilters` only restricts NDK code that THIS
    // module compiles. It does NOT filter AAR native libraries shipped by
    // dependencies — and the bloat is exactly there: flutter_gemma's
    // MediaPipe (~90 MB/ABI), sherpa_onnx (~40 MB/ABI), mobile_scanner
    // (~10 MB/ABI), and just_audio's ExoPlayer all package .so for
    // arm64-v8a + armeabi-v7a + x86_64 by default.
    //
    // `splits.abi` runs at packaging time and DOES filter dependency .so,
    // so a single APK that contains only arm64 ABI emerges — ~180 MB
    // instead of ~370 MB. minSdk = 24 (Android 7.0+) is effectively all
    // 64-bit ARM in our market, so dropping the other ABIs is safe.
    // To re-introduce an ABI later, add `include("armeabi-v7a")` or
    // `include("x86_64")` to the block below.
    splits {
        abi {
            isEnable = true
            reset()                        // drop the default include list
            include("arm64-v8a")
            isUniversalApk = false         // don't produce a fat APK alongside
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
