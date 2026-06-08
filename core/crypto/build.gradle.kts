plugins {
    id("awchat.android.library")
}

android {
    namespace = "me.awfixer.awchat.core.crypto"

    defaultConfig {
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }

    packaging {
        jniLibs {
            excludes += "**/libsignal_jni_testing.so"
        }
    }
}

dependencies {
    coreLibraryDesugaring(libs.desugar.jdk.libs)
    implementation(libs.libsignal.android)

    androidTestImplementation(libs.androidx.test.ext.junit)
    androidTestImplementation(libs.androidx.test.runner)
}