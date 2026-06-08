package me.awfixer.awchat.core.crypto.sealing

import me.awfixer.awchat.core.common.security.MasterKeyProvider
import java.security.SecureRandom
class InMemoryMasterKeyProvider(
    seed: ByteArray? = null,
) : MasterKeyProvider {
    private val masterKey: ByteArray =
        seed ?: ByteArray(MASTER_KEY_BYTES).also { SecureRandom().nextBytes(it) }

    override fun getOrCreateMasterKey(): ByteArray = masterKey.copyOf()

    companion object {
        const val MASTER_KEY_BYTES = 32
    }
}