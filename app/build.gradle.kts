plugins {
    id("awchat.android.application")
    id("awchat.android.compose")
}

android {
    namespace = "me.awfixer.awchat"
    defaultConfig {
        applicationId = "me.awfixer.awchat"
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.material3)
    debugImplementation(libs.androidx.compose.ui.tooling)

    testImplementation(libs.junit4)
}