/*
 * android/app/build.gradle.kts
 * Gaia Trails – Flutter (Kotlin DSL)
 */

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle plugin must come after the Android/Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties

/* ────────────────────────────────────────────────────────────────
   ⇒ Keystore handling (for release builds)
   ──────────────────────────────────────────────────────────────── */
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
} else {
    throw GradleException(
        "Missing key.properties file! Place it in the android/ directory and " +
                "add storePassword, keyPassword, keyAlias and storeFile."
    )
}

/** Fail fast if a property is missing. */
fun getRequiredProperty(key: String): String =
    keystoreProperties.getProperty(key)
        ?: throw GradleException("Missing required property '$key' in key.properties")

/* ────────────────────────────────────────────────────────────────
   ⇒ Android configuration
   ──────────────────────────────────────────────────────────────── */
android {
    // ←── NEW unique package for Gaia Trails
    namespace  = "com.gaiatrails.untitled"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }

    defaultConfig {
        // ←── Must match the namespace (or at least be consistent)
        applicationId = "com.gaiatrails.app"

        minSdk       = 23
        targetSdk    = flutter.targetSdkVersion
        versionCode  = flutter.versionCode        // bump when you publish
        versionName  = flutter.versionName        // e.g. "1.0.0"
    }

    signingConfigs {
        create("release") {
            keyAlias      = getRequiredProperty("keyAlias")
            keyPassword   = getRequiredProperty("keyPassword")
            storeFile     = file(getRequiredProperty("storeFile"))
            storePassword = getRequiredProperty("storePassword")
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig   = signingConfigs.getByName("release")
            isMinifyEnabled = true                 // keep ON for smaller APK/AAB
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"               // add custom rules here
            )
        }
        getByName("debug") {
            // Uses the debug keystore automatically created by the Android SDK
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

/* ────────────────────────────────────────────────────────────────
   ⇒ Flutter source hookup
   ──────────────────────────────────────────────────────────────── */
flutter { source = "../.." }

/* ────────────────────────────────────────────────────────────────
   ⇒ Dependencies (keep minimal; Flutter injects most of them)
   ──────────────────────────────────────────────────────────────── */
dependencies {
    // Align versions of all Kotlin components
    implementation(platform("org.jetbrains.kotlin:kotlin-bom:1.9.10"))
    // Other direct Android dependencies go here
}
