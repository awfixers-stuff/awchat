import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    `kotlin-dsl`
}

group = "me.awfixer.awchat.buildlogic"

java {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
}

dependencies {
    compileOnly(libs.android.gradle.plugin)
    compileOnly(libs.kotlin.gradle.plugin)
    compileOnly(libs.detekt.gradle.plugin)
}

gradlePlugin {
    plugins {
        register("androidApplication") {
            id = "awchat.android.application"
            implementationClass = "AwchatAndroidApplicationConventionPlugin"
        }
        register("androidLibrary") {
            id = "awchat.android.library"
            implementationClass = "AwchatAndroidLibraryConventionPlugin"
        }
        register("androidCompose") {
            id = "awchat.android.compose"
            implementationClass = "AwchatAndroidComposeConventionPlugin"
        }
        register("detekt") {
            id = "awchat.detekt"
            implementationClass = "AwchatDetektConventionPlugin"
        }
        register("kotlinLibrary") {
            id = "awchat.kotlin.library"
            implementationClass = "AwchatKotlinLibraryConventionPlugin"
        }
    }
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_21)
    }
}