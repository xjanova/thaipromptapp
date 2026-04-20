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

    // ───────── ABI + unused-native-lib stripping ─────────────────────────
    //
    // Starting point (v1.0.4): universal APK at 372 MB.
    //   v1.0.8: arm64-v8a only                  → 209 MB
    //   v1.0.11: + drop unused flutter_gemma libs → target ~120 MB
    //
    // [1] ABI filter — `packaging.jniLibs.excludes` is the ONLY knob that
    //     works reliably. Earlier attempts failed:
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
    //   The packaging-level exclude pattern drops `.so` files right
    //   before APK assembly, regardless of which subsystem (Flutter
    //   plugin, AAR, NDK) put them into the merge.
    //
    //   minSdk = 24 (Android 7.0+) is effectively all 64-bit ARM in TH
    //   2026 so dropping armeabi-v7a + x86_64 is safe.
    //
    // [2] flutter_gemma ships ~145 MB of native libs for features we
    //     don't use. We ONLY call:
    //       - FlutterGemma.initialize(huggingFaceToken: …)
    //       - FlutterGemma.isModelInstalled(id)
    //       - FlutterGemma.installModel(modelType: …).finish()
    //       - FlutterGemma.getActiveModel(…)  → LlmInference path
    //     — all of which load libllm_inference_engine_jni.so (26 MB)
    //     + liblitertlm_jni.so (20 MB). Everything else is unused:
    //
    //     Vision / image generation (38 MB):
    //       libmediapipe_tasks_vision_jni.so              (14 MB)
    //       libmediapipe_tasks_vision_image_generator_jni.so (14 MB)
    //       libimagegenerator_gpu.so                      (10 MB)
    //
    //     Embedding / RAG (50 MB):
    //       libgemma_embedding_model_jni.so               (17 MB)
    //       libgecko_embedding_model_jni.so               (17 MB)
    //       libtext_chunker_jni.so                         (9 MB)
    //       libsqlite_vector_store_jni.so                  (7 MB)
    //
    //     These .so live under `lib/arm64-v8a/` so they're matched by
    //     their filename regardless of ABI. If a future feature (on-
    //     device RAG or vision) needs any of them, delete the matching
    //     line below and the plugin will pick it up on next build.
    //
    // [3] To re-add an ABI later, remove the matching `lib/…/**` line.
    packaging {
        jniLibs {
            excludes += setOf(
                // [1] Drop non-arm64 ABIs.
                "lib/armeabi-v7a/**",
                "lib/x86/**",
                "lib/x86_64/**",

                // [2a] flutter_gemma — vision + image generation.
                "**/libmediapipe_tasks_vision_jni.so",
                "**/libmediapipe_tasks_vision_image_generator_jni.so",
                "**/libimagegenerator_gpu.so",

                // [2b] flutter_gemma — embedding / RAG.
                "**/libgemma_embedding_model_jni.so",
                "**/libgecko_embedding_model_jni.so",
                "**/libtext_chunker_jni.so",
                "**/libsqlite_vector_store_jni.so",
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
