plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase / Google services
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin last
}

android {
    namespace = "com.example.project_abiyahe"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.0.13004108"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true 
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        applicationId = "com.example.project_abiyahe"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    val kotlinVersion = "1.9.0" 
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlinVersion")
  coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
