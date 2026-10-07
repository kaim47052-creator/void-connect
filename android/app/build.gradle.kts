plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Direct APK distribution uses a private local signing key. CI builds debug
// packages and does not receive this key or its passwords.
val releaseStoreFile = System.getenv("VOID_CONNECT_RELEASE_STORE_FILE")
val releaseStorePassword = System.getenv("VOID_CONNECT_RELEASE_STORE_PASSWORD")
val releaseKeyAlias = System.getenv("VOID_CONNECT_RELEASE_KEY_ALIAS")
val releaseKeyPassword = System.getenv("VOID_CONNECT_RELEASE_KEY_PASSWORD")
val verificationInstall = System.getenv("VOID_CONNECT_VERIFY_RELEASE") == "1"
val hasReleaseSigning = listOf(
    releaseStoreFile, releaseStorePassword, releaseKeyAlias, releaseKeyPassword,
).all { !it.isNullOrBlank() } && file(releaseStoreFile.orEmpty()).isFile
val requestedRelease = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
if (requestedRelease && !hasReleaseSigning) {
    throw GradleException(
        "Release signing is not configured. Use scripts/Build-SignedAndroid.ps1 " +
            "or set VOID_CONNECT_RELEASE_* variables. See docs/RELEASING.md.",
    )
}

android {
    namespace = "dev.voidconnect.void_connect"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Keep this ID stable for v0.1 to preserve the existing application identity.
        applicationId = "dev.voidconnect.void_connect"
        manifestPlaceholders["applicationLabel"] =
            if (verificationInstall) "Void Connect Check" else "Void Connect"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            // An opt-in validation APK coexists with the user's debug install.
            // It is never a distribution artifact; packaging checks the ID.
            if (verificationInstall) applicationIdSuffix = ".releasecheck"
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
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
