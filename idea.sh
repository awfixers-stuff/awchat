rm -rf src app build .gradle && mkdir -p app/src/main/kotlin/com/example/myapp app/src/main/res/values app/src/main/kotlin/com/example/myapp/ui/theme && cat > settings.gradle.kts << 'EOF'
rootProject.name = "MyApp"
include(":app")
EOF
&& cat > build.gradle.kts << 'EOF'
plugins {
    id("com.android.application") version "9.2.0" apply false
}
EOF
&& cat > app/build.gradle.kts << 'EOF'
plugins {
    id("com.android.application")
}

android {
    namespace = "com.example.myapp"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.myapp"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.15"
    }
}

dependencies {
    val composeBom = platform("androidx.compose:compose-bom:2026.05.00")
    implementation(composeBom)
    implementation("androidx.compose.material3:material3:1.5.0-alpha21")
    implementation("androidx.activity:activity-compose:1.10.1")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    debugImplementation("androidx.compose.ui:ui-tooling")
}
EOF
&& cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:allowBackup="true"
        android:supportsRtl="true"
        android:theme="@android:style/Theme.Material.Light.NoDisplay">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@android:style/Theme.Material.Light.NoDisplay">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF
&& cat > app/src/main/kotlin/com/example/myapp/MainActivity.kt << 'EOF'
package com.example.myapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.myapp.ui.theme.MyAppTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MyAppTheme {
                Scaffold(
                    topBar = {
                        TopAppBar(title = { Text("Material 3 Expressive") })
                    }
                ) { padding ->
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(padding)
                            .padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Text(
                            "Jetpack Compose + Material 3 Expressive (alpha)",
                            style = MaterialTheme.typography.headlineSmall
                        )
                        Spacer(Modifier.height(32.dp))
                        Button(
                            onClick = { /* your action */ },
                            modifier = Modifier.fillMaxWidth(0.7f)
                        ) {
                            Text("Expressive Button")
                        }
                        Spacer(Modifier.height(16.dp))
                        FilledTonalButton(
                            onClick = { /* your action */ },
                            modifier = Modifier.fillMaxWidth(0.7f)
                        ) {
                            Text("Tonal Button")
                        }
                    }
                }
            }
        }
    }
}
EOF
&& cat > app/src/main/kotlin/com/example/myapp/ui/theme/Theme.kt << 'EOF'
package com.example.myapp.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColors = lightColorScheme()
private val DarkColors = darkColorScheme()

@Composable
fun MyAppTheme(
    darkTheme: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColors else LightColors
    MaterialTheme(
        colorScheme = colorScheme,
        content = content
    )
}
EOF
&& echo "✅ Done. Full modern Compose + Material 3 Expressive layout created."
&& echo "Run: ./gradlew assembleDebug"
