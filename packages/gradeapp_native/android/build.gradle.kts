plugins {
    id("com.android.library")
    id("kotlin-android")
}

group = "kz.gradeapp.native_notif"
version = "1.0"

android {
    namespace = "kz.gradeapp.native_notif"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        minSdk = 24
    }
}
