package me.awfixer.awchat.core.crypto

import androidx.test.ext.junit.runners.AndroidJUnit4
import java.lang.reflect.InvocationTargetException
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.signal.libsignal.protocol.IdentityKeyPair

@RunWith(AndroidJUnit4::class)
class LibSignalLoadTest {
    @Test
    fun nativeLibraryLoads() {
        val identity = IdentityKeyPair.generate()
        assertNotNull(identity.publicKey)
        assertNotNull(identity.privateKey)
    }

    @Test
    fun productionBuildExcludesTestingJni() {
        val error = assertThrows(InvocationTargetException::class.java) {
            val nativeTesting = Class.forName("org.signal.libsignal.internal.NativeTesting")
            val method = nativeTesting.getDeclaredMethod("test_only_fn_returns_123")
            method.invoke(null)
        }
        assertTrue(error.cause is UnsatisfiedLinkError)
    }
}