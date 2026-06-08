package me.awfixer.awchat

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class AwChatApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        System.loadLibrary("sqlcipher")
    }
}
