package me.awfixer.awchat.core.crypto

import androidx.test.ext.junit.runners.AndroidJUnit4
import kotlinx.coroutines.runBlocking
import me.awfixer.awchat.core.common.result.Result
import me.awfixer.awchat.core.crypto.identity.IdentityGenerator
import me.awfixer.awchat.core.crypto.internal.PreKeyBundleFactory
import me.awfixer.awchat.core.crypto.internal.ProtocolStoreFactory
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.signal.libsignal.protocol.message.CiphertextMessage

@RunWith(AndroidJUnit4::class)
class SessionManagerRoundTripTest {
    @Test
    fun encryptDecryptRoundTrip() = runBlocking {
        val aliceMaterial = IdentityGenerator.generate()
        val bobMaterial = IdentityGenerator.generate()

        val aliceStore = ProtocolStoreFactory.create(aliceMaterial)
        val bobStore = ProtocolStoreFactory.create(bobMaterial)

        val alice = LibSignalSessionManager(aliceStore)
        val bob = LibSignalSessionManager(bobStore)

        val bobBundle = PreKeyBundleFactory.createBundle(bobStore)
        assertTrue(alice.establishSession(bobMaterial.userId, bobBundle) is Result.Success)

        val plaintext = "AWChat PR6 round-trip".toByteArray(Charsets.UTF_8)
        val outbound = alice.encrypt(bobMaterial.userId, plaintext)

        assertTrue(outbound.messageType == CiphertextMessage.PREKEY_TYPE)

        val inbound =
            when (val decrypted = bob.decrypt(aliceMaterial.userId, outbound)) {
                is Result.Success -> decrypted.value
                is Result.Failure -> throw decrypted.error
            }
        assertArrayEquals(plaintext, inbound)

        val replyPlaintext = "Reply from Bob".toByteArray(Charsets.UTF_8)
        val replyOutbound = bob.encrypt(aliceMaterial.userId, replyPlaintext)
        assertTrue(replyOutbound.messageType == CiphertextMessage.WHISPER_TYPE)

        val replyInbound =
            when (val decrypted = alice.decrypt(bobMaterial.userId, replyOutbound)) {
                is Result.Success -> decrypted.value
                is Result.Failure -> throw decrypted.error
            }
        assertArrayEquals(replyPlaintext, replyInbound)
    }
}