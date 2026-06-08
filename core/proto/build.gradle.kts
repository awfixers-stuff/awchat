plugins {
    id("awchat.kotlin.library")
    alias(libs.plugins.protobuf)
}

dependencies {
    api(libs.protobuf.javalite)
    testImplementation(libs.junit4)
}

protobuf {
    protoc {
        artifact = libs.protoc.get().toString()
    }
    generateProtoTasks {
        all().forEach { task ->
            task.builtins {
                named("java") {
                    option("lite")
                }
            }
        }
    }
}