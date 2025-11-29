plugins {
    id("com.android.application")
    id("kotlin-android") // keep kotlin android plugin id as you had
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.medcad"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        // TODO: Specify your own unique Application ID
        applicationId = "com.example.medcad"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        minSdk = flutter.minSdkVersion
    }

    // Kotlin DSL style compileOptions
    compileOptions {
        // JavaVersion is available in Kotlin DSL
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8

        // enable core library desugaring
        // Kotlin DSL property name is "isCoreLibraryDesugaringEnabled"
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        // jvmTarget is still set like this in kotlinOptions block
        jvmTarget = "1.8"
    }

    buildTypes {
        getByName("release") {
            // use debug signing for release while testing (you may change this later)
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Add only the desugaring library here (Kotlin DSL syntax)
    // This enables Java 8+ core lib APIs required by some plugins
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
    implementation("com.google.firebase:firebase-analytics")

    // Note: do NOT add implementation/kotlin-stdlib here unless required by your project.
    // The Flutter plugin brings the necessary deps for the Android module.
}

flutter {
    source = "../.."
}
