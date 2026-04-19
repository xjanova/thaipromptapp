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

    // ───────── ABI stripping — arm64-v8a only ────────────────────────────
    //
    // We ship a single arm64-v8a APK. Two earlier attempts to filter
    // didn't work:
    //
    //   v1.0.5: `defaultConfig.ndk.abiFilters += listOf("arm64-v8a")`
    //     → `+=` appends to the default (empty) set; AAR `.so` for
    //       armeabi-v7a + x86_64 still got merged in → 350 MB APK.
    //
    //   v1.0.6: `splits.abi { include("arm64-v8a") }`
    //     → conflicts with Flutter Gradle plugin's auto-injected
    //       abiFilters (covers all 3 default platforms) at configuration
    //       phase, before any afterEvaluate can reconcile → build fails:
    //         Conflicting configuration : 'armeabi-v7a,arm64-v8a,x86_64'
    //         in ndk abiFilters cannot be present when splits abi filters
    //         are set : arm64-v8a
    //
    // The packaging-level exclude pattern always works — Gradle drops
    // any `.so` file matching the glob right before APK assembly, no
    // matter which subsystem put it there. ndk.abiFilters and splits.abi
    // both stay at their defaults so Flutter's plugin doesn't fight us.
    //
    // minSdk = 24 (Android 7.0+) is effectively all 64-bit ARM in TH 2026
    // so dropping armeabi-v7a + x86_64 is safe. To re-introduce later,
    // remove the matching exclude line below.
    packaging {
        jniLibs {
            excludes += setOf(
                "lib/armeabi-v7a/**",
                "lib/x86/**",
                "lib/x86_64/**",
            )
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
