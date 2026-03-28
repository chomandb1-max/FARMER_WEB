plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.farmer_app"
    compileSdk = 36

    sourceSets {
        getByName("main") {
            java.setSrcDirs(listOf("src/main/java", "src/main/kotlin"))
        }
    }

    buildTypes {
        getByName("release") {
            // ئەم دوو دێڕە کێشەی واژۆ و ئینستاڵ نەبوون چارەسەر دەکەن
            signingConfig = signingConfigs.getByName("debug")
            
            // ئەمانە بۆ ئەوەی ئەپەکە تێک نەچێت لە کاتی بچوکردنەوە
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    defaultConfig {
        applicationId = "com.example.farmer_app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }


   
}

flutter {
    source = "../.."
}
