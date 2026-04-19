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

        // ───────── ABI filtering — arm64-v8a only ─────────────────────────
        //
        // The 370 MB universal APK bloat comes from per-ABI duplication of
        // AAR native libraries — flutter_gemma's MediaPipe (~90 MB/ABI),
        // sherpa_onnx (~40 MB/ABI), mobile_scanner (~10 MB/ABI), and
        // just_audio (ExoPlayer). `defaultConfig.ndk.abiFilters` runs at
        // the `mergeNativeLibs` task and DOES filter `.so` from AARs +
        // JNI libs folders — but ONLY when set as the canonical filter
        // (clear default first, then add). Earlier attempt at v1.0.5 used
        // `abiFilters += listOf("arm64-v8a")` which ADDS to the default
        // 3-ABI list rather than replacing it → no filtering effect →
        // 350 MB APK instead of the expected 180 MB. This block clears
        // first so the result is exactly { "arm64-v8a" }.
        //
        // We deliberately don't use `splits.abi` here — when both knobs
        // are set Gradle insists they match exactly during the
        // configuration phase (before any afterEvaluate callback can
        // reconcile them), which makes the build fail with:
        //   Conflicting configuration : 'armeabi-v7a,arm64-v8a,x86_64'
        //   in ndk abiFilters cannot be present when splits abi filters
        //   are set : arm64-v8a
        //
        // minSdk = 24 (Android 7.0+) is virtually all 64-bit ARM in
        // TH 2026 so dropping armeabi-v7a + x86_64 is safe.
        ndk {
            abiFilters.clear()
            abiFilters.add("arm64-v8a")
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
