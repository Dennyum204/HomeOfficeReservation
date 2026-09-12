import java.io.File
import java.util.Properties

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

// Optional release signing. Neither the properties nor the keystore may be in Git.
val signingPath = providers.environmentVariable("HO_ANDROID_SIGNING_PROPERTIES").orNull
val releaseKeys = signingPath?.let {
    val file = File(it)
    val repository = rootDir.parentFile.parentFile.parentFile.canonicalFile.toPath()
    require(file.isAbsolute && file.isFile && !file.canonicalFile.toPath().startsWith(repository)) { "Signing properties must be an absolute private file outside the repository." }
    Properties().apply { file.inputStream().use { load(it) } }.also { keys ->
        listOf("storeFile", "storePassword", "keyAlias", "keyPassword").forEach { name ->
            require(!keys.getProperty(name).isNullOrBlank()) { "Incomplete private signing configuration." }
        }
        val store = File(keys.getProperty("storeFile"))
        require(store.isAbsolute && store.isFile && !store.canonicalFile.toPath().startsWith(repository)) { "Keystore must be an absolute private file outside the repository." }
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
        // Preserve installed app identity and the existing Firebase Android registration.
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

    signingConfigs {
        if (releaseKeys != null) create("pilot") {
            storeFile = File(releaseKeys.getProperty("storeFile"))
            storePassword = releaseKeys.getProperty("storePassword")
            keyAlias = releaseKeys.getProperty("keyAlias")
            keyPassword = releaseKeys.getProperty("keyPassword")
        }
    }
    buildTypes {
        release {
            // Core CI can still compile unsigned; never silently sign with a debug key.
            signingConfig = if (releaseKeys != null) signingConfigs.getByName("pilot") else null
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
