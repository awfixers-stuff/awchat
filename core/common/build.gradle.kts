plugins {
    id("awchat.kotlin.library")
}

dependencies {
    implementation(libs.kotlinx.coroutines.core)
    testImplementation(libs.junit4)
}