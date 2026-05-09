plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.smart_store"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    flavorDimensions += "app"

    productFlavors {

        create("client") {

            dimension = "app"

            applicationId = "com.example.smart_store"

            versionCode = 5
            versionName = "1.0.4"

            resValue("string", "app_name", "المتجر الذكي")
        }

        create("admin") {

            dimension = "app"

            applicationId = "com.example.smart_store_admin"

            versionCode = 1
            versionName = "1.0.0"

            resValue("string", "app_name", "المتجر الذكي - ادارة")

        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
