package me.awfixer.awchat.core.security.passphrase

import android.content.Context
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import me.awfixer.awchat.core.common.security.MasterKeyProvider
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import java.io.File
import java.security.SecureRandom

@RunWith(AndroidJUnit4::class)
class KeystorePassphraseProviderTest {

    private val context: Context = InstrumentationRegistry.getInstrumentation().targetContext

    @Test
    fun generatesNewPassphraseOnFirstCall() {
        val provider = createProvider()
        val passphrase = provider.getOrCreateDatabasePassphrase()

        assertEquals(32, passphrase.size)
        assertTrue(passphrase.any { it != 0.toByte() })
    }

    @Test
    fun returnsSamePassphraseOnSubsequentCalls() {
        val provider = createProvider()
        val p1 = provider.getOrCreateDatabasePassphrase()
        val p2 = provider.getOrCreateDatabasePassphrase()

        assertArrayEquals(p1, p2)
    }

    @Test
    fun persistsPassphraseAcrossInstances() {
        val masterKey = InMemoryMasterKeyProvider()
        val provider1 = KeystorePassphraseProvider(context, masterKey)
        val p1 = provider1.getOrCreateDatabasePassphrase()

        val provider2 = KeystorePassphraseProvider(context, masterKey)
        val p2 = provider2.getOrCreateDatabasePassphrase()

        assertArrayEquals(p1, p2)
    }

    @Test
    fun getOrCreateDatabasePassphraseReturnsCopy() {
        val provider = createProvider()
        val p1 = provider.getOrCreateDatabasePassphrase()
        val p2 = provider.getOrCreateDatabasePassphrase()

        p1[0] = 0xFF.toByte()
        assertTrue(!p1.contentEquals(p2))
    }

    private fun createProvider(): KeystorePassphraseProvider {
        cleanup()
        return KeystorePassphraseProvider(context, InMemoryMasterKeyProvider())
    }

    private fun cleanup() {
        File(context.filesDir, "awchat_db_passphrase.enc").delete()
    }

    private class InMemoryMasterKeyProvider : MasterKeyProvider {
        private val key = ByteArray(32).also { SecureRandom().nextBytes(it) }
        override fun getOrCreateMasterKey(): ByteArray = key.copyOf()
    }
}
