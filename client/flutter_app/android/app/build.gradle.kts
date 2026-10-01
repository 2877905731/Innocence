import java.util.Base64

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val signingVariables = listOf(
    "INNOCENCE_ANDROID_KEYSTORE",
    "INNOCENCE_ANDROID_STORE_PASSWORD",
    "INNOCENCE_ANDROID_KEY_ALIAS",
    "INNOCENCE_ANDROID_KEY_PASSWORD",
)
val hasReleaseSigning = signingVariables.all { !System.getenv(it).isNullOrBlank() }
val requestedRelease = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
if (requestedRelease && !hasReleaseSigning) {
    throw GradleException("Release signing requires the four INNOCENCE_ANDROID signing environment variables.")
}
val offlineEdition = (project.findProperty("dart-defines") as? String)
    ?.split(",")
    ?.any { String(Base64.getDecoder().decode(it)) == "INNOCENCE_OFFLINE_ONLY=true" }
    ?: false

android {
    namespace = "com.innocence.app.innocence_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.innocence.app.innocence_flutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (offlineEdition) {
        sourceSets.getByName("release").manifest.srcFile("src/offline/AndroidManifest.xml")
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(System.getenv("INNOCENCE_ANDROID_KEYSTORE"))
                storePassword = System.getenv("INNOCENCE_ANDROID_STORE_PASSWORD")
                keyAlias = System.getenv("INNOCENCE_ANDROID_KEY_ALIAS")
                keyPassword = System.getenv("INNOCENCE_ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
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
