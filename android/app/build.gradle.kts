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

    // ───────── ABI filtering — arm64-v8a only ──────────────────────────────
    //
    // The bloat (~370 MB universal APK) comes from per-ABI duplication of
    // AAR native libraries — flutter_gemma's MediaPipe (~90 MB/ABI),
    // sherpa_onnx (~40 MB/ABI), mobile_scanner (~10 MB/ABI), and
    // just_audio (ExoPlayer). `splits.abi` is what filters AARs at
    // packaging time. The matching `defaultConfig.ndk.abiFilters` is set
    // in an `afterEvaluate` block at the bottom of this file (Flutter's
    // plugin overwrites our changes if we set them inside `defaultConfig`
    // here).
    //
    // minSdk = 24 (Android 7.0+) is effectively all 64-bit ARM in TH 2026
    // so dropping armeabi-v7a + x86_64 is safe. To re-introduce later,
    // add the same ABI string to BOTH this `splits.abi.include(...)` AND
    // the `afterEvaluate` block below.
    splits {
        abi {
            isEnable = true
            reset()
            include("arm64-v8a")
            isUniversalApk = false
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

// ─── Force-strip non-arm64 ABIs after Flutter's plugin runs ────────────────
//
// The Flutter Gradle plugin auto-injects `defaultConfig.ndk.abiFilters` with
// every default Android platform (armeabi-v7a, arm64-v8a, x86_64). That
// happens AFTER our `defaultConfig { ndk { ... } }` block above, so any
// modification made there is silently overwritten — and the resulting
// `[armeabi-v7a, arm64-v8a, x86_64]` list collides with `splits.abi`'s
// single-ABI include list, which Gradle rejects with:
//   Conflicting configuration : 'armeabi-v7a,arm64-v8a,x86_64' in ndk
//   abiFilters cannot be present when splits abi filters are set : arm64-v8a
//
// `afterEvaluate` runs after every plugin (including Flutter's) is done
// configuring, so trimming the list here is the override that wins.
afterEvaluate {
    android.defaultConfig.ndk.abiFilters.clear()
    android.defaultConfig.ndk.abiFilters.add("arm64-v8a")
}
