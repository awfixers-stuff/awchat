package me.awfixer.awchat.core.security.keystore

import android.content.Context
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import java.io.File

@RunWith(AndroidJUnit4::class)
class KeystoreMasterKeyProviderTest {

    private val context: Context = InstrumentationRegistry.getInstrumentation().targetContext

    @Test
    fun generatesNewMasterKeyOnFirstCall() {
        val provider = createProvider()
        val key = provider.getOrCreateMasterKey()

        assertEquals(32, key.size)
        assertTrue(key.any { it != 0.toByte() })
    }

    @Test
    fun returnsSameMasterKeyOnSubsequentCalls() {
        val provider = createProvider()
        val key1 = provider.getOrCreateMasterKey()
        val key2 = provider.getOrCreateMasterKey()

        assertArrayEquals(key1, key2)
    }

    @Test
    fun persistsMasterKeyAcrossInstances() {
        val alias = "test-persist-key"
        val provider1 = KeystoreMasterKeyProvider(context, alias)
        val key1 = provider1.getOrCreateMasterKey()

        val provider2 = KeystoreMasterKeyProvider(context, alias)
        val key2 = provider2.getOrCreateMasterKey()

        assertArrayEquals(key1, key2)
    }

    @Test
    fun differentAliasesProduceDifferentKeys() {
        val providerA = KeystoreMasterKeyProvider(context, "test-alias-a")
        val providerB = KeystoreMasterKeyProvider(context, "test-alias-b")

        val keyA = providerA.getOrCreateMasterKey()
        val keyB = providerB.getOrCreateMasterKey()

        assertFalse(keyA.contentEquals(keyB))
    }

    @Test
    fun getOrCreateMasterKeyReturnsCopy() {
        val provider = createProvider()
        val key1 = provider.getOrCreateMasterKey()
        val key2 = provider.getOrCreateMasterKey()

        key1[0] = 0xFF.toByte()
        assertFalse(key1.contentEquals(key2))
    }

    private fun createProvider(alias: String = "test-master-key"): KeystoreMasterKeyProvider {
        cleanup(alias)
        return KeystoreMasterKeyProvider(context, alias)
    }

    private fun cleanup(alias: String) {
        val keyStore = java.security.KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        if (keyStore.containsAlias(alias)) {
            keyStore.deleteEntry(alias)
        }
        File(context.filesDir, "awchat_master_key.enc").delete()
    }
}
