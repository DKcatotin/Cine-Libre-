plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ✅ esta línea está bien
}

android {
    namespace = "com.example.cine_libre"
    compileSdk = 35 // o usa flutter.compileSdkVersion si ya está definido

    defaultConfig {
        applicationId = "com.example.cine_libre"
        minSdk = 21
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
    release {
        // Si activas esto en producción, asegúrate de usar ProGuard
        isMinifyEnabled = false
        isShrinkResources = false // 👈 importante
        signingConfig = signingConfigs.getByName("debug")
    }
}


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.gms:play-services-auth:20.7.0")
    implementation("com.google.firebase:firebase-auth-ktx:22.3.1")
}
