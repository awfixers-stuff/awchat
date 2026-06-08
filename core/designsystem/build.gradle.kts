plugins {
    id("awchat.android.library")
    id("awchat.android.compose")
}

android {
    namespace = "me.awfixer.awchat.core.designsystem"
}

dependencies {
    implementation(project(":core:model"))
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.foundation)
    implementation(libs.androidx.compose.material3)
    implementation(libs.androidx.compose.material.icons.extended)
}