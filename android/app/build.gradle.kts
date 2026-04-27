import java.util.Properties
import java.io.FileInputStream
import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dhanuk.gradeastra"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    // Load properties from dart-defines to access secrets passed at build time
    val dartEnvironmentVariables = project.property("dart-defines") as? String ?: ""
    val dartDefines = dartEnvironmentVariables.split(",").associate {
        val decoded = try {
             String(Base64.getDecoder().decode(it))
        } catch (e: Exception) {
             ""
        }
        val parts = decoded.split("=")
        parts[0] to (parts.getOrNull(1) ?: "")
    }

    defaultConfig {
        applicationId = dartDefines["PACKAGE_NAME"].takeIf { !it.isNullOrEmpty() } ?: "com.dhanuk.gradeastra"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = dartDefines["VERSION_CODE"]?.toIntOrNull() ?: flutter.versionCode
        versionName = dartDefines["VERSION_NAME"].takeIf { !it.isNullOrEmpty() } ?: flutter.versionName
        multiDexEnabled = true

        manifestPlaceholders["admob_app_id"] = dartDefines["ADMOB_APP_ID"].takeIf { !it.isNullOrEmpty() } ?: "ca-app-pub-3940256099942544~3347511713"
    }

    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: "mykey"
            keyPassword = keystoreProperties["keyPassword"] as String? ?: "GradeAstra@2024"
            storeFile = keystoreProperties["storeFile"]?.let { file(it) } ?: file("upload-keystore.jks")
            storePassword = keystoreProperties["storePassword"] as String? ?: "GradeAstra@2024"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            // proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
