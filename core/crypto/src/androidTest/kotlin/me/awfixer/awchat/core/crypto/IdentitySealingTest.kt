package me.awfixer.awchat.core.crypto

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import me.awfixer.awchat.core.crypto.identity.IdentityGenerator
import me.awfixer.awchat.core.crypto.identity.UserIdDeriver
import me.awfixer.awchat.core.crypto.sealing.AesGcmSealer
import me.awfixer.awchat.core.crypto.sealing.InMemoryMasterKeyProvider
import me.awfixer.awchat.core.crypto.sealing.SealedIdentityStore
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import java.io.File

@RunWith(AndroidJUnit4::class)
class IdentitySealingTest {
    @Test
    fun sealedIdentityRoundTrip() {
        val material = IdentityGenerator.generate()
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        val identityFile = File(context.cacheDir, "test-identity.sealed")

        val sealer = AesGcmSealer(InMemoryMasterKeyProvider())
        val store = SealedIdentityStore(sealer, identityFile)

        assertFalse(store.exists())
        store.save(material.identityKeyPair)
        assertTrue(store.exists())

        val restored = store.load()
        assertEquals(
            material.userId,
            UserIdDeriver.derive(restored),
        )
        assertTrue(
            material.identityKeyPair.publicKey.serialize()
                .contentEquals(restored.publicKey.serialize()),
        )

        identityFile.delete()
    }
}