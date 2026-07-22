import java.util.Properties
import java.io.FileInputStream
import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val flutterVersionCodeStr = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionNameStr = localProperties.getProperty("flutter.versionName") ?: "1.0.0"

android {
    namespace = "com.dhanuk.gradeastra"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
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

    // Resolve package name (e.g. com.dhanuk.gradeastra) once and derive
    // the Kotlin source path so MainActivity lives under <package>/<name>.
    val resolvedPackageName = dartDefines["PACKAGE_NAME"]
        .takeIf { !it.isNullOrBlank() && it.contains('.') }
        ?: "com.dhanuk.gradeastra"
    val packagePath = resolvedPackageName.replace('.', '/')
    val mainSourceSet = "src/main/kotlin"

    defaultConfig {
        applicationId = resolvedPackageName
        minSdk = 23
        targetSdk = 36

        versionCode = dartDefines["VERSION_CODE"]?.toIntOrNull() ?: flutterVersionCodeStr.toInt()
        versionName = dartDefines["VERSION_NAME"].takeIf { !it.isNullOrEmpty() } ?: flutterVersionNameStr
        multiDexEnabled = true

        manifestPlaceholders["admob_app_id"] = dartDefines["ADMOB_APP_ID"].takeIf { !it.isNullOrEmpty() } ?: "ca-app-pub-3940256099942544~3347511713"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("$mainSourceSet/$packagePath")
        }
    }

    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: "mykey"
            keyPassword = keystoreProperties["keyPassword"] as String? ?: ""
            storeFile = keystoreProperties["storeFile"]?.let { file(it) } ?: file("upload-keystore.jks")
            storePassword = keystoreProperties["storePassword"] as String? ?: ""
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
