import java.io.File

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") apply false
}

// Core builds need no Firebase file. The optional provider build reads a private external file.
val firebaseConfigPath = providers.environmentVariable("HO_FIREBASE_ANDROID_CONFIG").orNull
if (firebaseConfigPath != null) {
    val firebaseConfig = File(firebaseConfigPath)
    require(firebaseConfig.isAbsolute && firebaseConfig.isFile && !firebaseConfig.canonicalFile.toPath().startsWith(rootDir.parentFile.parentFile.parentFile.canonicalFile.toPath())) { "HO_FIREBASE_ANDROID_CONFIG must name an existing absolute file outside the repository." }
    apply(plugin = "com.google.gms.google-services")
    // Override the plugin's conventional paths after its Android variant configuration.
    afterEvaluate {
        tasks.withType<com.google.gms.googleservices.GoogleServicesTask>().configureEach {
            googleServicesJsonFiles.set(listOf(firebaseConfig))
        }
    }
}

android {
    namespace = "dev.homeoffice.homeoffice_mobile"
    compileSdk = 37 // flutter_secure_storage 11.0.0 requires API 37; target/min remain Flutter defaults.
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Development identifier; distribution identity is confirmed in HO-012.
        applicationId = "dev.homeoffice.homeoffice_mobile"
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

    buildTypes {
        release {
            // Unsigned release build for CI. Store signing is configured outside Git in HO-012.
            signingConfig = null
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

dependencies {
    // FlutterFire 16.6.0 has no Dart register/unregister API for FID mode yet.
    // Match its resolved native SDKs; the small channel calls official SDK APIs.
    implementation("com.google.firebase:firebase-messaging:25.1.2")
    implementation("com.google.firebase:firebase-installations:19.1.2")
}
